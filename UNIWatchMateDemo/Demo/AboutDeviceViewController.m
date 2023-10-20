//
//  AboutDeviceViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/8.
//

#import "AboutDeviceViewController.h"

@interface AboutDeviceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detail;

@end

@implementation AboutDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WMDeviceBaseInfo * baseInfo = [[[[WatchManager sharedInstance] currentValue] infoModel] baseinfoValue];
    NSMutableString * info = [NSMutableString string];
    [info appendFormat:@"%@%@\n",NSLocalizedString(@"Equipment model: ", nil),baseInfo.model];
    [info appendFormat:@"%@%@\n",NSLocalizedString(@"Device MAC address: ", nil),baseInfo.macAddress];
    [info appendFormat:@"%@%@\n",NSLocalizedString(@"Device version: ", nil),baseInfo.version];
    [info appendFormat:@"%@%@\n",NSLocalizedString(@"Device ID: ", nil),baseInfo.deviceId];
    [info appendFormat:@"%@%@\n",NSLocalizedString(@"Bluetooth name: ", nil),baseInfo.bluetoothName];
    [info appendFormat:@"%@%@\n",NSLocalizedString(@"Device name:", nil),baseInfo.deviceName];
    
    self.detail.text = info;
}
//点击页面复制全部信息
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    XLOG_INFO(@"%@",self.detail.text);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.detail.text;
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Copied to clipboard", nil)];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
