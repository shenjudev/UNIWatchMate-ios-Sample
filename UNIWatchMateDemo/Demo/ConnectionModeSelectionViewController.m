//
//  ConnectionModeSelectionViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import "ConnectionModeSelectionViewController.h"
#import "ScanQRCodeConnectionViewController.h"
#import "ConnectionManagementPageViewController.h"
@interface ConnectionModeSelectionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *macLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ConnectionModeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *lastConnectedMac = [WatchManager sharedInstance].lastConnectedMac;
    if (lastConnectedMac == nil){
        lastConnectedMac = @"";
    }
    self.macLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"mac:", nil), lastConnectedMac];
    NSString *logMessage = NSLocalizedString(@"You can browse the logs by opening http://%@:%d in your PC browser.\nNote: The phone and PC are on the same network.",nil);
    NSString *formattedMessage = [NSString stringWithFormat:logMessage, GCDTCPServerGetPrimaryIPAddress(false), 8080];
    
    self.detailLabel.text = formattedMessage;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 获取发布版本号
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // 获取构建版本号
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *fullVersion = [NSString stringWithFormat:@"version:%@(%@)", shortVersion, buildVersion];
    
    NSLog(@"App Short Version: %@", shortVersion);
    NSLog(@"App Build Version: %@", buildVersion);
    
    self.versionLabel.text = fullVersion;
    //    NSString *lastConnectedMac = [WatchManager sharedInstance].lastConnectedMac;
    if (lastConnectedMac == nil){
        lastConnectedMac = @"";
    }
    if (lastConnectedMac == nil || [lastConnectedMac length] == 0){
        return;
    }
    
    BOOL isUserLoggedIn = [defaults boolForKey:shouldAutoReconnect];
    if (isUserLoggedIn) {
        XLOG_INFO(@"通过mac地址回连");
        [SVProgressHUD showInfoWithStatus:  NSLocalizedString(@"通过mac地址回连", nil)];
        [self connectDeviceByMac: lastConnectedMac];
    }
}

//- (void)viewDidAppear:(BOOL)animated {
//    XLOG_INFO(@"通过mac地址回连");
//    NSString *lastConnectedMac = [WatchManager sharedInstance].lastConnectedMac;
//    if (lastConnectedMac == nil){
//        lastConnectedMac = @"";
//    }
//    if (lastConnectedMac == nil || [lastConnectedMac length] == 0){
//        return;
//    }
//    [SVProgressHUD showInfoWithStatus:  NSLocalizedString(@"通过mac地址回连", nil)];
//    [self connectDeviceByMac: lastConnectedMac];
//
//}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)actionSearch:(id)sender {
    
    ConnectionManagementPageViewController *connectionManagementPageViewController = [ConnectionManagementPageViewController new];
    [connectionManagementPageViewController connectDeviceBySearchProductType:@""];
    connectionManagementPageViewController.title = NSLocalizedString(@"Connection management page", nil);
    [self.navigationController pushViewController:connectionManagementPageViewController animated:true];
}

- (IBAction)actionScan:(id)sender {
    //    UIViewController *viewController = [ScanQRCodeConnectionViewController new];
    //    viewController.title = NSLocalizedString(@"Scan QR code connection", nil);
    //    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)actionByMac:(id)sender {
    
    NSString *lastConnectedMac = [WatchManager sharedInstance].lastConnectedMac;
    if (lastConnectedMac == nil || [lastConnectedMac length] == 0){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Last connected mac is nil.", nil)];
        return;
    }
    [self connectDeviceByMac:lastConnectedMac];
}

- (void)connectDeviceByMac:(NSString *)lastConnectedMac{
    ConnectionManagementPageViewController *connectionManagementPageViewController = [ConnectionManagementPageViewController new];
    [connectionManagementPageViewController connectDeviceByMac:lastConnectedMac productType:@"OSW-802N"];
    connectionManagementPageViewController.title = NSLocalizedString(@"Connection management page", nil);
    [self.navigationController pushViewController:connectionManagementPageViewController animated:true];
}

@end
