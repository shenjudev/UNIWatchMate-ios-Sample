//
//  ConfigHeartRateViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/24.
//

#import "ConfigHeartRateViewController.h"

@interface ConfigHeartRateViewController ()
@property (strong, nonatomic) UILabel *detail;
@property (nonatomic, strong) UIButton *getNowBtn;

@property (nonatomic,strong) UILabel *isAutoTip;
@property (nonatomic,strong) UISwitch *isAutoSwitch;


@property (nonatomic,strong) UILabel *heartRateRangeMaxTip;
@property (nonatomic,strong) UITextField *heartRateRangeMax;
@property (nonatomic,strong) UIButton *heartRateRangeMaxSave;

@property (nonatomic,strong) UILabel *exerciseAlertTip;
@property (nonatomic,strong) UILabel *exerciseAlertIsAlertEnabledTip;
@property (nonatomic,strong) UISwitch *exerciseAlertIsAlertEnabled;

@property (nonatomic,strong) UILabel *exerciseAlertThresholdTip;
@property (nonatomic,strong) UITextField *exerciseAlertThreshold;
@property (nonatomic,strong) UIButton *exerciseAlertThresholdSave;


@property (nonatomic,strong) UILabel *restingHeartRateAlertTip;
@property (nonatomic,strong) UILabel *restingHeartRateAlertEnabledTip;
@property (nonatomic,strong) UISwitch *restingHeartRateAlertIsAlertEnabled;

@property (nonatomic,strong) UILabel *restingHeartRateAlertThresholdTip;
@property (nonatomic,strong) UITextField *restingHeartRateAlertThreshold;
@property (nonatomic,strong) UIButton *restingHeartRateAlertThresholdSave;

@property (nonatomic,strong) UIScrollView *scrollView;


@end

@implementation ConfigHeartRateViewController

-(UIScrollView *)scrollView{
    if(_scrollView == nil){
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 1000);
        [self.view addSubview:_scrollView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

// isAutoTip
- (UILabel *)isAutoTip {
    if (!_isAutoTip) {
        _isAutoTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _isAutoTip.text = @"isAutoMeasure";
        _isAutoTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_isAutoTip];
    }
    return _isAutoTip;
}

// isAutoSwitch
- (UISwitch *)isAutoSwitch {
    if (!_isAutoSwitch) {
        _isAutoSwitch = [[UISwitch alloc] init];
        // 进行其他属性设置和布局
        [_isAutoSwitch addTarget:self action:@selector(changeAuto) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:_isAutoSwitch];
    }
    return _isAutoSwitch;
}




-(UILabel *)detail{
    if(_detail == nil){
        _detail = [[UILabel alloc] init];
        _detail.adjustsFontSizeToFitWidth = true;
        _detail.numberOfLines = 0;
        _detail.backgroundColor = [UIColor lightGrayColor];
        [self.scrollView addSubview:_detail];
    }
    return  _detail;
}

-(UIButton *)getNowBtn{
    if (_getNowBtn == nil){
        _getNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getNowBtn setTitle:@"Get Now" forState:UIControlStateNormal];
        [_getNowBtn addTarget:self action:@selector(getNow) forControlEvents:UIControlEventTouchUpInside];
        _getNowBtn.layer.masksToBounds = YES;
        _getNowBtn.layer.cornerRadius = 5;
        [_getNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getNowBtn setBackgroundColor:[UIColor blueColor]];
        [self.scrollView addSubview:_getNowBtn];
    }
    return _getNowBtn;
}


// heartRateRangeWarmUpTip
- (UILabel *)heartRateRangeMaxTip {
    if (!_heartRateRangeMaxTip) {
        _heartRateRangeMaxTip = [[UILabel alloc] init];
        _heartRateRangeMaxTip.text = @"maxHeartRate";
        _heartRateRangeMaxTip.adjustsFontSizeToFitWidth = YES;
        _heartRateRangeMaxTip.textColor = [UIColor blackColor];
        _heartRateRangeMaxTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_heartRateRangeMaxTip];
    }
    return _heartRateRangeMaxTip;
}

