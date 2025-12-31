//
//  WMPhotoLibrary.h
//  UNIWatchMate
//
//  Created by abel on 2025/5/7.
//
#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WMPhotoLibraryAppDelegate <NSObject, AVCaptureVideoDataOutputSampleBufferDelegate>

/// 无存储方案，设备拍照，向手机发送照片分片数量 （No storage solution, device takes photos, number of photo fragments sent to the mobile phone）
/// Parameter elementCount: 照片分片数量 （Number of photo fragments）
- (void)deviceTakePhotoElementCount:(NSInteger)elementCount;

@end



@interface WMPhotoLibrary : NSObject<WMSupportProtocol>


@property (nonatomic, weak) id<WMPhotoLibraryAppDelegate> delegate;

/// APP请求设备 照片名称（设备不进入 "等待发送图片状态"） （APP Turn on/off the record）
/// result 照片列表
- (RACSignal<NSNumber *> *)getOnlyDevicePhotoNamesCount;

/// APP请求设备 发送 照片名称 （APP Turn on/off the record）
/// result 0 : 成功1：失败2：设备正忙
- (RACSignal<NSNumber *> *)letDeviceSendFileNames;

///APP请求设备传输照片（APP Turn on/off the camera）
///result:    0 : 成功1：失败2：设备正忙
- (RACSignal<NSNumber *> *)letDeviceSendPhoto:(NSInteger)index;

///APP请求设备照片分片数量，由于图片太大，需要分片接收（APP Turn on/off the camera）
///result:    0 : 成功1：失败2：设备正忙
- (RACSignal<NSNumber *> *)getDevicePhotoElementCount:(NSString *)photoName;

/// APP请求设备删除照片（APP Turn on/off the camera）
///result:    0 : 成功1：失败2：设备正忙
- (RACSignal<NSNumber *> *)letDeviceDeletePhoto:(NSArray<NSString *> *)photoName;

/// APP请求结束"等待发送图片状态" （APP Turn on/off the record）
/// result 0 : 成功1：失败2：设备正忙
- (RACSignal<NSNumber *> *)letDeviceEndReceiveState;
@end

NS_ASSUME_NONNULL_END
