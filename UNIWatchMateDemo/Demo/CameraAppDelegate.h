//
//  CameraAppDelegate.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/13.
//

#import <Foundation/Foundation.h>
static NSString * NOTI_watchOpenOrCloseCamera = @"WatchOpenOrCloseCamera";
static NSString * NOTI_WatchSwitchCameraCaptureResult = @"WatchSwitchCameraCaptureResult";
static NSString * NOTI_watchSwitchCameraPosition = @"watchSwitchCameraPosition";
static NSString * NOTI_watchSwitchCameraflash = @"watchSwitchCameraflash";
typedef void (^WatchresultBlock)(BOOL);
NS_ASSUME_NONNULL_BEGIN
@interface CameraAppDelegate : NSObject<WMCameraAppDelegate>

@end

NS_ASSUME_NONNULL_END
