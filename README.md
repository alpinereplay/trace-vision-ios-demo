# trace-vision-ios-demo
TraceVisionSDK Demo app (SwiftUI) that demonstrates the usage of [TraceVision SDK](https://tracevision.com) to process the soccer video and create the valuable highlights on the fly.

This app will allow you to learn how to use TraceVision SDK

- with a pre-recorded video from camera roll.
- record the video with iPhone and create the highlights during the recording.

## Installation

There are several steps that you need to do before you can compile the app and run it on your phone.

### Prepare XCode project
This project requires the use of CocaoPods ([install instructions](https://guides.cocoapods.org/using/getting-started.html))

Clone repo: 
```
git clone https://github.com/tracevision/trace-vision-ios-demo.git
```

In terminal, navitage to `trace-vision-ios-demo/TraceVisionDemo` and run;
```
pod install
```

This will generate `TraceVisionDemo.xcworkspace`. 

For the following steps, open `TraceVisionDemo.xcworkspace`, NOT `TraceVisionDemo.xcodeproj`

### Get the SDK and API keys

To start with the app you'll need the TraceVision SDK binary framework and a pair of keys to initialize it.

You can download the framework and find your keys in the [developer portal](https://developer.tracevision.com). 

Once you have the token+secret, set the keys in [AppDelegate.swift](TraceVisionDemo/TraceVisionDemo/AppDelegate.swift#L19) 

```swift
/// Set your vision token and secret here.
let VISION_TOKEN = "PUT_YOUR_TOKEN_HERE"
let VISION_SECRET = "PUT_YOUR_SECRET_HERE"
```

### Adding the SDK

- Unpack TraceVision SDK framework archive.
- Open Xcode workspace (`TraceVisionDemo.xcworkspace`) and navigate to the `TraceVisionDemo` target’s General settings.
- Scroll down to the “Frameworks, Libraries, and Embedded Content” section.
- Drag and drop the `TraceVisionSDK.xcframework` XCFramework from Finder to this section in Xcode.

### Run the demo app

Now you are ready to compile, install and run the demo app on your device.

## Inside the demo app code

Here are several hints where to find the valuable code that uses the SDK

[AppDelegate.swift](TraceVisionDemo/TraceVisionDemo/AppDelegate.swift) 

- Initializing the SDK

[MainView.swift](TraceVisionDemo/TraceVisionDemo/views/MainView.swift) 

- Waiting for SDK to initialize
- Using `VideoPickerView` to pick the video from the camera roll.
- Initializing the video import or video recording session of the SDK.

[ImportedVideoProcessView.swift](TraceVisionDemo/TraceVisionDemo/views/importing/ImportedVideoProcessView.swift) 

- Loading video from camera roll into the local storage.
- Importing the local video into the video import session.
- Processing the video, finding the highlights.
- Updating the visual progress and number of highlights found so far using the processing status.
- Showing the highlights when the processing is finished.

[VideoRecorderView.swift](TraceVisionDemo/TraceVisionDemo/views/recording/VideoRecorderView.swift)

- Initializing the rear camera with the SDK.
- Showing the camera preview.
- Managing zoom controls with the recording session.
- Recording the video and processing the highlights in real time.
- Updating the number of highlights found on the fly.
- Stopping the recording and the camera.

[HighlightGallery.swift](TraceVisionDemo/TraceVisionDemo/views/gallery/HighlightGallery.swift)

- Loading a list of saved highlights.
- Using filters to get the highlights according to the user choice.

[GalleryView.swift](TraceVisionDemo/TraceVisionDemo/views/gallery/GalleryView.swift)

- Getting and displaying highlight thumbnails.

[JersetPicker.swift](TraceVisionDemo/TraceVisionDemo/views/gallery/JerseyPicker.swift)

- Getting a list of available jersey numbers from the saved highlights.
- Selecting multiple and setting the filters for the list of highlights (in HighlightGallery).

[VideoPlayerView.swift](TraceVisionDemo/TraceVisionDemo/views/gallery/VideoPlayerView.swift)

- Using `HighlightVideoPlayer` to play the video from a list of highlights.
- Saving/Exporting the highlight to the camera roll.

Copyright (c) TraceVision, 2024

This demo app code is distributed under the MIT license.

