//
//  AlarmEditViewController.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlarmEditViewController : UIViewController
@property (nonatomic, strong) WMAlarmModel *alarmModel;
@property (nonatomic, strong) NSMutableArray<WMAlarmModel *> *alarmModels;
@property (copy, nonatomic) void (^completionHandler)(NSString *data);

@end

NS_ASSUME_NONNULL_END
