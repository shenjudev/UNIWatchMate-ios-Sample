
# UNIWatchMate

The interface framework of UNIWatchMate smartwatch is responsible for packaging functions such as communication with the glasses device. It provides interfaces related to the smartGlasses for the App to operate, and connects to SDKS of other watches.
  
# [Wiki](https://github.com/shenjudev/UNIWatchMate-ios-Sample/wiki)  
# Version 1.0.1

## v1.0.1(2025-02-07)
1.Bind and unbind the device
2.Obtain the number of media
3.Obtain storage information
4.Device Configuration (language)
5.Basic device information Step
6.Preview
7.AI dialogue picture, audio (pcm) data Step
8.Take pictures
9.Video
10.Recording
11.Other functions (local ota, restart, disconnection)

## Note
1 For the use of the new interface for the Glasses project, refer to item 8 of the Wiki
2 By calling startPreviewSet, startRecordSet, startRecordVideoSet, DeviceTakePhoto method so as to obtain the result just got command equipment is normal, the real results of WMGlassesVideoAppDelegate method through the equipment send to the APP
