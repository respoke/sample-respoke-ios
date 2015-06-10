Respoke SDK demo application
============================

The Respoke demo application showcases the live voice, video, and text messaging features of the [Respoke iOS SDK](https://github.com/respoke/respoke-sdk-ios).

Refer to the [Getting Started Guide](https://docs.respoke.io/client/ios/getting-started.html) for instructions on adding the Respoke SDK to your own mobile application.

Installation
============

1) Create a Respoke developer account and define a Respoke application in the [developer console](https://portal.respoke.io/#/signup). Make a note of the **application ID** for the Respoke Application you created.

2) _(Optional)_ If you would like to receive push notifications in the iOS demo app, follow the [Obtaining Push Credentials](https://docs.respoke.io/client/ios/ios-push-notification-credentials.html) guide in the Respoke documentation site to configure your iOS Developer Portal for Respoke.

3) Clone the repository from Github:

    git clone https://github.com/respoke/sample-respoke-ios.git

4) Install the CocoaPods:

    pod install

(The Respoke SDK depends on [libjingle_peerconnection](http://cocoadocs.org/docsets/libjingle_peerconnection) which ships with a ~1GB binary. So bear with us, hopefully the `pod install` step won't be necessary forever.)

5) Open LoginViewController.m and replace the value of the macro `RESPOKE_APP_ID` with the application ID you received in step 1.

When you run the application, you will be given the chance to enter an endpoint ID (similar to a user name) and an optional group. The demo app discovers other endpoints when they join a group that your endpoint is also a member of. To test the real time chat features of Respoke, run this demo app (or the Android app) on two different devices. Choose a unique endpoint ID on each device, and join the same group. The devices will then discover each other and allow you to chat through text, audio, or video.

Components
==========

The Respoke demo workspace contains several parts:

* Respoke/Respoke: The demo application showcasing the Respoke SDK capabilities.
* Respoke/RespokeTests: The demo application functional tests.
* Pods: Source files and libraries for the Respoke SDK and other dependencies.

Working with the RespokeSDK
===========================

Refer to the README on [Github](https://github.com/respoke/respoke-sdk-ios)

License
=======

The Respoke SDK and demo applications are licensed under the MIT license. Please see the [LICENSE](LICENSE) file for details.
