function fetch() {
echo "-- fetching webrtc"
gclient config http://webrtc.googlecode.com/svn/trunk/
echo "target_os = ['mac']" >> .gclient
gclient sync

sed -i "" '$d' .gclient
echo "target_os = ['ios', 'mac']" >> .gclient
gclient sync
echo "-- webrtc has been sucessfully fetched"

}

function wrbase() {
export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1"
export GYP_GENERATORS="ninja"
}

function wrsim() {
wrbase
export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=ia32"
export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios"
export GYP_CROSSCOMPILE=1
}
 
function wrios() {
wrbase
export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=armv7"
export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios"
export GYP_CROSSCOMPILE=1
}

function buildsim() {
echo "-- building x86 webrtc"
pushd trunk
wrsim && gclient runhooks
ninja -C out_ios/Debug-iphonesimulator iossim AppRTCDemo
libtool -static -o "out_ios/Debug-iphonesimulator/libWebRTC-sim-Debug.a" out_ios/Debug-iphonesimulator/*.a
popd
echo "-- x86 webrtc has been sucessfully built"
}
 
function buildios() {
echo "-- building arm webrtc ios"
pushd trunk
wrios && gclient runhooks && ninja -C out_ios/Debug-iphoneos AppRTCDemo
libtool -static -o "out_ios/Debug-iphoneos/libWebRTC-ios-Debug.a" out_ios/Debug-iphoneos/*.a
popd
echo "-- arm webrtc has been sucessfully built"
}

function move_libs() {
echo "-- moving libraries and headers to the Respoke project"
rm -f ./Respoke/WebRTC/headers/*.*
rm -f ./Respoke/WebRTC/*.a
cp ./trunk/talk/app/webrtc/objc/public/*.h ./Respoke/WebRTC/headers/
lipo -create ./trunk/out_ios/Debug-iphonesimulator/libWebRTC-sim-Debug.a ./trunk/out_ios/Debug-iphoneos/libWebRTC-ios-Debug.a -output ./Respoke/WebRTC/libWebRTC-Debug.a
}

function fail() {
echo "*** webrtc build failed"
exit 1
}

#fetch || fail
buildsim || fail
buildios || fail
move_libs