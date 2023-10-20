//
//  CameraControlViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/24.
//

#import "CameraControlViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraControlViewController () <AVCapturePhotoCaptureDelegate,WMCameraAppDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *currentCameraInput;
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *selectPhotoButton;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, assign) AVCaptureFlashMode currentFlashMode;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CameraControlViewController
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.apps.cameraApp openOrCloseCamera:YES] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        BOOL isOpen = [x boolValue];
        [[[WatchManager sharedInstance].currentValue.apps.cameraApp configFlash:self.currentFlashMode == AVCaptureFlashModeOn ? WMCameraFlashModeOn:WMCameraFlashModeOff] subscribeNext:^(NSNumber * _Nullable x) {} error:^(NSError * _Nullable error) {}];
        [[[WatchManager sharedInstance].currentValue.apps.cameraApp videoPreviewBegin] subscribeNext:^(NSNumber * _Nullable x) {} error:^(NSError * _Nullable error) {}];
    } error:^(NSError * _Nullable error) {
        
    }];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[WatchManager sharedInstance].currentValue.apps.cameraApp videoPreviewEnd];
    [[[WatchManager sharedInstance].currentValue.apps.cameraApp openOrCloseCamera:NO] subscribeNext:^(NSNumber * _Nullable x) {} error:^(NSError * _Nullable error) {}];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
    self.currentFlashMode = photoSettings.flashMode;
    
    // 创建并配置 AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // 创建 AVCaptureDeviceInput 来获取摄像头输入
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.currentCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
    if (!error && [self.captureSession canAddInput:self.currentCameraInput]) {
        [self.captureSession addInput:self.currentCameraInput];
    }
    
    // 创建 AVCapturePhotoOutput 来处理拍照
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [self.captureSession addOutput:output];
    // 创建预览图层并添加到视图
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 40;
    self.imageView.layer.borderColor = [UIColor redColor].CGColor;
    self.imageView.layer.borderWidth = 10;
    [self.imageView setHidden:YES];
    
    // 创建拍照按钮
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.frame = CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height - 100, 80, 80);
    [self.captureButton setImage: [UIImage imageNamed:@"ic_camera_tack"] forState:UIControlStateNormal];
    //    self.captureButton.backgroundColor = [UIColor whiteColor];
    self.captureButton.layer.masksToBounds = YES;
    self.captureButton.layer.cornerRadius = 40;
    //    self.captureButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.captureButton.layer.borderWidth = 2;
    [self.view addSubview:self.captureButton];
    
    // 创建前后摄像头切换按钮
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchCameraButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 150, 140, 40, 40);
    [self.switchCameraButton setImage:[UIImage imageNamed:@"ic_camera_switch"] forState:UIControlStateNormal];
    //    self.switchCameraButton.backgroundColor = [UIColor whiteColor];
    self.switchCameraButton.layer.masksToBounds = YES;
    self.switchCameraButton.layer.cornerRadius = 20;
    //    self.switchCameraButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.switchCameraButton.layer.borderWidth = 2;
    [self.view addSubview:self.switchCameraButton];
    
    // 创建闪光灯控制按钮
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 100, 140, 40, 40);
    [self.flashButton setImage:self.currentFlashMode == AVCaptureFlashModeOn ? [UIImage imageNamed:@"ic_bolt_circle_fill"] : [UIImage imageNamed:@"ic_bolt_slash_fill"] forState:UIControlStateNormal];
    //    self.flashButton.backgroundColor = [UIColor whiteColor];
    self.flashButton.layer.masksToBounds = YES;
    self.flashButton.layer.cornerRadius = 20;
    //    self.flashButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.flashButton.layer.borderWidth = 2;
    [self.view addSubview:self.flashButton];
    
    // 创建选择照片按钮
    self.selectPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectPhotoButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 50, 140, 40, 40);
    //    self.selectPhotoButton.backgroundColor = [UIColor whiteColor];
    self.selectPhotoButton.layer.masksToBounds = YES;
    self.selectPhotoButton.layer.cornerRadius = 20;
    //    self.selectPhotoButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.selectPhotoButton.layer.borderWidth = 2;
    [self.selectPhotoButton setHidden:YES];
    [self.view addSubview:self.selectPhotoButton];
    
    // 添加按钮点击事件处理
    [self.captureButton addTarget:self action:@selector(captureButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.switchCameraButton addTarget:self action:@selector(switchCameraButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.flashButton addTarget:self action:@selector(flashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.selectPhotoButton addTarget:self action:@selector(selectPhotoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiWatchOpenOrCloseCamera:) name:NOTI_watchOpenOrCloseCamera object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiWatchSwitchCameraCaptureResult:) name:NOTI_WatchSwitchCameraCaptureResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiWatchSwitchCameraPosition:) name:NOTI_watchSwitchCameraPosition object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiWatchSwitchCameraflash:) name:NOTI_watchSwitchCameraflash object:nil];
    
}

