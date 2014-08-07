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
ninja -C out_ios/Release-iphonesimulator iossim AppRTCDemo
popd
echo "-- x86 webrtc has been sucessfully built"
}
 
function buildios() {
echo "-- building arm webrtc ios"
pushd trunk
wrios && gclient runhooks && ninja -C out_ios/Release-iphoneos AppRTCDemo
popd
echo "-- arm webrtc has been sucessfully built"
}

function move_libs() {
echo "-- moving libraries and headers to the Respoke project"
rm -f ./RespokeSDK/WebRTC/headers/*.*
rm -f ./RespokeSDK/WebRTC/*.a
cp ./trunk/talk/app/webrtc/objc/public/*.h ./RespokeSDK/WebRTC/headers/

pushd trunk
pushd out_ios
pushd Release-iphoneos

# libjingle_p2p.a is larger than the maximum file size allowed by Github, let alone when combined with the device slice as well. Therefore, unlike the rest of the libraries, they will be renamed to two separate files and then optionally included in the project to get around this file size limitation.
mv libjingle_p2p.a libjingle_p2p_armv7.a

for f in *.a; do
  if [ -f "../Release-iphonesimulator/$f" ]; then
    echo "creating fat static library $f"
    lipo -create "$f" "../Release-iphonesimulator/$f" -output "../../../RespokeSDK/WebRTC/$f"
  else
    echo ""
    echo "$f was not built for the simulator."
    echo ""
    cp "$f" "../../../RespokeSDK/WebRTC/"
  fi
done

cd ../Release-iphonesimulator
mv libjingle_p2p.a libjingle_p2p_x86.a
cp libjingle_p2p_x86.a ../../../RespokeSDK/WebRTC/

for f in *.a; do
  if [ ! -f "../Release-iphoneos/$f" ]; then
    echo ""
    echo "$f was not built for the iPhone."
    echo ""
    cp "$f" "../../../RespokeSDK/WebRTC/"
  fi
done

popd
popd
popd
}

function fail() {
echo "*** webrtc build failed"
exit 1
}

#fetch || fail
buildsim || fail
buildios || fail
move_libs