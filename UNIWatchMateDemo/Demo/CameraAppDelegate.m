//
//  CameraAppDelegate.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/13.
//

#import "CameraAppDelegate.h"


@implementation CameraAppDelegate


- (void)watchOpenOrCloseCamera:(BOOL)isOpen result:(nonnull void (^)(BOOL))result {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchOpenOrCloseCamera" object:self userInfo:@{@"isOpen":[NSNumber numberWithBool:isOpen],@"result":result}];
}

- (void)watchSwitchCameraCaptureResult:(nonnull void (^)(BOOL))result {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WatchSwitchCameraCaptureResult" object:self userInfo:@{@"result":result}];
    
}

- (void)watchSwitchCameraPosition:(WMCameraPosition)position result:(nonnull void (^)(BOOL))result {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"watchSwitchCameraPosition" object:self userInfo:@{@"position":[NSNumber numberWithInteger:position],@"result":result}];
    
}

- (void)watchSwitchCameraflash:(WMCameraFlashMode)flash result:(nonnull void (^)(BOOL))result {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"watchSwitchCameraflash" object:self userInfo:@{@"flash":[NSNumber numberWithInteger:flash],@"result":result}];
    
}

@end
