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
}

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
    [connectionManagementPageViewController connectDeviceBySearchProductType:@"OSW-802N"];
    connectionManagementPageViewController.title = NSLocalizedString(@"Connection management page", nil);
    [self.navigationController pushViewController:connectionManagementPageViewController animated:true];
}
- (IBAction)actionScan:(id)sender {
    UIViewController *viewController = [ScanQRCodeConnectionViewController new];
    viewController.title = NSLocalizedString(@"Scan QR code connection", nil);
    [self.navigationController pushViewController:viewController animated:true];
}
- (IBAction)actionByMac:(id)sender {
    
    NSString *lastConnectedMac = [WatchManager sharedInstance].lastConnectedMac;
    if (lastConnectedMac == nil || [lastConnectedMac length] == 0){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Last connected mac is nil.", nil)];
        return;
    }
    ConnectionManagementPageViewController *connectionManagementPageViewController = [ConnectionManagementPageViewController new];
    [connectionManagementPageViewController connectDeviceByMac:lastConnectedMac productType:@"OSW-802N"];
    connectionManagementPageViewController.title = NSLocalizedString(@"Connection management page", nil);
    [self.navigationController pushViewController:connectionManagementPageViewController animated:true];
}

@end
