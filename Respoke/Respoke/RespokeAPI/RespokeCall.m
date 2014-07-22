//
//  RespokeCall.m
//  Respoke
//
//  Created by Jason Adams on 7/18/14.
//  Copyright (c) 2014 Ninjanetic Design Inc. All rights reserved.
//

#import "RespokeCall.h"
#import "RespokeEndpoint.h"
#import "Respoke.h"
#import <AVFoundation/AVFoundation.h>
#import "RTCICECandidate.h"
#import "RTCICEServer.h"
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCStatsDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoSource.h"
#import "RTCEAGLVideoView.h"


@interface RespokeCall () <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCStatsDelegate, RTCEAGLVideoViewDelegate> {
    RespokeSignalingChannel *signalingChannel;
    NSMutableArray *iceServers;
    RTCPeerConnection* peerConnection;
    RTCPeerConnectionFactory* peerConnectionFactory;
    RTCVideoSource* videoSource;
    NSMutableArray* queuedRemoteCandidates;
    NSMutableArray *queuedLocalCandidates;
    RTCEAGLVideoView* localVideoView;
    RTCEAGLVideoView* remoteVideoView;
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
    BOOL caller;
    BOOL waitingForAnswer;
    NSDictionary *incomingSDP;
}

@end


@implementation RespokeCall


- (instancetype)initWithSignalingChannel:(RespokeSignalingChannel*)channel
{
    if (self = [super init])
    {
        signalingChannel = channel;
        iceServers = [[NSMutableArray alloc] init];
        queuedLocalCandidates = [[NSMutableArray alloc] init];
        [RTCPeerConnectionFactory initializeSSL];
        peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
        self.sessionID = [Respoke makeGUID];
        [signalingChannel.clientDelegate callCreated:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }

    return self;
}


- (instancetype)initWithSignalingChannel:(RespokeSignalingChannel*)channel incomingCallSDP:(NSDictionary*)sdp
{
    if (self = [self initWithSignalingChannel:channel])
    {
        incomingSDP = sdp;
    }

    return self;
}


- (void)applicationWillResignActive
{
    NSLog(@"Application lost focus, connection broken.");
    [self disconnect];
    [self.delegate onHangup:self];
}


- (void)disconnect 
{
    [peerConnection close];
    peerConnection = nil;
    videoSource = nil;
    queuedRemoteCandidates = nil;
    [remoteVideoView removeFromSuperview];
    [localVideoView removeFromSuperview];
    remoteVideoView = nil;
    localVideoView = nil;
    self.remoteView = nil;
    self.localView = nil;
    [signalingChannel.clientDelegate callTerminated:self];
}


- (void)startCall
{
    caller = YES;
    waitingForAnswer = YES;

    [self getTurnServerCredentialsWithSuccessHandler:^(void){
        [self addLocalStreams];
        [self createOffer];
    } errorHandler:^(NSString *errorMessage){
        [self.delegate onError:errorMessage sender:self];
    }];
}


- (void)answerCall
{
    if (!caller)
    {
        [self getTurnServerCredentialsWithSuccessHandler:^(void){
            [self addLocalStreams];
            [self processRemoteSDP];
        } errorHandler:^(NSString *errorMessage){
            [self.delegate onError:errorMessage sender:self];
        }];
    }
}


- (void)hangup
{
    NSDictionary *signalData = @{@"signalType": @"hangup", @"target": @"call", @"to": self.endpoint.endpointID, @"sessionId": self.sessionID, @"signalId": [Respoke makeGUID]};
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:signalData options:0 error:&jsonError];
    
    if (!jsonError)
    {
        NSString *jsonSignal = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSDictionary *data = @{@"signal": jsonSignal, @"to": self.endpoint.endpointID};

        [signalingChannel sendRESTMessage:@"post" url:@"/v1/signaling" data:data responseHandler:^(id response, NSString *errorMessage) {
            if (errorMessage)
            {
                [self.delegate onError:errorMessage sender:self];
            }
        }];
    }
    else
    {
        [self.delegate onError:@"Error encoding hangup signal to json" sender:self];
    }

    [self disconnect];
}


