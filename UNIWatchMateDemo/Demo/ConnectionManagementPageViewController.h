//
//  ConnectionManagementPageViewController.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectionManagementPageViewController : UIViewController

-(void)connectDeviceByQRCode:(NSString *)qrCode;
-(void)connectDeviceByMac:(NSString *)mac productType:(NSString *)productType;
-(void)connectDeviceBySearchProductType:(NSString *)productType;
@end

NS_ASSUME_NONNULL_END
