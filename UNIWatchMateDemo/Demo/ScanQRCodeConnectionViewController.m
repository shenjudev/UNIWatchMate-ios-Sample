//
//  ScanQRCodeConnectionViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import "ScanQRCodeConnectionViewController.h"
#import <LBXScan/LBXScanViewController.h>
#import <LBXScan/LBXScanView.h>
#import "ConnectionManagementPageViewController.h"
@interface ScanQRCodeConnectionViewController () <LBXScanViewControllerDelegate>
@property(nonatomic,strong) LBXScanViewController *scanVC;
@end

@implementation ScanQRCodeConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self startScanQRCode];
}

- (void)startScanQRCode {
    if (self.scanVC != nil){
        self.scanVC = nil;
    }
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc] init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    style.isNeedShowRetangle = YES;
    
    _scanVC = [[LBXScanViewController alloc] init];
    self.scanVC.style = style;
    self.scanVC.isOpenInterestRect = YES;
    self.scanVC.delegate = self;
    self.scanVC.view.frame = self.view.bounds;
    [self addChildViewController:self.scanVC];
    [self.view addSubview:self.scanVC.view];
}

#pragma mark - LBXScanViewControllerDelegate

- (void)scanResultWithArray:(NSArray<LBXScanResult *> *)array {
    XLOG_INFO(@"扫描结果：%@", array);
    
    // 处理扫描结果，例如显示在界面上或执行其他操作
    LBXScanResult * first = [array firstObject];
    XLOG_INFO(@"扫描结果：%@", first.strScanned);
    [self goConnectionManagementPage:first.strScanned];
    //延迟3秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startScanQRCode];
    });
}
-(void)goConnectionManagementPage:(NSString *)QRCode{
    ConnectionManagementPageViewController *connectionManagementPageViewController = [ConnectionManagementPageViewController new];
    [connectionManagementPageViewController connectDeviceByQRCode:QRCode];
    connectionManagementPageViewController.title = NSLocalizedString(@"Connection management page", nil);
    [self.navigationController pushViewController:connectionManagementPageViewController animated:true];
}

@end
