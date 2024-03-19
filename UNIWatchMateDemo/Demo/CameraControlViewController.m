//
//  CameraControlViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/24.
//

#import "CameraControlViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
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
   
    if(_openFromDevice){
        @weakify(self);
//        [[[WatchManager sharedInstance].currentValue.apps.cameraApp configFlash:self.currentFlashMode == AVCaptureFlashModeOn ? WMCameraFlashModeOn:WMCameraFlashModeOff] subscribeNext:^(NSNumber * _Nullable x) {
//
//        } error:^(NSError * _Nullable error) {
//            NSLog(@"configFlash error");
//
//        }];
        [[[WatchManager sharedInstance].currentValue.apps.cameraApp videoPreviewBegin] subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            NSLog(@"videoPreviewBegin success");
        } error:^(NSError * _Nullable error) {
            NSLog(@"videoPreviewBegin error");
        }];
    }else{
        @weakify(self);
        [[[WatchManager sharedInstance].currentValue.apps.cameraApp openOrCloseCamera:YES] subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            NSLog(@"openOrCloseCamera YES success");
            BOOL isOpen = [x boolValue];
            [[[WatchManager sharedInstance].currentValue.apps.cameraApp configFlash:self.currentFlashMode == AVCaptureFlashModeOn ? WMCameraFlashModeOn:WMCameraFlashModeOff] subscribeNext:^(NSNumber * _Nullable x) {
                
            } error:^(NSError * _Nullable error) {
                NSLog(@"configFlash error");

            }];
            [[[WatchManager sharedInstance].currentValue.apps.cameraApp videoPreviewBegin] subscribeNext:^(NSNumber * _Nullable x) {
                NSLog(@"videoPreviewBegin success");
            } error:^(NSError * _Nullable error) {
                NSLog(@"videoPreviewBegin error");
            }];
        } error:^(NSError * _Nullable error) {
            NSLog(@"openOrCloseCamera YES error");

        }];
    }

}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[WatchManager sharedInstance].currentValue.apps.cameraApp videoPreviewEnd];
    [[[WatchManager sharedInstance].currentValue.apps.cameraApp openOrCloseCamera:NO] subscribeNext:^(NSNumber * _Nullable x) {} error:^(NSError * _Nullable error) {}];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Camera Control",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
    self.currentFlashMode = photoSettings.flashMode;
    
    // Create and configure AVCaptureSession
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // Create AVCaptureDeviceInput to get the camera input
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.currentCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
    if (!error && [self.captureSession canAddInput:self.currentCameraInput]) {
        [self.captureSession addInput:self.currentCameraInput];
    }
    
    // Create an AVCapturePhotoOutput to process the photo
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [self.captureSession addOutput:output];
    // Create a preview layer and add it to the view
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
    
    // Create photo button
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.frame = CGRectMake(self.view.frame.size.width / 2 - 40, self.view.frame.size.height - 100, 80, 80);
    [self.captureButton setImage: [UIImage imageNamed:@"ic_camera_tack"] forState:UIControlStateNormal];
    //    self.captureButton.backgroundColor = [UIColor whiteColor];
    self.captureButton.layer.masksToBounds = YES;
    self.captureButton.layer.cornerRadius = 40;
    //    self.captureButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.captureButton.layer.borderWidth = 2;
    [self.view addSubview:self.captureButton];
    
    // Create front and rear camera toggle buttons
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchCameraButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 150, 140, 40, 40);
    [self.switchCameraButton setImage:[UIImage imageNamed:@"ic_camera_switch"] forState:UIControlStateNormal];
    //    self.switchCameraButton.backgroundColor = [UIColor whiteColor];
    self.switchCameraButton.layer.masksToBounds = YES;
    self.switchCameraButton.layer.cornerRadius = 20;
    //    self.switchCameraButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.switchCameraButton.layer.borderWidth = 2;
    [self.view addSubview:self.switchCameraButton];
    
    // Create flash control buttons
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 100, 140, 40, 40);
    [self.flashButton setImage:self.currentFlashMode == AVCaptureFlashModeOn ? [UIImage imageNamed:@"ic_bolt_circle_fill"] : [UIImage imageNamed:@"ic_bolt_slash_fill"] forState:UIControlStateNormal];
    //    self.flashButton.backgroundColor = [UIColor whiteColor];
    self.flashButton.layer.masksToBounds = YES;
    self.flashButton.layer.cornerRadius = 20;
    //    self.flashButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.flashButton.layer.borderWidth = 2;
    [self.view addSubview:self.flashButton];
    
    // Create Select Photo button
    self.selectPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectPhotoButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 50, 140, 40, 40);
    //    self.selectPhotoButton.backgroundColor = [UIColor whiteColor];
    self.selectPhotoButton.layer.masksToBounds = YES;
    self.selectPhotoButton.layer.cornerRadius = 20;
    //    self.selectPhotoButton.layer.borderColor = [UIColor blueColor].CGColor;
    //    self.selectPhotoButton.layer.borderWidth = 2;
    [self.selectPhotoButton setHidden:YES];
    [self.view addSubview:self.selectPhotoButton];
    
    // Add button click event handling
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
       
        WatchresultBlock resultBlock = noti.userInfo[@"result"];
        if (resultBlock) {
            resultBlock(YES);
        }
        if (isOpen == YES){
        }else{
            [self.navigationController popViewControllerAnimated:true];

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
    // Handle photo button click events
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
    photoSettings.flashMode = self.currentFlashMode;
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
}

- (void)switchCameraButtonTapped {
    // Handle front and rear camera switch button click event
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
    // Handle front and rear camera switch button click event
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
    // Handle select photo button click event
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

// Realize the proxy method after the photo is taken
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (error) {
        // Processing photo error
        return;
    }
    
    // Get photo data taken
    NSData *imageData = [photo fileDataRepresentation];
    UIImage *capturedImage = [UIImage imageWithData:imageData];
    
    self.imageView.image = capturedImage;
    [self.imageView setHidden:NO];
    //Disappear after 1s
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imageView setHidden:YES];
    });
    
    // Handle the actions taken after the photo is taken, such as displaying the photo or saving it to an album
if(imageData) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetCreationRequest creationRequestForAssetFromImage:[UIImage imageWithData:imageData]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"Photo has been successfully saved to the album.");
        } else {
            NSLog(@"Error saving photo: %@", error);
        }
    }];
}
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