- (void)hangupReceived
{
    [self disconnect];
    [self.delegate onHangup:self];
}


- (void)answerReceived:(NSDictionary*)remoteSDP fromConnection:(NSString*)remoteConnection
{
    incomingSDP = remoteSDP;
    self.toConnection = remoteConnection;

    NSDictionary *signalData = @{@"signalType": @"connected", @"target": @"call", @"to": self.endpoint.endpointID, @"toConnection": self.toConnection, @"sessionId": self.sessionID, @"signalId": [Respoke makeGUID]};
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:signalData options:0 error:&jsonError];
    
    if (!jsonError)
    {
        NSString *jsonSignal = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSDictionary *data = @{@"signal": jsonSignal, @"to": self.endpoint.endpointID};

        [signalingChannel sendRESTMessage:@"post" url:@"/v1/signaling" data:data responseHandler:^(id response, NSString *errorMessage) {
            if (errorMessage)
            {
                [self.delegate onError:errorMessage sender:self];
            }
            else
            {
                [self processRemoteSDP];
                [self.delegate onConnected:self];
            }
        }];
    }
    else
    {
        [self.delegate onError:@"Error encoding ice candidate to json" sender:self];
    }
}


- (void)connectedReceived
{
    [self.delegate onConnected:self];
}


- (void)iceCandidatesReceived:(NSArray*)candidates
{
    for (NSDictionary *eachCandidate in candidates)
    {
        NSString* mid = [eachCandidate objectForKey:@"sdpMid"];
        NSNumber* sdpLineIndex = [eachCandidate objectForKey:@"sdpMLineIndex"];
        NSString* sdp = [eachCandidate objectForKey:@"candidate"];

        RTCICECandidate* rtcCandidate = [[RTCICECandidate alloc] initWithMid:mid index:sdpLineIndex.intValue sdp:sdp];

        if (queuedRemoteCandidates)
        {
            [queuedRemoteCandidates addObject:rtcCandidate];
        }
        else
        {
            [peerConnection addICECandidate:rtcCandidate];
        }
    }
}


- (void)processRemoteSDP
{
    NSString *type = [incomingSDP objectForKey:@"type"];
    NSString *sdpString = [incomingSDP objectForKey:@"sdp"];

    if (type && sdpString)
    {
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:type sdp:[[self class] preferISAC:sdpString]];
        [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
    }
    else
    {
        [self.delegate onError:@"Invalid call sdp" sender:self];
    }
}


- (void)getTurnServerCredentialsWithSuccessHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString*))errorHandler
{
    // get TURN server credentials
    [signalingChannel sendRESTMessage:@"get" url:@"/v1/turn" data:nil responseHandler:^(id response, NSString *errorMessage) {
        if (errorMessage)
        {
            errorHandler(errorMessage);
        }
        else
        {
            if ([response isKindOfClass:[NSDictionary class]])
            {
                NSString *username = [response objectForKey:@"username"];
                NSString *password = [response objectForKey:@"password"];
                NSArray *uris = [response objectForKey:@"uris"];

                for (NSString *eachUri in uris)
                {
                    RTCICEServer* server = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:eachUri] username:username password:password];
                    [iceServers addObject:server];
                }

                if ([iceServers count] > 0)
                {
                    successHandler();
                }
                else
                {
                    errorHandler(errorMessage);
                }
            }
            else
            {
                errorHandler(@"Unexpected response from server");
            }
        }
    }];
}


