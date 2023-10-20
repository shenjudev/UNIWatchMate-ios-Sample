//
//  SoundAndTouchFeedbackViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/11.
//

#import "SoundAndTouchFeedbackViewController.h"

@interface SoundAndTouchFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detail;

@end

@implementation SoundAndTouchFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Sound and touch feedback", nil);
    [self getNow];
    [self listen];
    
}
-(void)getNow{
    self.detail.text = @"";
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    [[[[wMPeripheral settings] switchs] getConfigModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    }];
}
-(void)listen{
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    [[[[wMPeripheral settings] switchs] model] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    }];
}

-(void)feedInfo:(WMSwitchsModel * _Nullable) x{
    NSMutableString * info = [[NSMutableString alloc] init];
    [info appendFormat:@"isRingtoneEnabled:%d\n",x.isRingtoneEnabled];
    [info appendFormat:@"isNotificationHaptic:%d\n",x.isNotificationHaptic];
    [info appendFormat:@"isCrownHapticFeedback:%d\n",x.isCrownHapticFeedback];
    [info appendFormat:@"isSystemHapticFeedback:%d\n",x.isSystemHapticFeedback];
    [info appendFormat:@"isMuted:%d\n",x.isMuted];
    [info appendFormat:@"isScreenWakeEnabled:%d\n",x.isScreenWakeEnabled];
    
    self.detail.text = info;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)getInfo:(id)sender {
    [self getNow];
}
- (IBAction)IsRingtoneEnabledON:(id)sender {
    [self setIsRingtoneEnabled:YES];
}
- (IBAction)IsRingtoneEnabledOFF:(id)sender {
    [self setIsRingtoneEnabled:NO];
}
- (IBAction)isNotificationHapticOn:(id)sender {
    [self setIsNotificationHaptic:YES];
}
- (IBAction)isNotificationHapticOFF:(id)sender {
    [self setIsNotificationHaptic:NO];
}
- (IBAction)isCrownHapticFeedbackON:(id)sender {
    [self setIsCrownHapticFeedback:YES];
}
- (IBAction)isCrownHapticFeedbackOFF:(id)sender {
    [self setIsCrownHapticFeedback:NO];
}
- (IBAction)isSystemHapticFeedbackON:(id)sender {
    [self setIsSystemHapticFeedback:YES];
}
- (IBAction)isSystemHapticFeedbackOFF:(id)sender {
    [self setIsSystemHapticFeedback:NO];
}
- (IBAction)isMutedON:(id)sender {
    [self setIsMuted:YES];
}
- (IBAction)isMutedOFF:(id)sender {
    [self setIsMuted:NO];
}
- (IBAction)isScreenWakeEnabledON:(id)sender {
    [self setIsScreenWakeEnabled:YES];
}
- (IBAction)isScreenWakeEnabledOFF:(id)sender {
    [self setIsScreenWakeEnabled:NO];
}
-(void)setIsRingtoneEnabled:(BOOL)enable{
    self.detail.text = @"";
    
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMSwitchsModel *wMSwitchsModel = [[[wMPeripheral settings] switchs] modelValue];
    wMSwitchsModel.isRingtoneEnabled = enable;
    [[[[wMPeripheral settings] switchs] setConfigModel:wMSwitchsModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
}
-(void)setIsNotificationHaptic:(BOOL)enable{
    self.detail.text = @"";
    
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMSwitchsModel *wMSwitchsModel = [[[wMPeripheral settings] switchs] modelValue];
    wMSwitchsModel.isNotificationHaptic = enable;
    [[[[wMPeripheral settings] switchs] setConfigModel:wMSwitchsModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
}
-(void)setIsCrownHapticFeedback:(BOOL)enable{
    self.detail.text = @"";
    
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMSwitchsModel *wMSwitchsModel = [[[wMPeripheral settings] switchs] modelValue];
    wMSwitchsModel.isCrownHapticFeedback = enable;
    [[[[wMPeripheral settings] switchs] setConfigModel:wMSwitchsModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
}
-(void)setIsSystemHapticFeedback:(BOOL)enable{
    self.detail.text = @"";
    
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMSwitchsModel *wMSwitchsModel = [[[wMPeripheral settings] switchs] modelValue];
    wMSwitchsModel.isSystemHapticFeedback = enable;
    [[[[wMPeripheral settings] switchs] setConfigModel:wMSwitchsModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
}
-(void)setIsMuted:(BOOL)enable{
    self.detail.text = @"";
    
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMSwitchsModel *wMSwitchsModel = [[[wMPeripheral settings] switchs] modelValue];
    wMSwitchsModel.isMuted = enable;
    [[[[wMPeripheral settings] switchs] setConfigModel:wMSwitchsModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
}
-(void)setIsScreenWakeEnabled:(BOOL)enable{
    self.detail.text = @"";
    
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMSwitchsModel *wMSwitchsModel = [[[wMPeripheral settings] switchs] modelValue];
    wMSwitchsModel.isScreenWakeEnabled = enable;
    [[[[wMPeripheral settings] switchs] setConfigModel:wMSwitchsModel] subscribeNext:^(WMSwitchsModel * _Nullable x) {
        @strongify(self);
        [self feedInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
}
@end
