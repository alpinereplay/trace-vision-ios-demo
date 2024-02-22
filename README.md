# trace-vision-ios-demo
TraceVisionSDK Demo app (SwiftUI) that demonstrates the usage of [TraceVision SDK](https://tracevision.com) to process the soccer video and create the valuable highlights on the fly
This app will allow you to learn how to use TraceVision SDK

- with a pre-recorded video from camera roll
- record the video with iPhone and create the highlights on the fly

## Installation

There are several things that you need to do before you can compile the app and run it on your phone.

### Get the SDK and API keys

To start with the app you'll need the TraceVision SDK binary framework and a pair of keys to initialize it.
You can download the framework and find your keys in the [developer portal](https://developer.tracevision.com)

Once you have the token+secret and clone this repo, set the keys in [AppDelegate.swift](TraceVisionDemo/TraceVisionDemo/AppDelegate.swift#L19) 

```swift
/// Set your consumer token and secret here
///
/// You can find your API token and secret in
/// the [TraceVision developer console](https://developer.tracevision.com).
let VISION_TOKEN = "PUT_YOUR_TOKEN_HERE"
let VISION_SECRET = "PUT_YOUR_SECRET_HERE"
```

### Adding the SDK

- Unpack TraceVision SDK framework
- Drag and drop it into your project

### Run the demo app

Now you are ready to compile, install and run the demo app on your device.


