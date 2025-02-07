//
//  WMWatchVideoModel.h
//  UNIWatchMate
//
//  Created by abel on 2024/5/8.
//

#ifndef WMWatchVideoModel_h
#define WMWatchVideoModel_h


#endif /* WMWatchVideoModel_h */
#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import <AVFoundation/AVFoundation.h>
#import "WmGlassesMediaCount.h"
#import "WmGlassesStorageInfo.h"


NS_ASSUME_NONNULL_BEGIN
@protocol WMGlassesVideoAppDelegate <NSObject, AVCaptureVideoDataOutputSampleBufferDelegate>

/// 手表端开关录音 （Watch end switch recording）
/// - Parameter isOpen: YES打开录音；（YES Opens record;）
- (void)watchOpenOrCloseRecord:(NSInteger)result ;
/// 手表端开关录像 （Watch end switch video recording）
/// - Parameter isOpen: YES打开录像；（YES Opens record video;）
- (void)watchOpenOrCloseRecordVideo:(NSInteger)result;

/// 手表端开关预览 （Watch end switch preview）
/// - Parameter isOpen: YES打开预览；（YES Openspreview;）
- (void)watchClosePreview:(NSInteger)result;

- (void)watchTakePhoto:(NSInteger)result;

@end

@interface WMGlassesVideoModel : NSObject<WMSupportProtocol>

@property (nonatomic, weak) id<WMGlassesVideoAppDelegate> delegate;


/// 是否支持视频预览 （Whether to support video preview）
- (BOOL)isSupportVideoPreview;

/// 接收手表发送过来的视频 （Receive video from the watch）
- (RACSignal<NSData *> *)monitorVideo;

/// APP打开/关闭相机 （APP Turn on/off the camera）
/// - Parameter isOpen: BOOL 是否打开成功 （Whether successfully opened）
- (RACSignal<NSNumber *> *)startPreviewSet:(BOOL)start;

/// 手机获取设备预览状态 （Phone Gets device preview status）
- (RACSignal<NSNumber *> *)devicePreviewState;

/// APP打开/关闭录音 （APP Turn on/off the record）
/// - Parameter isOpen: BOOL 是否打开成功 （Whether successfully opened）
- (RACSignal<NSNumber *> *)startRecordSet:(BOOL)start;

/// 手机获取设备录音状态 （The mobile phone obtains the recording status of the device）
- (RACSignal<NSNumber *> *)deviceRecordState;

/// APP打开/关闭录像 （APP Turn on/off the record video）
/// - Parameter isOpen: BOOL 是否打开成功 （Whether successfully opened）
- (RACSignal<NSNumber *> *)startRecordVideoSet:(BOOL)start;

/// 手机获取设备录像状态 （The mobile phone obtains the recording status of the device）
- (RACSignal<NSNumber *> *)deviceRecordVideoState;

/// APP请求设备拍照（The APP requests the device to take a photo）
- (RACSignal<NSNumber *> *)deviceTakePhoto;

- (RACSignal<WmGlassesMediaCount *> *)deviceMediaCount;

- (RACSignal<WmGlassesStorageInfo *> *)deviceStoreageInfo;

@end

NS_ASSUME_NONNULL_END
