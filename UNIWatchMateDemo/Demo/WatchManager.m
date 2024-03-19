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


// Use static variables to hold singleton instances
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
   
    _lastConnectedMac = [self retrieveLastConnectedMacFromUserDefaults];
    return _lastConnectedMac;
}

- (void)setLastConnectedMac:(NSString *)macAddress {
   
    _lastConnectedMac = macAddress;
    
    
    [self saveLastConnectedMacToUserDefaults];
}

- (void)saveLastConnectedMacToUserDefaults {
    // Store in UserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_lastConnectedMac forKey:@"LastConnectedMac"];
    [userDefaults synchronize]; // Prior to iOS 9, you needed to manually invoke the synchronize method
}

- (NSString *)retrieveLastConnectedMacFromUserDefaults {
    // Retrieves mac addresses from UserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *macAddress = [userDefaults objectForKey:@"LastConnectedMac"];
    return macAddress;
}

@end
