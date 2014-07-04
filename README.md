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
This will pull all of the code and associated submodules from a variety of sources. Expect this to take a long time to finish, and will require ~1.5 GB of storage space

