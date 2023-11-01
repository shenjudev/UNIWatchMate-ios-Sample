//
//  FindDeviceViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/23.
//

#import "FindDeviceViewController.h"

@interface FindDeviceViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UILabel *ringCountTip;
@property(nonatomic,strong)UITextField *ringCount;
@property(nonatomic,strong)UILabel *ringTimeTip;
@property(nonatomic,strong)UITextField *ringTime;
@property(nonatomic,strong)UIButton *findBtn;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation FindDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Find device";


    self.ringCountTip.frame = CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 44);
    self.ringCount.frame = CGRectMake(20, 150, CGRectGetWidth(self.view.frame) - 40, 44);
    self.ringTimeTip.frame = CGRectMake(20, 200, CGRectGetWidth(self.view.frame) - 40, 44);
    self.ringTime.frame = CGRectMake(20, 250, CGRectGetWidth(self.view.frame) - 40, 44);

    self.findBtn.frame = CGRectMake(20, 400, CGRectGetWidth(self.view.frame) - 40, 44);

    self.ringCount.text = @"1";
    self.ringTime.text = @"3";
    [self listenForDeviceDiscovery];

}
-(void)listenForDeviceDiscovery{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.findApp.closeFindPhone subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        BOOL close = x;
        if (close == YES){
            if (self.alertController != nil){
                [self.alertController dismissViewControllerAnimated:false completion:nil];
            }
        }
    } error:^(NSError * _Nullable error) {

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
-(UILabel *)ringCountTip{
    if (_ringCountTip == nil){
        _ringCountTip = [UILabel new];
        _ringCountTip.text = @"Please input ring count.";
        _ringCountTip.numberOfLines = 0;
        _ringCountTip.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_ringCountTip];
    }
    return  _ringCountTip;
}

-(UITextField *)ringCount
{
    if (_ringCount == nil){
        _ringCount = [UITextField new];
        _ringCount.delegate = self;
        _ringCount.keyboardType = UIKeyboardTypeNumberPad;
        _ringCount.placeholder = @"Ring count";
        [self.view addSubview:_ringCount];
    }
    return  _ringCount;
}
-(UILabel *)ringTimeTip{
    if (_ringTimeTip == nil){
        _ringTimeTip = [UILabel new];
        _ringTimeTip.text = @"Please input ring time. s";
        _ringTimeTip.numberOfLines = 0;
        _ringTimeTip.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_ringTimeTip];
    }
    return  _ringTimeTip;
}
-(UITextField *)ringTime
{
    if (_ringTime == nil){
        _ringTime = [UITextField new];
        _ringTime.delegate = self;
        _ringTime.keyboardType = UIKeyboardTypeNumberPad;
        _ringTime.placeholder = @"Ring time";
        [self.view addSubview:_ringTime];
    }
    return  _ringTime;
}
-(UIButton *)findBtn{
    if (_findBtn == nil){
        _findBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_findBtn setTitle:@"Find" forState:UIControlStateNormal];
        [_findBtn setBackgroundColor:[UIColor blueColor]];
        [_findBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_findBtn addTarget:self action:@selector(actionFind) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_findBtn];
    }
    return  _findBtn;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(void)actionFind{
    if ([self.ringCount.text intValue] == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please input ring count.Canot be zero"];
        return;
    }
    if ([self.ringTime.text intValue] == 0) {
        [SVProgressHUD showErrorWithStatus:@"Please input ring time.Canot be zero"];
        return;
    }

    WMDeviceFindModel *model = [WMDeviceFindModel new];
    model.count = [self.ringCount.text intValue];
    model.timeSeconds = [self.ringTime.text intValue];
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[[WatchManager sharedInstance].currentValue.apps.findApp findWatch:model] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showFindController];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Find send failed"];
    }];
}


-(void)showFindController{
    @weakify(self);
    _alertController = [UIAlertController alertControllerWithTitle:@"Find" message:@"The watch is ring" preferredStyle:UIAlertControllerStyleAlert];
    [_alertController addAction:[UIAlertAction actionWithTitle:@"Stop" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self stopFind];
    }]];
    [self presentViewController:_alertController animated:YES completion:nil];
}

-(void)stopFind{
    [[WatchManager sharedInstance].currentValue.apps.findApp.phoneCloseFindWatch subscribeNext:^(NSNumber * _Nullable x) {

    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showSuccessWithStatus:@"Stop failed"];
    }];
}
- (void)dealloc
{
    if (_alertController != nil){
        [_alertController dismissViewControllerAnimated:false completion:nil];
    }
}

@end
