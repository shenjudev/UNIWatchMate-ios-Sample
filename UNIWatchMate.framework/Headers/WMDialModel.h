//
//  WMDialModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 表盘
@interface WMDialModel : NSObject

/// 表盘ID
@property (nonatomic, copy) NSString *identifier;
/// 是否内置
@property (nonatomic, assign) BOOL isBuiltIn;

@end

NS_ASSUME_NONNULL_END