// heartRateRangeWarmUp
- (UITextField *)heartRateRangeMax {
    if (!_heartRateRangeMax) {
        _heartRateRangeMax = [[UITextField alloc] init];
        _heartRateRangeMax.placeholder = @"Input max heart rate";
        _heartRateRangeMax.textColor = [UIColor blackColor];
        _heartRateRangeMax.keyboardType = UIKeyboardTypeNumberPad;
        [self.scrollView addSubview:_heartRateRangeMax];
    }
    return _heartRateRangeMax;
}

// heartRateRangeWarmUpSave
- (UIButton *)heartRateRangeMaxSave {
    if (!_heartRateRangeMaxSave) {
        _heartRateRangeMaxSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [_heartRateRangeMaxSave setTitle:@"Save" forState:UIControlStateNormal];
        [_heartRateRangeMaxSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_heartRateRangeMaxSave setBackgroundColor:[UIColor blueColor]];
        _heartRateRangeMaxSave.layer.masksToBounds = YES;
        _heartRateRangeMaxSave.layer.cornerRadius = 5;
        [_heartRateRangeMaxSave addTarget:self action:@selector(heartRateRangeMaxAction) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_heartRateRangeMaxSave];
    }
    return _heartRateRangeMaxSave;
}



// exerciseAlertTip
- (UILabel *)exerciseAlertTip {
    if (!_exerciseAlertTip) {
        _exerciseAlertTip = [[UILabel alloc] init];
        _exerciseAlertTip.text = @"exerciseAlert";
        _exerciseAlertTip.textColor = [UIColor blackColor];
        _exerciseAlertTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_exerciseAlertTip];
    }
    return _exerciseAlertTip;
}

// exerciseAlertIsAlertEnabledTip
- (UILabel *)exerciseAlertIsAlertEnabledTip {
    if (!_exerciseAlertIsAlertEnabledTip) {
        _exerciseAlertIsAlertEnabledTip = [[UILabel alloc] init];
        _exerciseAlertIsAlertEnabledTip.text = @"IsAlertEnabled";
        _exerciseAlertIsAlertEnabledTip.textColor = [UIColor blackColor];
        _exerciseAlertIsAlertEnabledTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_exerciseAlertIsAlertEnabledTip];
    }
    return _exerciseAlertIsAlertEnabledTip;
}

// exerciseAlertIsAlertEnabled
- (UISwitch *)exerciseAlertIsAlertEnabled {
    if (!_exerciseAlertIsAlertEnabled) {
        _exerciseAlertIsAlertEnabled = [[UISwitch alloc] init];
        [self.scrollView addSubview:_exerciseAlertIsAlertEnabled];
        [_exerciseAlertIsAlertEnabled addTarget:self action:@selector(exerciseAlertIsAlertEnabledpSaveAction) forControlEvents:UIControlEventValueChanged];
    }
    return _exerciseAlertIsAlertEnabled;
}

// exerciseAlertThresholdTip
- (UILabel *)exerciseAlertThresholdTip {
    if (!_exerciseAlertThresholdTip) {
        _exerciseAlertThresholdTip = [[UILabel alloc] init];
        _exerciseAlertThresholdTip.text = @"Alert Threshold";
        _exerciseAlertThresholdTip.textColor = [UIColor blackColor];
        _exerciseAlertThresholdTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_exerciseAlertThresholdTip];
    }
    return _exerciseAlertThresholdTip;
}

// exerciseAlertThreshold
- (UITextField *)exerciseAlertThreshold {
    if (!_exerciseAlertThreshold) {
        _exerciseAlertThreshold = [[UITextField alloc] init];
        _exerciseAlertThreshold.placeholder = @"Input AlertThreshold";
        _exerciseAlertThreshold.textColor = [UIColor blackColor];
        _exerciseAlertThreshold.keyboardType = UIKeyboardTypeNumberPad;
        [self.scrollView addSubview:_exerciseAlertThreshold];
    }
    return _exerciseAlertThreshold;
}

