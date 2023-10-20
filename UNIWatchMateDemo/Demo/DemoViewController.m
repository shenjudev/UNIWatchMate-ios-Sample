//
//  DemoViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import "DemoViewController.h"
#import "ScanQRCodeConnectionViewController.h"
#import <CoreTelephony/CTCellularData.h>
#import "AlarmsViewController.h"
#import "AlarmEditViewController.h"
@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self checkNetworkPermission];
    [self goTest];
    [HDWindowLogger hideLogWindow];
    [HDWindowLogger defaultWindowLogger].mCompleteLogOut = NO;
    [HDWindowLogger defaultWindowLogger].mDebugAreaLogOut = NO;
    
    //设置SVProgressHUD属性
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    
}
- (void)checkNetworkPermission {
    NSURL *url = [NSURL URLWithString:@"https://www.example.com"]; // 将 "www.example.com" 替换为你想要加载的域名
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    [dataTask resume];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)goConnectionModeSelectionViewController{
    // 获取应用程序的主Storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // 获取主Storyboard的初始ViewController
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ConnectionModeSelectionViewController"];
    viewController.title = NSLocalizedString(@"Connection mode selection", nil);
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
}

-(void)goScanQRCodeConnectionViewController{
    UIViewController *viewController = [ScanQRCodeConnectionViewController new];
    viewController.title = NSLocalizedString(@"Scan QR code connection", nil);
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
}
-(void)goAlarmsViewController{
    UIViewController *viewController = [AlarmsViewController new];
    viewController.title = NSLocalizedString(@"AlarmsViewController", nil);
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
}
-(void)goEditAlarmsViewController{
    UIViewController *viewController = [AlarmEditViewController new];
    viewController.title = NSLocalizedString(@"AlarmEditViewController", nil);
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
}
-(void)goTest{
    [self  goConnectionModeSelectionViewController];
    //    [self goAlarmsViewController];
    //    [self goAlarmsViewController];
    //    [self goScanQRCodeConnectionViewController];
    //    [self goEditAlarmsViewController];
    
}
@end
