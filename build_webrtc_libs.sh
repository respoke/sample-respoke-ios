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
  export GYP_GENERATORS="ninja"
  export GYP_DEFINES="OS=ios target_arch=arm64 target_subarch=arm64 build_neon=0 $GYP_DEFINES"
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
  echo "-- building arm webrtc"
  pushd src
  wrios && gclient runhooks && ninja -C out_ios/Release-iphoneos AppRTCDemo
  popd
}

function move_libs() {
  echo "-- moving libraries and headers to the Respoke project"
  rm -f ./RespokeSDKBuilder/RespokeSDK/WebRTC/*.*
  rm -f ./RespokeSDK/libs/*.a
  cp ./src/talk/app/webrtc/objc/public/*.h ./RespokeSDKBuilder/RespokeSDK/WebRTC/

  libtool -static -o src/out_ios/Release-iphonesimulator/libWebRTC-sim.a src/out_ios/Release-iphonesimulator/*.a
  strip -S -x -o src/out_ios/Release-iphonesimulator/libWebRTC-sim-min.a -r src/out_ios/Release-iphonesimulator/libWebRTC-sim.a
  libtool -static -o src/out_ios/Release-iphoneos/libWebRTC-ios.a src/out_ios/Release-iphoneos/*.a
  strip -S -x -o src/out_ios/Release-iphoneos/libWebRTC-ios-min.a -r src/out_ios/Release-iphoneos/libWebRTC-ios.a
  lipo -create src/out_ios/Release-iphonesimulator/libWebRTC-sim-min.a src/out_ios/Release-iphoneos/libWebRTC-ios-min.a -output ./RespokeSDK/libs/libWebRTC.a
}

#buildsim || buildios || 
move_libs