//
//  WMAlarmAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMAlarmModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMAlarmAppModel : NSObject<WMSupportProtocol>

/// 设备端闹钟列表改变订阅
@property (nonatomic, strong) RACSignal<NSArray<WMAlarmModel*> *> *alarmList;
/// 当前闹钟列表（设备端、APP修改配置成功时更新数据）
@property (nonatomic, strong, readonly) NSArray<WMAlarmModel*> *alarmListValue;
           
/// 同步闹钟列表
- (RACSignal<NSArray<WMAlarmModel*> *> *)syncAlarmList;

/// 删除闹钟
/// - Parameter alarm: 闹钟
- (RACSignal<NSArray<WMAlarmModel*> *> *)deleteAlarm:(NSInteger)alarmId;

/// 添加闹钟（闹钟id可为空，由设备产生）
/// - Parameter alarm: 闹钟
- (RACSignal<NSArray<WMAlarmModel*> *> *)addAlarm:(WMAlarmModel *)alarm;

/// 修改闹钟设置
/// - Parameter alarm: 闹钟
- (RACSignal<NSArray<WMAlarmModel*> *> *)updateAlarm:(WMAlarmModel *)alarm;

@end

NS_ASSUME_NONNULL_END
