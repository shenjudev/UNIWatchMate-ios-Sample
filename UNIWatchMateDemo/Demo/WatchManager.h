//
//  WatchManager.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import <Foundation/Foundation.h>
#import "CameraAppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface WatchManager : NSObject

@property (nonatomic, strong) RACReplaySubject<WMPeripheral *> *current;
@property (nonatomic, strong) WMPeripheral * currentValue;
@property (nonatomic, strong) NSString *lastConnectedMac;
@property (nonatomic, strong) CameraAppDelegate *cameraAppDelegate;
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
