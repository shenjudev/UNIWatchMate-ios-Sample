//
//  WMLanguageModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 语言设置
@interface WMLanguageModel : NSObject

/// 当前语言（BCP）
@property (nonatomic, copy) NSString *language;


/// 支持的语言列表（BCP）
- (NSArray<NSString *> *)languages;

@end

NS_ASSUME_NONNULL_END
