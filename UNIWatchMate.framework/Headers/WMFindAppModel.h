//
//  WMFindAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 查找
@interface WMFindAppModel : NSObject<WMSupportProtocol>

/// 手表端关闭查找手表
@property (nonatomic, strong) RACSignal<NSNumber *> *findWatchClose;
@property (nonatomic, assign, readonly) BOOL findWatchCloseValue;

/// 手表端关闭查找手机
@property (nonatomic, strong) RACSignal<NSNumber *> *findPhoneClose;
@property (nonatomic, assign, readonly) BOOL findPhoneCloseValue;

/// 关闭查找手表
- (RACSignal<NSNumber *> *)closeFindWatch;
/// 关闭查找手机
- (RACSignal<NSNumber *> *)closeFindPhone;
/// 查找手表
/// - Parameter ringNumber: 响铃次数
- (RACSignal<NSNumber *> *)closeFindWatch:(int)ringNumber;

@end

NS_ASSUME_NONNULL_END
