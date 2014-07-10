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
popd
echo "-- x86 webrtc has been sucessfully built"
}
 
function buildios() {
echo "-- building arm webrtc ios"
pushd trunk
wrios && gclient runhooks && ninja -C out_ios/Debug-iphoneos AppRTCDemo
popd
echo "-- arm webrtc has been sucessfully built"
}

function move_libs() {
echo "-- moving libraries and headers to the Respoke project"
rm -f ./Respoke/WebRTC/headers/*.*
rm -f ./Respoke/WebRTC/*.a
cp ./trunk/talk/app/webrtc/objc/public/*.h ./Respoke/WebRTC/headers/

pushd trunk
pushd out_ios
pushd Debug-iphoneos

for f in *.a; do
  if [ -f "../Debug-iphonesimulator/$f" ]; then
    echo "creating fat static library $f"
    lipo -create "$f" "../Debug-iphonesimulator/$f" -output "../../../Respoke/WebRTC/$f"
  else
    echo ""
    echo "$f was not built for the simulator."
    echo ""
    cp "$f" "../../../Respoke/WebRTC/"
  fi
done

cd ../Debug-iphonesimulator
for f in *.a; do
  if [ ! -f "../Debug-iphoneos/$f" ]; then
    echo ""
    echo "$f was not built for the iPhone."
    echo ""
    cp "$f" "../../../Respoke/WebRTC/"
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