- (void)addLocalStreams
{
    queuedRemoteCandidates = [[NSMutableArray alloc] init];
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc]
            initWithMandatoryConstraints:@[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], 
                                           [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:self.audioOnly ? @"false" : @"true"]]
                     optionalConstraints:@[[[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"],
                                           [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]]];
    peerConnection = [peerConnectionFactory peerConnectionWithICEServers:iceServers constraints:constraints delegate:self];
    RTCMediaStream* lms = [peerConnectionFactory mediaStreamWithLabel:@"ARDAMS"];

    if (!self.audioOnly)
    {
        remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.remoteView.bounds];
        remoteVideoView.delegate = self;
        remoteVideoView.transform = CGAffineTransformMakeScale(-1, 1);
        [self.remoteView addSubview:remoteVideoView];

        localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.localView.bounds];
        localVideoView.delegate = self;
        [self.localView addSubview:localVideoView];

        [self updateVideoViewLayout];
        
        // The iOS simulator doesn't provide any sort of camera capture
        // support or emulation (http://goo.gl/rHAnC1) so don't bother
        // trying to open a local stream.

        // TODO(tkchin): local video capture for OSX. See
        // https://code.google.com/p/webrtc/issues/detail?id=3417.
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
        RTCVideoTrack* localVideoTrack;
        NSString* cameraID = nil;

        for (AVCaptureDevice* captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) 
        {
            if (captureDevice.position == AVCaptureDevicePositionFront)
            {
                cameraID = [captureDevice localizedName];
                break;
            }
        }

        NSAssert(cameraID, @"Unable to get the front camera id");

        RTCVideoCapturer* capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
        videoSource = [peerConnectionFactory videoSourceWithCapturer:capturer constraints:nil];
        localVideoTrack = [peerConnectionFactory videoTrackWithID:@"ARDAMSv0" source:videoSource];

        if (localVideoTrack) 
        {
            [lms addVideoTrack:localVideoTrack];
        }

        localVideoView.videoTrack = localVideoTrack;
#endif
    }

    [lms addAudioTrack:[peerConnectionFactory audioTrackWithID:@"ARDAMSa0"]];
    [peerConnection addStream:lms constraints:constraints];
}


- (void)createOffer
{
    RTCPair* audio = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"];
    RTCPair* video = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:self.audioOnly ? @"false" : @"true"];
    NSArray* mandatory = @[ audio, video ];
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:nil];
    
    [peerConnection createOfferWithDelegate:self constraints:constraints];
}


- (void)updateVideoViewLayout
{
    CGSize defaultAspectRatio = CGSizeMake(4, 3);
    CGSize localAspectRatio = CGSizeEqualToSize(_localVideoSize, CGSizeZero) ? defaultAspectRatio : _localVideoSize;
    CGSize remoteAspectRatio = CGSizeEqualToSize(_remoteVideoSize, CGSizeZero) ? defaultAspectRatio : _remoteVideoSize;

    CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(remoteAspectRatio, self.remoteView.bounds);
    remoteVideoView.frame = remoteVideoFrame;

    CGRect localVideoFrame = AVMakeRectWithAspectRatioInsideRect(localAspectRatio, self.localView.bounds);
    localVideoView.frame = localVideoFrame;
}


#pragma mark - RTCEAGLVideoViewDelegate


- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size 
{
    if (videoView == localVideoView) 
    {
        _localVideoSize = size;
    } 
    else if (videoView == remoteVideoView) 
    {
        _remoteVideoSize = size;
    } 
    else 
    {
        NSParameterAssert(NO);
    }

    [self updateVideoViewLayout];
}


#pragma mark - RTCPeerConnectionDelegate


- (void)peerConnectionOnError:(RTCPeerConnection*)peerConnection 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate onError:@"PeerConnection failed." sender:self];
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PCO onSignalingStateChange: %d", stateChanged);
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection addedStream:(RTCMediaStream*)stream 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PCO onAddStream.");
        NSAssert([stream.audioTracks count] == 1 || [stream.videoTracks count] == 1, @"Expected audio or video track");
        NSAssert([stream.audioTracks count] <= 1, @"Expected at most 1 audio stream");
        NSAssert([stream.videoTracks count] <= 1, @"Expected at most 1 video stream");

        if ([stream.videoTracks count] != 0) 
        {
            remoteVideoView.videoTrack = stream.videoTracks[0];
        }
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection removedStream:(RTCMediaStream*)stream 
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        NSLog(@"PCO onRemoveStream."); 
    });
}


- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection*)peerConnection 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PCO onRenegotiationNeeded - ignoring because AppRTC has a predefined negotiation strategy");
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection gotICECandidate:(RTCICECandidate*)candidate 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PCO onICECandidate.\n  Mid[%@] Index[%li] Sdp[%@]", candidate.sdpMid, (long)candidate.sdpMLineIndex, candidate.sdp);

        if (caller && waitingForAnswer)
        {
            [queuedLocalCandidates addObject:candidate];
        }
        else
        {
            [self sendLocalCandidate:candidate];
        }
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState 
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        NSLog(@"PCO onIceGatheringChange. %d", newState); 
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PCO onIceConnectionChange. %d", newState);

        if (newState == RTCICEConnectionConnected)
        {
            NSLog(@"ICE Connection Connected.");
        }
        else if (newState == RTCICEConnectionFailed)
        {
            [self.delegate onError:@"ICE Connection failed!" sender:self];
            [self disconnect];
            [self.delegate onHangup:self];
            self.delegate = nil;
        }
    });
}


- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel 
{
    NSAssert(NO, @"AppRTC doesn't use DataChannels");
}


#pragma mark - RTCSessionDescriptionDelegate


- (void)peerConnection:(RTCPeerConnection*)thePeerConnection didCreateSessionDescription:(RTCSessionDescription*)origSdp error:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) 
        {
            [self.delegate onError:@"SDP didCreateSessionDescription onFailure." sender:self];
        }
        else
        {
            NSLog(@"SDP onSuccess(SDP) - set local description.");
            RTCSessionDescription* sdp = [[RTCSessionDescription alloc] initWithType:origSdp.type sdp:[[self class] preferISAC:origSdp.description]];
            [thePeerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
            NSLog(@"PC setLocalDescription.");

            NSDictionary *signalData = @{@"signalType": sdp.type, @"target": @"call", @"to": self.endpoint.endpointID, @"sessionId": self.sessionID, @"sdp": @{@"sdp": sdp.description, @"type": sdp.type}, @"signalId": [Respoke makeGUID]};
            NSError *jsonError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:signalData options:0 error:&jsonError];
            
            if (!jsonError)
            {
                NSString *jsonSignal = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSDictionary *data = @{@"signal": jsonSignal, @"to": self.endpoint.endpointID};

                [signalingChannel sendRESTMessage:@"post" url:@"/v1/signaling" data:data responseHandler:^(id response, NSString *errorMessage) {
                    if (errorMessage)
                    {
                        [self.delegate onError:errorMessage sender:self];
                    }
                }];
            }
            else
            {
                [self.delegate onError:@"Error encoding offer/answer to json" sender:self];
            }
        }
    });
}


- (void)peerConnection:(RTCPeerConnection*)thePeerConnection didSetSessionDescriptionWithError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) 
        {
            [self.delegate onError:@"SDP didSetSessionDescriptionWithError onFailure." sender:self];
        }
        else
        {
            NSLog(@"SDP onSuccess() - possibly drain candidates");

            if (caller) 
            {
                if (peerConnection.remoteDescription) 
                {
                    NSLog(@"SDP onSuccess - drain candidates");
                    waitingForAnswer = NO;
                    [self drainRemoteCandidates];
                    [self drainLocalCandidates];
                }
            }
            else
            {
                if (thePeerConnection.remoteDescription && !thePeerConnection.localDescription)
                {
                    NSLog(@"Callee, setRemoteDescription succeeded");
                    RTCPair* audio = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"];
                    RTCPair* video = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"];
                    NSArray* mandatory = @[ audio, video ];
                    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:nil];
                    [thePeerConnection createAnswerWithDelegate:self constraints:constraints];
                    NSLog(@"PC - createAnswer.");
                } 
                else
                {
                    NSLog(@"SDP onSuccess - drain candidates");
                    [self drainRemoteCandidates];
                }
            } 
        }
    });
}


- (void)drainRemoteCandidates 
{
    for (RTCICECandidate* candidate in queuedRemoteCandidates) 
    {
        [peerConnection addICECandidate:candidate];
    }

    queuedRemoteCandidates = nil;
}


