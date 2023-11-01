//
//  WMDialAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMDialModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMDialAppModel : NSObject<WMSupportProtocol>

/// 设备端更新表盘列表
@property (nonatomic, strong) RACSignal<NSArray<WMDialModel*> *> *dialList;

/// 当前表盘列表（设备端、APP修改配置成功时更新数据）
@property (nonatomic, strong, readonly) NSArray<WMDialModel*> *dialListValue;

/// 获取表盘列表
- (RACSignal<NSArray<WMDialModel*> *> *)syncDialList;

/// 删除表盘
/// - Parameter dial: 表盘
- (RACSignal<NSArray<WMDialModel*> *> *)deleteDial:(WMDialModel *)dial;

@end

NS_ASSUME_NONNULL_END
