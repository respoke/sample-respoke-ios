Respoke SDK demo application
============================

The Respoke demo application showcases the live voice, video, and text messaging features of the [Respoke iOS SDK](https://github.com/respoke/respoke-sdk-ios).

Refer to the [Getting Started Guide](https://docs.respoke.io/client/ios/getting-started.html) for instructions on adding the Respoke SDK to your own mobile application.

Installation
============

Clone the repository from Github:

    git clone https://github.com/respoke/respoke-ios.git

Then install the CocoaPods:

    pod install

(The Respoke SDK depends on [libjingle_peerconnection](http://cocoadocs.org/docsets/libjingle_peerconnection) which ships with a ~1GB binary. So bear with us, hopefully the `pod install` step won't be necessary forever.)

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
