respoke-ios
===========

iOS prototype for the Respoke.io service

This XCode project contains all of the signaling layer and UI control for the prototype. It is built on top of the open-source WebRTC libraries supplied by Google.

The libraries themselves have been pre-compiled and included into this repository, so there is no reason to have to compile them from scratch (unless you are evaluating upstream changes). To change the signaling layer or UI code, just work directly with the XCode project included here.

If you would like to modify or update the WebRTC libraries, then follow the instructions below.

Building the WebRTC libraries from scratch
==========================================

The open-source code lives here:

https://code.google.com/p/webrtc/

The WebRTC source code is a nightmarish onion of layers, and can be challenging to build correctly for iOS. Build scripts have been included in this repository to automate as much of this process as possible. For a list of the many individual steps, and workarounds for frequent problems, take a look at my blog post here:

http://ninjanetic.com/how-to-get-started-with-webrtc-and-ios-without-wasting-10-hours-of-your-life/

Prerequisites:
--------------
* XCode 5.1+ with the Command Line Tools installed (Preferences -> Downloads -> Command Line Tools)
* Git installed and working

The build scripts assume that all of the WebRTC code will be placed inside of this repository's directory structure. The first step is to get the Chromium Depot Tools, which are used to pull the source code and build it later.

Step 1: Chromium tools
----------------------

From the terminal, change into the root directory of this repository wherever it lives on your system. We will assume that it resides in /projects/respoke-ios for the purposes of documentation:
```
$ cd /projects/respoke-ios
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```
These are a bunch of tools used during the build process, and they will need to be in your path so you will need to modify your .bash_profile (or other shell file) and modify the PATH line like so:
```
$ export PATH=/projects/respoke-ios/depot_tools:$PATH
```
Next you will need to restart your terminal or re-run your bash profile so that the changes take effect:
```
$ source ~/.bash_profile
```
Step 2: Download the WebRTC source code
---------------------------------------

A build script has been provided to pull the correct revision of the source code:
```
$ ./pull_webrtc_source.sh
```
This will pull all of the code and associated submodules from a variety of sources. Expect this to take a long time to finish, and will require ~1.5 GB of storage space. If you would like to use a newer version of the WebRTC source, then edit this file and change the first line to define the specific revision # you are interested in using. I highly recommend one of the stable releases, as the daily builds seem to break somewhat regularly.

Step 3: Build the libraries
---------------------------

Another build script has been provided to handle actually building the libraries.
```
$ ./build_webrtc_libs
```
This will build the massive WebRTC source, combine the assorted libraries into a single universal simulator/device compatible library, and then replace the compiled library and associated headers inside of the Respoke iOS project with the new ones. Once it completes successfully, you should be able to open the XCode project, recompile and go.

If you encounter an error during the build phase, there are a multitude of things that could have gone wrong. If you see this error in particular:
```
AssertionError: Multiple codesigning fingerprints for identity: iPhone Developer
```
Go check out the "Curveball: codesigning" section of my blog post for workarounds. 

Notes about WebRTC library
--------------------------

The open source WebRTC libraries currently do not build for the armv7s architecture, so it's necessary that any XCode project using this library skip that architecture (it's one of the standard architectures defined for new projects). The library built here will still run on armv7s devices (the newest) but will not be 100% optimized for them. You will get a build error if you try to build for the armv7s architecture.

The WebRTC library is also currently built in debug mode. Release mode has been rumored to have reliability issues at the moment.