//
//  XEncoder.h
//  h264encoder
//
//  Created by wangwenfeng on 2023/7/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface XEncoderResultModel : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) bool isKeyFrame;

@end

@interface XEncoder : NSObject

+ (nonnull instancetype)shareInstance;

- (void *) initEncode:(int)dst_width height:(int)dst_height;
- (void) uninitEncode:(void *)handle;
- (XEncoderResultModel *) encode:(void *)handle yData:(uint8_t *)y_data uData:(uint8_t *)u_data vData:(nullable uint8_t *)v_data srcWidth:(int)src_width srcHeight:(int)src_height orientation:(int)orientation;

@end

NS_ASSUME_NONNULL_END
