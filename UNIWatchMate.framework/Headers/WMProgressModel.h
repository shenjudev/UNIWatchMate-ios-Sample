//
//  WMProgressModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMProgressModel : NSObject

/// 当前在传输第几个文件
@property (nonatomic, assign) NSInteger index;
/// 文件个数
@property (nonatomic, assign) NSInteger total;
/// 进度（0-100）
@property (nonatomic, assign) double progress;
/// 是否传输成功
@property (nonatomic, assign) BOOL isSuccess;
/// 是否传输失败
@property (nonatomic, assign) BOOL isFail;
/// 当失败时可设置一个Error
@property (nonatomic, strong) NSError * _Nullable error;

@end

NS_ASSUME_NONNULL_END
