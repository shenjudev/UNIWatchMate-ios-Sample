//
//  WMFindAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import "WMDeviceFindModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 查找
@interface WMFindAppModel : NSObject<WMSupportProtocol>

/// 手表端查找手机
@property (nonatomic, strong) RACSignal<WMDeviceFindModel *> *findPhone;

/// 手表端停止查找手机
@property (nonatomic, strong) RACSignal<NSNumber *> *closeFindPhone;

/// 手表端停止查找手表
@property (nonatomic, strong) RACSignal<NSNumber *> *closeFindWatch;

/// 关闭查找手表
- (RACSignal<NSNumber *> *)phoneCloseFindWatch;
/// 关闭查找手机
- (RACSignal<NSNumber *> *)phoneCloseFindPhone;
/// 查找手表
/// - Parameter ringNumber: 响铃次数
- (RACSignal<NSNumber *> *)findWatch:(WMDeviceFindModel *)model;

@end

NS_ASSUME_NONNULL_END