-(void)notiWatchOpenOrCloseCamera:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo!= nil){
        BOOL isOpen = [userInfo[@"isOpen"] boolValue];
        if (isOpen == YES){
        }
        WatchresultBlock resultBlock = noti.userInfo[@"result"];
        if (resultBlock) {
            resultBlock(YES);
        }
    }
    
}
-(void)notiWatchSwitchCameraCaptureResult:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo!= nil){
        [self captureButtonTapped];
        WatchresultBlock resultBlock = noti.userInfo[@"result"];
        if (resultBlock) {
            resultBlock(YES);
        }
    }
    
}
-(void)notiWatchSwitchCameraPosition:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo!= nil){
        WMCameraPosition position = [userInfo[@"position"] intValue];
        switch (position) {
            case WMCameraPositionFront:
                [self switchCamera:AVCaptureDevicePositionFront];
                break;
                
            case WMCameraPositionRear:
                [self switchCamera:AVCaptureDevicePositionBack];
                break;
        }
        WatchresultBlock resultBlock = noti.userInfo[@"result"];
        if (resultBlock) {
            resultBlock(YES);
        }
    }
    
}
-(void)notiWatchSwitchCameraflash:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo!= nil){
        WMCameraFlashMode flash = [userInfo[@"flash"] intValue];
        switch (flash) {
            case WMCameraFlashModeOn:
                [self changeFlashTo:WMCameraFlashModeOn];
                break;
                
            case WMCameraFlashModeOff:
                [self changeFlashTo:WMCameraFlashModeOff];
                break;
            default:
                break;
        }
        WatchresultBlock resultBlock = noti.userInfo[@"result"];
        if (resultBlock) {
            resultBlock(YES);
        }
    }
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)captureButtonTapped {
    // 处理拍照按钮点击事件
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
    photoSettings.flashMode = self.currentFlashMode;
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
}

- (void)switchCameraButtonTapped {
    // 处理前后摄像头切换按钮点击事件
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    
    if (self.currentCameraInput.device.position == AVCaptureDevicePositionBack) {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        [self changePosition:@0];
    } else {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        [self changePosition:@1];
    }
    
    NSError *error = nil;
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
    
    if (!error) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.currentCameraInput];
        
        if ([self.captureSession canAddInput:newInput]) {
            [self.captureSession addInput:newInput];
            self.currentCameraInput = newInput;
        } else {
            [self.captureSession addInput:self.currentCameraInput];
        }
        
        [self.captureSession commitConfiguration];
    }
    
}
- (void)switchCamera:(AVCaptureDevicePosition)captureDevicePosition{
    // 处理前后摄像头切换按钮点击事件
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    
    newCamera = [self cameraWithPosition:captureDevicePosition];
    NSError *error = nil;
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
    
    if (!error) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.currentCameraInput];
        
        if ([self.captureSession canAddInput:newInput]) {
            [self.captureSession addInput:newInput];
            self.currentCameraInput = newInput;
        } else {
            [self.captureSession addInput:self.currentCameraInput];
        }
        
        [self.captureSession commitConfiguration];
    }
    
}
- (void)flashButtonTapped {
    NSString *imageName = @"ic_bolt_slash_fill";
    WMCameraFlashMode wMCameraFlashMode = WMCameraFlashModeOff;
    switch (self.currentFlashMode) {
        case AVCaptureFlashModeOff:
            self.currentFlashMode = AVCaptureFlashModeOn;
            wMCameraFlashMode = WMCameraFlashModeOn;
            imageName = @"ic_bolt_circle_fill";
            break;
        default:
            self.currentFlashMode = AVCaptureFlashModeOff;
            wMCameraFlashMode = WMCameraFlashModeOff;
            imageName = @"ic_bolt_slash_fill";
            break;
    }
    [self.flashButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [[[WatchManager sharedInstance].currentValue.apps.cameraApp configFlash:wMCameraFlashMode] subscribeNext:^(NSNumber * _Nullable x) {} error:^(NSError * _Nullable error) {}];
}
- (void)changeFlashTo:(WMCameraFlashMode)cameraFlashMode {
    NSString *imageName = @"ic_bolt_slash_fill";
    WMCameraFlashMode wMCameraFlashMode = WMCameraFlashModeOff;
    switch (self.currentFlashMode) {
        case AVCaptureFlashModeOff:
            self.currentFlashMode = AVCaptureFlashModeOn;
            wMCameraFlashMode = WMCameraFlashModeOn;
            imageName = @"ic_bolt_circle_fill";
            break;
        default:
            self.currentFlashMode = AVCaptureFlashModeOff;
            wMCameraFlashMode = WMCameraFlashModeOff;
            imageName = @"ic_bolt_slash_fill";
            break;
    }
    [self.flashButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}








- (void)selectPhotoButtonTapped {
    // 处理选择照片按钮点击事件
    // ...
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [[WatchManager sharedInstance].currentValue.apps.cameraApp sendVideo:sampleBuffer CameraPosition:self.currentCameraInput.device.position == AVCaptureDevicePositionBack];
}

// 实现拍照完成后的代理方法
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (error) {
        // 处理拍照错误
        return;
    }
    
    // 获取拍摄的照片数据
    NSData *imageData = [photo fileDataRepresentation];
    UIImage *capturedImage = [UIImage imageWithData:imageData];
    
    self.imageView.image = capturedImage;
    [self.imageView setHidden:NO];
    //1s后消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imageView setHidden:YES];
    });
    // 处理拍照完成后的操作，例如展示照片或保存到相册
    // ...
}
-(void)changePosition:(NSNumber *)position{
    [[[WatchManager sharedInstance].currentValue.apps.cameraApp configPosition:position] subscribeNext:^(NSNumber * _Nullable x) {
    } error:^(NSError * _Nullable error) {
        
    }];
}


// MARK: - WMCameraAppDelegate
- (void)watchOpenOrCloseCamera:(BOOL)isOpen result:(nonnull void (^)(BOOL))result {
    result(true);
}

- (void)watchSwitchCameraCaptureResult:(nonnull void (^)(BOOL))result {
    result(true);
}

- (void)watchSwitchCameraPosition:(WMCameraPosition)position result:(nonnull void (^)(BOOL))result {
    
}

- (void)watchSwitchCameraflash:(WMCameraFlashMode)flash result:(nonnull void (^)(BOOL))result {
    
}


@end
