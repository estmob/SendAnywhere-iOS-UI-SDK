<p align="center" >
  <img src="https://dj8mgfv7cr8nn.cloudfront.net/assets/img/brand/logo_sendanywhere_retina.png" alt="SendAnywhere" title="SendAnywhere">
</p>


[![Version](https://img.shields.io/cocoapods/v/SendAnywhereSDK.svg?style=flat)](http://cocoapods.org/pods/SendAnywhereSDK)
[![License](https://img.shields.io/cocoapods/l/SendAnywhereSDK.svg?style=flat)](http://cocoapods.org/pods/SendAnywhereSDK)
[![Platform](https://img.shields.io/cocoapods/p/SendAnywhereSDK.svg?style=flat)](http://cocoapods.org/pods/SendAnywhereSDK)
[![Twitter](https://img.shields.io/badge/twitter-@SendAnywhere-blue.svg?style=flat)](http://twitter.com/send_anywhere)
[![Facebook](https://img.shields.io/badge/facebook-@SendAnywhere-blue.svg?style=flat)](https://www.facebook.com/Send2Anywhere)

The simplest way to Send files Anywhere

## Prequisites
Please issue your API key from following link first:
https://send-anywhere.com/web/page/api


### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like SendAnywhereSDK in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile

To integrate SendAnywhereSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'SendAnywhereSDK', '~> 4.0'
end
```

Then, run the following command:

```bash
$ pod install
```

## Requirements

| Minimum iOS Target  | iOS 8 |
|:--------------------:|:-----:|

## Troubleshooting
If you have any problem or questions with Send Anywhere iOS SDK, please create new issue(https://github.com/estmob/SendAnywhere-iOS-UI-SDK/issues) or contact to our customer center(https://send-anywhere.zendesk.com).

## Usage
First look at the source code of [the provided demo](https://github.com/dustmob/SendAnywhereSDK/tree/master/Example).

#### Initialization

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SendAnywhere.withKey("INPUT_YOUR_API_KEY")
        return true
}
```

#### Show a Send file UI.

```swift
try? sa_showSendView(withFiles: [<FILEURL>])
```

## License

SendAnywhereSDK is available under the MIT license. See the LICENSE file for more info.
