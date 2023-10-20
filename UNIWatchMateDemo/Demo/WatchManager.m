//
//  WatchManager.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import "WatchManager.h"

@implementation WatchManager
{
    NSString *_lastConnectedMac; // Declare the instance variable here
}


// 使用静态变量来保存单例实例
static WatchManager *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.current = [RACReplaySubject replaySubjectWithCapacity:1];
        [sharedInstance.current subscribeNext:^(id value) {
            sharedInstance.currentValue = value;
            sharedInstance.cameraAppDelegate = [CameraAppDelegate new];
            sharedInstance.currentValue.apps.cameraApp.delegate = sharedInstance.cameraAppDelegate;
            
        }];
        
        
    });
    return sharedInstance;
}

-(NSString *)lastConnectedMac {
    // 使用 getter 方法从属性中获取值
    _lastConnectedMac = [self retrieveLastConnectedMacFromUserDefaults];
    return _lastConnectedMac;
}

- (void)setLastConnectedMac:(NSString *)macAddress {
    // 使用 setter 方法设置属性的值
    _lastConnectedMac = macAddress;
    
    // 存储到 UserDefaults
    [self saveLastConnectedMacToUserDefaults];
}

- (void)saveLastConnectedMacToUserDefaults {
    // 存储到 UserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_lastConnectedMac forKey:@"LastConnectedMac"];
    [userDefaults synchronize]; // 在iOS 9之前，需要手动调用synchronize方法
}

- (NSString *)retrieveLastConnectedMacFromUserDefaults {
    // 从 UserDefaults 中检索 mac 地址
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *macAddress = [userDefaults objectForKey:@"LastConnectedMac"];
    return macAddress;
}

@end