// exerciseAlertThresholdSave
- (UIButton *)exerciseAlertThresholdSave {
    if (!_exerciseAlertThresholdSave) {
        _exerciseAlertThresholdSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exerciseAlertThresholdSave setTitle:@"Save" forState:UIControlStateNormal];
        [_exerciseAlertThresholdSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exerciseAlertThresholdSave setBackgroundColor:[UIColor blueColor]];
        _exerciseAlertThresholdSave.layer.masksToBounds = YES;
        _exerciseAlertThresholdSave.layer.cornerRadius = 5;
        [_exerciseAlertThresholdSave addTarget:self action:@selector(exerciseAlertThresholdSaveAction) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_exerciseAlertThresholdSave];
    }
    return _exerciseAlertThresholdSave;
}

// restingHeartRateAlertTip
- (UILabel *)restingHeartRateAlertTip {
    if (!_restingHeartRateAlertTip) {
        _restingHeartRateAlertTip = [[UILabel alloc] init];
        _restingHeartRateAlertTip.text = @"restingAlert";
        _restingHeartRateAlertTip.textColor = [UIColor blackColor];
        _restingHeartRateAlertTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_restingHeartRateAlertTip];
    }
    return _restingHeartRateAlertTip;
}

// restingHeartRateAlertEnabledTip
- (UILabel *)restingHeartRateAlertEnabledTip {
    if (!_restingHeartRateAlertEnabledTip) {
        _restingHeartRateAlertEnabledTip = [[UILabel alloc] init];
        _restingHeartRateAlertEnabledTip.text = @"IsAlertEnabled";
        _restingHeartRateAlertEnabledTip.textColor = [UIColor blackColor];
        _restingHeartRateAlertEnabledTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_restingHeartRateAlertEnabledTip];
        
    }
    return _restingHeartRateAlertEnabledTip;
}

// restingHeartRateAlertIsAlertEnabled
- (UISwitch *)restingHeartRateAlertIsAlertEnabled {
    if (!_restingHeartRateAlertIsAlertEnabled) {
        _restingHeartRateAlertIsAlertEnabled = [[UISwitch alloc] init];
        [self.scrollView addSubview:_restingHeartRateAlertIsAlertEnabled];
        [_restingHeartRateAlertIsAlertEnabled addTarget:self action:@selector(restingHeartRateAlertIsAlertEnabledpSaveAction) forControlEvents:UIControlEventValueChanged];
    }
    return _restingHeartRateAlertIsAlertEnabled;
}


// restingHeartRateAlertThresholdTip
- (UILabel *)restingHeartRateAlertThresholdTip {
    if (!_restingHeartRateAlertThresholdTip) {
        _restingHeartRateAlertThresholdTip = [[UILabel alloc] init];
        _restingHeartRateAlertThresholdTip.text = @"AlertThreshold";
        _restingHeartRateAlertThresholdTip.textColor = [UIColor blackColor];
        _restingHeartRateAlertThresholdTip.adjustsFontSizeToFitWidth = YES;
        [self.scrollView addSubview:_restingHeartRateAlertThresholdTip];
    }
    return _restingHeartRateAlertThresholdTip;
}

// restingHeartRateAlertThreshold
- (UITextField *)restingHeartRateAlertThreshold {
    if (!_restingHeartRateAlertThreshold) {
        _restingHeartRateAlertThreshold = [[UITextField alloc] init];
        _restingHeartRateAlertThreshold.placeholder = @"Input Threshold";
        _restingHeartRateAlertThreshold.textColor = [UIColor blackColor];
        _restingHeartRateAlertThreshold.keyboardType = UIKeyboardTypeNumberPad;
        [self.scrollView addSubview:_restingHeartRateAlertThreshold];
    }
    return _restingHeartRateAlertThreshold;
}

// restingHeartRateAlertThresholdSave
- (UIButton *)restingHeartRateAlertThresholdSave {
    if (!_restingHeartRateAlertThresholdSave) {
        _restingHeartRateAlertThresholdSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restingHeartRateAlertThresholdSave setTitle:@"Save" forState:UIControlStateNormal];
        [_restingHeartRateAlertThresholdSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_restingHeartRateAlertThresholdSave setBackgroundColor:[UIColor blueColor]];
        _restingHeartRateAlertThresholdSave.layer.masksToBounds = YES;
        _restingHeartRateAlertThresholdSave.layer.cornerRadius = 5;
        [_restingHeartRateAlertThresholdSave addTarget:self action:@selector(restingHeartRateAlertThresholdSaveAction) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_restingHeartRateAlertThresholdSave];
    }
    return _restingHeartRateAlertThresholdSave;
}


