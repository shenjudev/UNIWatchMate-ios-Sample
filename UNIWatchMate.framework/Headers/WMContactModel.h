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

/// 联系人ID
@property (nonatomic, assign) int identifier;
/// 联系人名称
@property (nonatomic, copy) NSString *name;
/// 电话号码
@property (nonatomic, copy) NSString *number;

@end

NS_ASSUME_NONNULL_END
