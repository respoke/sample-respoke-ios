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

function wrios64() {
  wrbase
  export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=arm64 target_subarch=arm64"
  export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_arm64"
  export GYP_CROSSCOMPILE=1
}

function buildsim() {
  echo "-- building x86 webrtc"
  pushd src
  wrsim && gclient runhooks
  ninja -C out_ios/Release-iphonesimulator iossim AppRTCDemo
  popd
}
 
function buildios() {
  echo "-- building armv7 webrtc"
  pushd src
  wrios && gclient runhooks && ninja -C out_ios/Release-iphoneos AppRTCDemo
  popd
}
 
function buildios64() {
  echo "-- building arm64 webrtc"
  pushd src
  wrios64 && gclient runhooks && ninja -C out_arm64/Release-iphoneos AppRTCDemo
  popd
}

function move_libs() {
  echo "-- moving libraries and headers to the Respoke project"
  rm -f ./RespokeSDKBuilder/RespokeSDK/WebRTC/*.*
  rm -f ./RespokeSDK/libs/*.a
  cp ./src/talk/app/webrtc/objc/public/*.h ./RespokeSDKBuilder/RespokeSDK/WebRTC/

  libtool -static -o src/out_ios/libWebRTC-sim.a src/out_ios/Release-iphonesimulator/*.a
  strip -S -x -o src/out_ios/libWebRTC-sim-min.a -r src/out_ios/libWebRTC-sim.a
  libtool -static -o src/out_ios/libWebRTC-ios.a src/out_ios/Release-iphoneos/*.a
  strip -S -x -o src/out_ios/libWebRTC-ios-min.a -r src/out_ios/libWebRTC-ios.a
  libtool -static -o src/out_arm64/libWebRTC-ios64.a src/out_arm64/Release-iphoneos/*.a
  strip -S -x -o src/out_arm64/libWebRTC-ios64-min.a -r src/out_arm64/libWebRTC-ios64.a
  lipo -create src/out_ios/libWebRTC-sim-min.a src/out_ios/libWebRTC-ios-min.a src/out_arm64/libWebRTC-ios64-min.a -output ./RespokeSDK/libs/libWebRTC.a
}

buildsim && buildios && buildios64 && move_libs