-(void)listen{

}
-(void)showDetail:(WMHeartRateConfigModel *)x{
    NSMutableString *info = [NSMutableString new];
    [info appendFormat:@"isAutoMeasure: %d\n",x.isAutoMeasure];

    [info appendFormat:@"maxHeartRate:\n",@""];
    [info appendFormat:@"  maxHeartRate: %d\n",x.maxHeartRate];
    WMHeartRateRangeModel *wMHeartRateRangeModel = x.heartRateRangeModel;
    [info appendFormat:@"  warmUp: %d\n",wMHeartRateRangeModel.warmUp];
    [info appendFormat:@"  fatBurn: %d\n",wMHeartRateRangeModel.fatBurn];
    [info appendFormat:@"  endurance: %d\n",wMHeartRateRangeModel.endurance];
    [info appendFormat:@"  anaerobic: %d\n",wMHeartRateRangeModel.anaerobic];
    [info appendFormat:@"  peak: %d\n",wMHeartRateRangeModel.peak];


    [info appendFormat:@"exerciseAlert:\n",@""];
    [info appendFormat:@"  isAlertEnabled: %d\n",x.exerciseAlert.isAlertEnabled];
    [info appendFormat:@"  alertThreshold: %d\n",x.exerciseAlert.alertThreshold];


    [info appendFormat:@"restingAlert:\n",@""];
    [info appendFormat:@"  isAlertEnabled: %d\n",x.restingAlert.isAlertEnabled];
    [info appendFormat:@"  alertThreshold: %d\n",x.restingAlert.alertThreshold];

    self.detail.text = info;

}

-(void)getNow{
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[WatchManager sharedInstance].currentValue.apps.configHeartRateApp.wm_getHeartRateConfig subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];

    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Config heart rate", nil);
    self.view.backgroundColor = [UIColor whiteColor];

    self.scrollView.frame = self.view.frame;

    self.detail.frame = CGRectMake(20, 20, CGRectGetWidth(self.view.frame) - 40, 150);
    self.getNowBtn.frame = CGRectMake(20, 190, CGRectGetWidth(self.view.frame) - 40, 44);

    self.isAutoTip.frame = CGRectMake(20, 260, 100, 44);
    self.isAutoSwitch.frame = CGRectMake(CGRectGetMaxX(self.isAutoTip.frame), 260, 60, 44);

    self.heartRateRangeMaxTip.frame =  CGRectMake(20, 340,100, 44);
    self.heartRateRangeMax.frame = CGRectMake(CGRectGetMaxX(self.heartRateRangeMaxTip.frame), 340, 160, 44);
    self.heartRateRangeMaxSave.frame = CGRectMake(CGRectGetMaxX(self.heartRateRangeMax.frame), 340, 60, 44);

    self.exerciseAlertTip.frame = CGRectMake(20, 460, CGRectGetWidth(self.view.frame) - 40, 44);
    self.exerciseAlertIsAlertEnabledTip.frame =  CGRectMake(40, 520, 100, 44);
    self.exerciseAlertIsAlertEnabled.frame = CGRectMake(CGRectGetMaxX(self.exerciseAlertIsAlertEnabledTip.frame) + 10, 520, 160, 44);

    self.exerciseAlertThresholdTip.frame =  CGRectMake(40, 580, 100, 44);
    self.exerciseAlertThreshold.frame = CGRectMake(CGRectGetMaxX(self.exerciseAlertThresholdTip.frame), 580, 160, 44);
    self.exerciseAlertThresholdSave.frame = CGRectMake(CGRectGetMaxX(self.exerciseAlertThreshold.frame), 580, 60, 44);


    self.restingHeartRateAlertTip.frame = CGRectMake(20, 640, CGRectGetWidth(self.view.frame) - 40, 44);
    self.restingHeartRateAlertEnabledTip.frame =  CGRectMake(40, 720, 100, 44);
    self.restingHeartRateAlertIsAlertEnabled.frame = CGRectMake(CGRectGetMaxX(self.restingHeartRateAlertEnabledTip.frame) + 10, 720, 160, 44);

    self.restingHeartRateAlertThresholdTip.frame =  CGRectMake(40, 780, 100, 44);
    self.restingHeartRateAlertThreshold.frame = CGRectMake(CGRectGetMaxX(self.restingHeartRateAlertThresholdTip.frame), 780, 160, 44);
    self.restingHeartRateAlertThresholdSave.frame = CGRectMake(CGRectGetMaxX(self.restingHeartRateAlertThreshold.frame), 780, 60, 44);


    [self getNow];
    [self listen];
}
- (void)closeKeyboard
{
    [self.view endEditing:YES];
}
-(void)changeAuto{
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMHeartRateConfigModel * wMHeartRateConfigModel = [WatchManager sharedInstance].currentValue.apps.configHeartRateApp.modelValue;
    wMHeartRateConfigModel.isAutoMeasure = _isAutoSwitch.isOn;
    [[[WatchManager sharedInstance].currentValue.apps.configHeartRateApp wm_setHeartRateConfig:wMHeartRateConfigModel] subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Set success."];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set failed.\n%@",error.description]];

    }];
}
-(void)heartRateRangeMaxAction{
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMHeartRateConfigModel * wMHeartRateConfigModel = [WatchManager sharedInstance].currentValue.apps.configHeartRateApp.modelValue;
    wMHeartRateConfigModel.maxHeartRate = [self.heartRateRangeMax.text integerValue];
    [[[WatchManager sharedInstance].currentValue.apps.configHeartRateApp wm_setHeartRateConfig:wMHeartRateConfigModel] subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Set success."];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set failed.\n%@",error.description]];

    }];
}

