//
//  WMAppViewModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WMAppViewType) {
    //瀑布流
    WMAppViewTypeWATERFALL = 0,
    //列表
    WMAppViewTypeLIST,
    //满天星
    WMAppViewTypeSTAR,
    //九宫格
    WMAppViewTypeNINE_GRID,
};

/// app视图设置
@interface WMAppViewModel : NSObject

/// 当前视图
@property (nonatomic, assign) WMAppViewType current;

/// 支持的视图列表（WMAppViewType）
- (NSArray<NSNumber *> *)views;

@end

NS_ASSUME_NONNULL_END
