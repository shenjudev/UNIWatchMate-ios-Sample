//
//  WMCameraAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMCameraPosition) {
    WMCameraPositionFront = 0,   /// 前置摄像头
    WMCameraPositionRear     /// 后置摄像头
};

typedef NS_ENUM(NSInteger, WMCameraFlashMode) {
    WMCameraFlashModeOn = 0,     /// 闪光灯开启
    WMCameraFlashModeOff,    /// 闪光灯关闭
    WMCameraFlashModeAuto    /// 闪光灯自动
};

@protocol WMCameraAppDelegate <NSObject, AVCaptureVideoDataOutputSampleBufferDelegate>

/// 手表端开关相机
/// - Parameter isOpen: YES打开相机；
/// - Parameter result: 否执行成功 
- (void)watchOpenOrCloseCamera:(BOOL)isOpen result:(void(^)(BOOL))result;

/// 手表端切换摄像头
/// - Parameter position: WMCameraPosition；
/// - Parameter result: 否执行成功
- (void)watchSwitchCameraPosition:(WMCameraPosition)position result:(void(^)(BOOL))result;

/// 手表端切换闪光灯
/// - Parameter flash: WMCameraFlashMode；
/// - Parameter result: 否执行成功
- (void)watchSwitchCameraflash:(WMCameraFlashMode)flash result:(void(^)(BOOL))result;

/// 手表端点击拍照；
/// - Parameter result: 否执行成功
- (void)watchSwitchCameraCaptureResult:(void(^)(BOOL))result;

@end

@interface WMCameraAppModel : NSObject<WMSupportProtocol>

/// 手表端控制相机代理，需要实现
@property (nonatomic, weak) id<WMCameraAppDelegate> delegate;

/// APP切换摄像头
/// - Parameter position: WMCameraPosition
- (RACSignal<NSNumber *> *)configPosition:(WMCameraPosition)position;

/// APP切换闪光灯
/// - Parameter flash: WMCameraFlashMode
- (RACSignal<NSNumber *> *)configFlash:(WMCameraFlashMode)flash;

/// APP打开/关闭相机
/// - Parameter isOpen: BOOL 是否打开成功
- (RACSignal<NSNumber *> *)openOrCloseCamera:(BOOL)isOpen;

/// 是否支持视频预览
- (BOOL)isSupportVideoPreview;

/// 开启视频预览，（视频预览前需要先打开相机）; 停止/不允许时回调Error
- (RACSignal<NSNumber *> *)videoPreviewBegin;

/// 发送视频数据给设备
/// - Parameters:
///   - buffer: AVCaptureVideoDataOutputSampleBufferDelegate， 视频数据回调
///   - isBack: 是否为后置摄像
- (void)sendVideo:(CMSampleBufferRef)buffer CameraPosition:(BOOL)isBack;

/// 关闭视频预览
- (void)videoPreviewEnd;

@end

NS_ASSUME_NONNULL_END