- (void)drainLocalCandidates
{
    for (RTCICECandidate* candidate in queuedLocalCandidates) 
    {
        [self sendLocalCandidate:candidate];
    }   
}


- (void)sendLocalCandidate:(RTCICECandidate*)candidate
{
    NSDictionary *candidateDict = @{@"sdpMLineIndex": [NSNumber numberWithInteger:candidate.sdpMLineIndex], @"sdpMid": candidate.sdpMid, @"candidate": candidate.sdp};
    NSDictionary *signalData = @{@"signalType": @"iceCandidates", @"target": @"call", @"to": self.endpoint.endpointID, @"toConnection": self.toConnection, @"iceCandidates": @[candidateDict], @"sessionId": self.sessionID, @"signalId": [Respoke makeGUID]};
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:signalData options:0 error:&jsonError];
    
    if (!jsonError)
    {
        NSString *jsonSignal = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSDictionary *data = @{@"signal": jsonSignal, @"to": self.endpoint.endpointID};

        [signalingChannel sendRESTMessage:@"post" url:@"/v1/signaling" data:data responseHandler:^(id response, NSString *errorMessage) {
            if (errorMessage)
            {
                [self.delegate onError:errorMessage sender:self];
            }
        }];
    }
    else
    {
        [self.delegate onError:@"Error encoding ice candidate to json" sender:self];
    }
}


#pragma mark - RTCStatsDelegate methods


- (void)peerConnection:(RTCPeerConnection*)peerConnection didGetStats:(NSArray*)stats 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Stats:\n %@", stats);
    });
}


#pragma mark - misc


// Mangle |origSDP| to prefer the ISAC/16k audio codec.
+ (NSString*)preferISAC:(NSString*)origSDP 
{
    int mLineIndex = -1;
    NSString* isac16kRtpMap = nil;
    NSArray* lines = [origSDP componentsSeparatedByString:@"\n"];
    NSRegularExpression* isac16kRegex = [NSRegularExpression regularExpressionWithPattern:@"^a=rtpmap:(\\d+) ISAC/16000[\r]?$" options:0 error:nil];

    for (int i = 0; (i < [lines count]) && (mLineIndex == -1 || isac16kRtpMap == nil); ++i) 
    {
        NSString* line = [lines objectAtIndex:i];

        if ([line hasPrefix:@"m=audio "]) 
        {
            mLineIndex = i;
            continue;
        }

        isac16kRtpMap = [self firstMatch:isac16kRegex withString:line];
    }
    
    if (mLineIndex == -1) 
    {
        NSLog(@"No m=audio line, so can't prefer iSAC");
        return origSDP;
    }
    
    if (isac16kRtpMap == nil) 
    {
        NSLog(@"No ISAC/16000 line, so can't prefer iSAC");
        return origSDP;
    }

    NSArray* origMLineParts = [[lines objectAtIndex:mLineIndex] componentsSeparatedByString:@" "];
    NSMutableArray* newMLine = [NSMutableArray arrayWithCapacity:[origMLineParts count]];
    int origPartIndex = 0;

    // Format is: m=<media> <port> <proto> <fmt> ...
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:isac16kRtpMap];

    for (; origPartIndex < [origMLineParts count]; ++origPartIndex) 
    {
        if (![isac16kRtpMap isEqualToString:[origMLineParts objectAtIndex:origPartIndex]]) 
        {
            [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex]];
        }
    }

    NSMutableArray* newLines = [NSMutableArray arrayWithCapacity:[lines count]];
    [newLines addObjectsFromArray:lines];
    [newLines replaceObjectAtIndex:mLineIndex withObject:[newMLine componentsJoinedByString:@" "]];
    return [newLines componentsJoinedByString:@"\n"];
}


// Match |pattern| to |string| and return the first group of the first
// match, or nil if no match was found.
+ (NSString*)firstMatch:(NSRegularExpression*)pattern withString:(NSString*)string 
{
    NSTextCheckingResult* result = [pattern firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (!result)
        return nil;

    return [string substringWithRange:[result rangeAtIndex:1]];
}


@end
