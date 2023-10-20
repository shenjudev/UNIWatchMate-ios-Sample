//
//  WMSettingsModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMSportGoalSettingModel.h"
#import "WMUnitInfoSettingModel.h"
#import "WMPersonalInfoSettingModel.h"
#import "WMLanguageSettingModel.h"
#import "WMReminderSettingModel.h"
#import "WMDateTimeSettingModel.h"
#import "WMSwitchsSettingModel.h"
#import "WMAppViewSettingModel.h"
#import "WMSleepSettingModel.h"
#import "WMMessageSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 功能设置
@interface WMSettingsModel : NSObject

/// 运动目标设置
@property (nonatomic, strong) WMSportGoalSettingModel *sportGoal;
/// 计量单位设置
@property (nonatomic, strong) WMUnitInfoSettingModel *unitInfo;
/// 个人信息设置
@property (nonatomic, strong) WMPersonalInfoSettingModel *personalInfo;
/// 语言设置
@property (nonatomic, strong) WMLanguageSettingModel *language;
/// 喝水提醒设置
@property (nonatomic, strong) WMReminderSettingModel *waterReminder;
/// 久坐提醒设置
@property (nonatomic, strong) WMReminderSettingModel *sedentaryReminder;
/// 时间设置
@property (nonatomic, strong) WMDateTimeSettingModel *dateTime;
/// 开关设置
@property (nonatomic, strong) WMSwitchsSettingModel *switchs;
/// app视图设置
@property (nonatomic, strong) WMAppViewSettingModel *appView;
/// 睡眠设置
@property (nonatomic, strong) WMSleepSettingModel *sleep;
/// 消息设置
@property (nonatomic, strong) WMMessageSettingModel *message;

@end

NS_ASSUME_NONNULL_END
