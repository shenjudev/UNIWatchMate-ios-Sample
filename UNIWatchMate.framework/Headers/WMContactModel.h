//
//  WMContactModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 联系人
@interface WMContactModel : NSObject
/// 联系人名称
@property (nonatomic, copy) NSString *name;
/// 电话号码
@property (nonatomic, copy) NSString *number;

@end

/// 紧急联系人
@interface WMEmergencyContactModel : NSObject
/// 是否启用紧急联系人
@property (nonatomic, assign) BOOL isEnable;
/// 联系人
@property (nonatomic, strong) WMContactModel *model;

@end

NS_ASSUME_NONNULL_END
