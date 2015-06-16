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

Running the Test Cases
==========================

The functional test cases for the demo application require a specific web application based on Respoke.js that is set up to automatically respond to certain actions that the test cases perform. This web test application is currently maintained in the [Respoke SDK repo](https://github.com/respoke/respoke-sdk-ios)
.

To run the test cases, do the following:

1) Open the file LoginTests.m and replace the value of the macro `TEST_APP_ID` with the application ID you received in step 1 of the "Installation" section above.

2) Either clone the [Respoke SDK repository](https://github.com/respoke/respoke-sdk-ios) onto your development computer, or just grab the [single-file Web Test Bot](https://github.com/respoke/respoke-sdk-ios/blob/master/RespokeSDKTests/WebTestBot/index.html) that you will need for testing the demo application.

3) Follow the instructions in the [SDK README](https://github.com/respoke/respoke-sdk-ios/blob/master/README.md) in the section "Starting the Web TESTBOT" in order to get the web test application ready for testing.

4) Open the sample application workspace in XCode and choose Product -> Test

5) The test cases will run, displaying the results inside of XCode. You will also see debug messages and video displayed in the web browser running the TestBot.

** Please note that since the test cases do functional testing with audio and video, it is necessary to use a physical iOS device. The iOS simulator will not be able to pass all of the tests.

Components
==========

The Respoke demo workspace contains several parts:

* Respoke/Respoke: The demo application showcasing the Respoke SDK capabilities.
* Respoke/RespokeTests: The demo application functional tests.
* Pods: Source files and libraries for the Respoke SDK and other dependencies.

Working with the RespokeSDK
===========================

Refer to the README on [Github](https://github.com/respoke/respoke-sdk-ios)

Contributing
============

We welcome pull requests to improve the demo application for everyone. When submitting changes, please make sure you have run the test cases before submitting and added/modified any tests that are affected by your improvements.

License
=======

The Respoke SDK and demo applications are licensed under the MIT license. Please see the [LICENSE](LICENSE) file for details.
