//
//  DialModel.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DialModel : NSObject
@property(nonatomic,strong)WMDialModel *model;
@property(nonatomic,strong)NSString *image;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,assign)BOOL canInstall;
@end

NS_ASSUME_NONNULL_END