-(void)exerciseAlertIsAlertEnabledpSaveAction{
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMHeartRateConfigModel * wMHeartRateConfigModel = [WatchManager sharedInstance].currentValue.apps.configHeartRateApp.modelValue;
    wMHeartRateConfigModel.exerciseAlert.isAlertEnabled = self.exerciseAlertIsAlertEnabled.isOn;
    [[[WatchManager sharedInstance].currentValue.apps.configHeartRateApp wm_setHeartRateConfig:wMHeartRateConfigModel] subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Set success."];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set failed.\n%@",error.description]];

    }];


}
-(void)exerciseAlertThresholdSaveAction{
    NSInteger value = [self.exerciseAlertThreshold.text intValue];
    if (value == nil || value == 0){
        [SVProgressHUD showErrorWithStatus:@"Value is not valid"];
        return;
    }
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMHeartRateConfigModel * wMHeartRateConfigModel = [WatchManager sharedInstance].currentValue.apps.configHeartRateApp.modelValue;
    wMHeartRateConfigModel.exerciseAlert.alertThreshold = value;
    [[[WatchManager sharedInstance].currentValue.apps.configHeartRateApp wm_setHeartRateConfig:wMHeartRateConfigModel] subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Set success."];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set failed.\n%@",error.description]];

    }];


}
-(void)restingHeartRateAlertIsAlertEnabledpSaveAction{
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMHeartRateConfigModel * wMHeartRateConfigModel = [WatchManager sharedInstance].currentValue.apps.configHeartRateApp.modelValue;
    wMHeartRateConfigModel.restingAlert.isAlertEnabled = self.restingHeartRateAlertIsAlertEnabled.isOn;
    [[[WatchManager sharedInstance].currentValue.apps.configHeartRateApp wm_setHeartRateConfig:wMHeartRateConfigModel] subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Set success."];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set failed.\n%@",error.description]];

    }];
}
-(void)restingHeartRateAlertThresholdSaveAction{
    NSInteger value = [self.restingHeartRateAlertThreshold.text intValue];
    if (value == nil || value == 0){
        [SVProgressHUD showErrorWithStatus:@"Value is not valid"];
        return;
    }
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMHeartRateConfigModel * wMHeartRateConfigModel = [WatchManager sharedInstance].currentValue.apps.configHeartRateApp.modelValue;
    wMHeartRateConfigModel.restingAlert.alertThreshold = value;
    [[[WatchManager sharedInstance].currentValue.apps.configHeartRateApp wm_setHeartRateConfig:wMHeartRateConfigModel] subscribeNext:^(WMHeartRateConfigModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Set success."];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set failed.\n%@",error.description]];

    }];
}
@end
