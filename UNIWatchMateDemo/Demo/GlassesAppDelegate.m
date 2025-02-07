//
//  CameraAppDelegate.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/13.
//

#import "GlassesAppDelegate.h"

@implementation GlassesAppDelegate

- (void)watchClosePreview:(NSInteger)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_watchClosePreview object:self userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
}

- (void)watchOpenOrCloseRecord:(NSInteger)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_watchOpenOrCloseRecord object:self userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
}

- (void)watchOpenOrCloseRecordVideo:(NSInteger)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_watchOpenOrCloseRecordVideo object:self userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
}

- (void)watchTakePhoto:(NSInteger)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_watchTakePhoto object:self userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
}

@end
