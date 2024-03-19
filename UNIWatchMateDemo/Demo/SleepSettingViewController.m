//
//  SleepSettingViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/12.
//

#import "SleepSettingViewController.h"
#import "NSDate+YYAdd.h"

@interface SleepSettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTime;
@property(strong,nonatomic) WMSleepModel *wMSleepModel;

@end

@implementation SleepSettingViewController
- (IBAction)getInfo:(id)sender {
    [self getNow];
}
- (IBAction)turnOn:(id)sender {
    [self turn:YES];
}
- (IBAction)turnOff:(id)sender {
    [self turn:NO];
}
- (IBAction)sendStartTime:(id)sender {
    [self setTimeIsStart:YES];
}
- (IBAction)sendEndTime:(id)sender {
    [self setTimeIsStart:NO];
}
-(void)turn:(BOOL)enable{
    self.detail.text = @"";
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    if(_wMSleepModel == nil){
        return;
    }
    _wMSleepModel.isEnabled = enable;
    [[[[wMPeripheral settings] sleep] setConfigModel:_wMSleepModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        self.detail.text = [NSString stringWithFormat:@"isEnabled:%d\nstart:%@\nend:%@\n",_wMSleepModel.isEnabled,[_wMSleepModel.timeRange.start stringWithFormat:@"HH:mm"],[_wMSleepModel.timeRange.end stringWithFormat:@"HH:mm"]];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
}
-(void)setTimeIsStart:(BOOL)isStart{
    self.detail.text = @"";
    @weakify(self);
    if(_wMSleepModel == nil){
        return;
    }
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    if (isStart == true){
        _wMSleepModel.timeRange.start = self.startTime.date;
    }else{
        _wMSleepModel.timeRange.end = self.endTime.date;
    }
    [[[[wMPeripheral settings] sleep] setConfigModel:_wMSleepModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        self.detail.text = [NSString stringWithFormat:@"isEnabled:%d\nstart:%@\nend:%@\n",_wMSleepModel.isEnabled,[_wMSleepModel.timeRange.start stringWithFormat:@"HH:mm"],[_wMSleepModel.timeRange.end stringWithFormat:@"HH:mm"]];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Sleep time", nil);
    [self getNow];
    [self listen];
    
}
-(void)getNow{
    self.detail.text = @"";
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    [wMPeripheral settings];
//    [[[[wMPeripheral settings] sleep] getConfigModel] subscribeNext:^(WMSleepModel * _Nullable x) {
//        @strongify(self);
//        self->_wMSleepModel = x;
//        self.detail.text = [NSString stringWithFormat:@"isEnabled:%d\nstart:%@\nend:%@\n",_wMSleepModel.isEnabled,[x.timeRange.start stringWithFormat:@"HH:mm"],[_wMSleepModel.timeRange.end stringWithFormat:@"HH:mm"]];
//    } error:^(NSError * _Nullable error) {
//        
//    }];
}
-(void)listen{
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    [[[[wMPeripheral settings] sleep] model] subscribeNext:^(WMSleepModel * _Nullable x) {
        @strongify(self);
        self.detail.text = [NSString stringWithFormat:@"isEnabled:%d\nstart:%@\nend:%@\n",x.isEnabled,[x.timeRange.start stringWithFormat:@"HH:mm"],[x.timeRange.end stringWithFormat:@"HH:mm"]];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
    
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
