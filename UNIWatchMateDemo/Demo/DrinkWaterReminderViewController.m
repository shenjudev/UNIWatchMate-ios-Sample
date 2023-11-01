//
//  DrinkWaterReminderViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/24.
//

#import "DrinkWaterReminderViewController.h"
NSString *NSStringFromWMTimeFrequencyWater(WMTimeFrequency timeFrequency) {
    switch (timeFrequency) {
        case WMTimeFrequencyEvery30Minutes:
            return @"WMTimeFrequencyEvery30Minutes";
        case WMTimeFrequencyEvery1Hour:
            return @"WMTimeFrequencyEvery1Hour";
        case WMTimeFrequencyEvery1Hour30Minutes:
            return @"WMTimeFrequencyEvery1Hour30Minutes";
    }
}

@interface DrinkWaterReminderViewController ()
@property (strong, nonatomic) UILabel *detail;
@property (nonatomic, strong) UIButton *getNowBtn;

@property (nonatomic,strong) UILabel *isEnableTip;
@property (nonatomic,strong) UISwitch *isEnableSwitch;

@property (nonatomic,strong) UILabel *timeRangeTip;
@property (nonatomic,strong) UIDatePicker *startDate;
@property (nonatomic,strong) UIDatePicker *endDate;
@property (nonatomic,strong) UIButton *timeRangeSave;


@property (nonatomic,strong) UILabel *frequencyTip;
@property (nonatomic,strong) UIButton *frequencyBtn;

@property (nonatomic,strong) UILabel *noDisturbLunchBreakTip;

@property (nonatomic,strong) UILabel *noDisturbLunchBreakIsEnableTip;
@property (nonatomic,strong) UISwitch *noDisturbLunchBreakIsEnableSwitch;

@property (nonatomic,strong) UILabel *noDisturbLunchBreakTimeRangeTip;
@property (nonatomic,strong) UIDatePicker *noDisturbLunchBreakStartDate;
@property (nonatomic,strong) UIDatePicker *noDisturbLunchBreakEndDate;

@property (nonatomic, strong) UIButton *noDisturbLaunchBreak;

@property (nonatomic,strong) NSArray *timeFrequencys;
@property (nonatomic, strong) PickerViewController *pickerVC;
@property (nonatomic, strong) LSTPopView *popView;

@property (nonatomic,strong) UIScrollView *scrollView;

@end

@implementation DrinkWaterReminderViewController

-(UIScrollView *)scrollView{
    if(_scrollView == nil){
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 800);
        [self.view addSubview:_scrollView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

- (void)closeKeyboard
{
    [self.view endEditing:YES];
}


- (UIButton *)timeRangeSave {
    if (!_timeRangeSave) {
        _timeRangeSave = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeRangeSave setTitle:@"Save" forState:UIControlStateNormal];
        [_timeRangeSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_timeRangeSave setBackgroundColor:[UIColor blueColor]];
        _timeRangeSave.layer.masksToBounds = YES;
        _timeRangeSave.layer.cornerRadius = 5;
        [_timeRangeSave addTarget:self action:@selector(actionTimeRange) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_timeRangeSave];
    }
    return _timeRangeSave;
}




// isEnableTip
- (UILabel *)isEnableTip {
    if (!_isEnableTip) {
        _isEnableTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _isEnableTip.text = @"isEnable";
        [self.scrollView addSubview:_isEnableTip];
    }
    return _isEnableTip;
}

// isEnableSwitch
- (UISwitch *)isEnableSwitch {
    if (!_isEnableSwitch) {
        _isEnableSwitch = [[UISwitch alloc] init];
        // 进行其他属性设置和布局
        [_isEnableSwitch addTarget:self action:@selector(actionEnable:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:_isEnableSwitch];
    }
    return _isEnableSwitch;
}

// timeRangeTip
- (UILabel *)timeRangeTip {
    if (!_timeRangeTip) {
        _timeRangeTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _timeRangeTip.text = @"timeRange";
        [self.scrollView addSubview:_timeRangeTip];
    }
    return _timeRangeTip;
}

// startDate
- (UIDatePicker *)startDate {
    if (!_startDate) {
        _startDate = [[UIDatePicker alloc] init];
        // 进行其他属性设置和布局
        _startDate.datePickerMode = UIDatePickerModeTime; // 设置为时间选择模式
        // 限制显示的时间组件，只显示小时和分钟
        [_startDate setMinuteInterval:1]; // 设置分钟间隔为1分钟

        [self.scrollView addSubview:_startDate];
    }
    return _startDate;
}

// endDate
- (UIDatePicker *)endDate {
    if (!_endDate) {
        _endDate = [[UIDatePicker alloc] init];
        // 进行其他属性设置和布局
        _endDate.datePickerMode = UIDatePickerModeTime; // 设置为时间选择模式
        // 限制显示的时间组件，只显示小时和分钟
        [_endDate setMinuteInterval:1]; // 设置分钟间隔为1分钟
        // 进行其他属性设置和布局
        [self.scrollView addSubview:_endDate];
    }
    return _endDate;
}

// frequencyTip
- (UILabel *)frequencyTip {
    if (!_frequencyTip) {
        _frequencyTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _frequencyTip.text = @"frequency";
        [self.scrollView addSubview:_frequencyTip];
    }
    return _frequencyTip;
}

// frequencyBtn
- (UIButton *)frequencyBtn {
    if (!_frequencyBtn) {
        _frequencyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        // 进行其他属性设置和布局
        [_frequencyBtn setBackgroundColor:[UIColor blueColor]];
        [_frequencyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_frequencyBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _frequencyBtn.layer.cornerRadius = 5;
        _frequencyBtn.layer.masksToBounds = YES;
        _frequencyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_frequencyBtn setTitle:self.timeFrequencys.firstObject forState:UIControlStateNormal];
        [_frequencyBtn addTarget:self action:@selector(changeFrequency:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_frequencyBtn];
    }
    return _frequencyBtn;
}

// noDisturbLunchBreakTip
- (UILabel *)noDisturbLunchBreakTip {
    if (!_noDisturbLunchBreakTip) {
        _noDisturbLunchBreakTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _noDisturbLunchBreakTip.text = @"noDisturbLunchBreakTip";
        [self.scrollView addSubview:_noDisturbLunchBreakTip];
    }
    return _noDisturbLunchBreakTip;
}

// noDisturbLunchBreakIsEnableTip
- (UILabel *)noDisturbLunchBreakIsEnableTip {
    if (!_noDisturbLunchBreakIsEnableTip) {
        _noDisturbLunchBreakIsEnableTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _noDisturbLunchBreakIsEnableTip.text = @"isEnable";
        [self.scrollView addSubview:_noDisturbLunchBreakIsEnableTip];
    }
    return _noDisturbLunchBreakIsEnableTip;
}

// noDisturbLunchBreakIsEnableSwitch
- (UISwitch *)noDisturbLunchBreakIsEnableSwitch {
    if (!_noDisturbLunchBreakIsEnableSwitch) {
        _noDisturbLunchBreakIsEnableSwitch = [[UISwitch alloc] init];
        // 进行其他属性设置和布局
        [_noDisturbLunchBreakIsEnableSwitch addTarget:self action:@selector(actionNoDisturbLunchBreakIsEnable:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:_noDisturbLunchBreakIsEnableSwitch];
    }
    return _noDisturbLunchBreakIsEnableSwitch;
}

// noDisturbLunchBreakTimeRangeTip
- (UILabel *)noDisturbLunchBreakTimeRangeTip {
    if (!_noDisturbLunchBreakTimeRangeTip) {
        _noDisturbLunchBreakTimeRangeTip = [[UILabel alloc] init];
        // 进行其他属性设置和布局
        _noDisturbLunchBreakTimeRangeTip.text = @"timeRange";
        [self.scrollView addSubview:_noDisturbLunchBreakTimeRangeTip];
    }
    return _noDisturbLunchBreakTimeRangeTip;
}

// noDisturbLunchBreakStartDate
- (UIDatePicker *)noDisturbLunchBreakStartDate {
    if (!_noDisturbLunchBreakStartDate) {
        _noDisturbLunchBreakStartDate = [[UIDatePicker alloc] init];
        // 进行其他属性设置和布局
        _noDisturbLunchBreakStartDate.datePickerMode = UIDatePickerModeTime; // 设置为时间选择模式
        // 限制显示的时间组件，只显示小时和分钟
        [_noDisturbLunchBreakStartDate setMinuteInterval:1]; // 设置分钟间隔为1分钟

        [self.scrollView addSubview:_noDisturbLunchBreakStartDate];
    }
    return _noDisturbLunchBreakStartDate;
}

// noDisturbLunchBreakEndDate
- (UIDatePicker *)noDisturbLunchBreakEndDate {
    if (!_noDisturbLunchBreakEndDate) {
        _noDisturbLunchBreakEndDate = [[UIDatePicker alloc] init];
        // 进行其他属性设置和布局
        _noDisturbLunchBreakEndDate.datePickerMode = UIDatePickerModeTime; // 设置为时间选择模式
        // 限制显示的时间组件，只显示小时和分钟
        [_noDisturbLunchBreakEndDate setMinuteInterval:1]; // 设置分钟间隔为1分钟
        // 进行其他属性设置和布局
        [self.scrollView addSubview:_noDisturbLunchBreakEndDate];
    }
    return _noDisturbLunchBreakEndDate;
}

// shureBtn
- (UIButton *)noDisturbLaunchBreak {
    if (!_noDisturbLaunchBreak) {
        _noDisturbLaunchBreak = [UIButton buttonWithType:UIButtonTypeCustom];
        // 进行其他属性设置和布局
        [_noDisturbLaunchBreak setTitle:@"save" forState:UIControlStateNormal];
        [_noDisturbLaunchBreak setBackgroundColor:[UIColor blueColor]];
        [_noDisturbLaunchBreak setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_noDisturbLaunchBreak setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _noDisturbLaunchBreak.layer.cornerRadius = 5;
        _noDisturbLaunchBreak.layer.masksToBounds = YES;
        [_noDisturbLaunchBreak addTarget:self action:@selector(actionNoDisturbLaunch:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:_noDisturbLaunchBreak];
    }
    return _noDisturbLaunchBreak;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Drink water reminder", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView.frame = self.view.frame;

    _timeFrequencys = @[
        NSStringFromWMTimeFrequencyWater(WMTimeFrequencyEvery30Minutes),
        NSStringFromWMTimeFrequencyWater(WMTimeFrequencyEvery1Hour),
        NSStringFromWMTimeFrequencyWater(WMTimeFrequencyEvery1Hour30Minutes),

    ];
    self.detail.frame = CGRectMake(20, 20, CGRectGetWidth(self.view.frame) - 40, 150);
    self.getNowBtn.frame = CGRectMake(20, 190, CGRectGetWidth(self.view.frame) - 40, 44);

    self.isEnableTip.frame = CGRectMake(20, 260, 100, 44);
    self.isEnableSwitch.frame = CGRectMake(CGRectGetMaxX(self.isEnableTip.frame), 260, 60, 44);
    self.timeRangeTip.frame =  CGRectMake(20, 310, CGRectGetWidth(self.view.frame) - 40, 44);
    self.startDate.frame = CGRectMake(20, 360, 100, 44);
    self.endDate.frame = CGRectMake(CGRectGetMaxX(self.startDate.frame) + 10, 360, 100, 44);
    self.timeRangeSave.frame = CGRectMake(CGRectGetMaxX(self.endDate.frame) + 10, 360, 100, 44);
    self.frequencyTip.frame = CGRectMake(20, 410, 100, 44);
    self.frequencyBtn.frame = CGRectMake(CGRectGetMaxX(self.frequencyTip.frame) + 10, 410, CGRectGetWidth(self.view.frame) - CGRectGetMaxX(self.frequencyTip.frame) - 10 - 20, 44);

    self.noDisturbLunchBreakTip.frame = CGRectMake(20, 460, CGRectGetWidth(self.view.frame) - 40, 44);
    self.noDisturbLunchBreakIsEnableTip.frame = CGRectMake(40, 520, 100, 44);
    self.noDisturbLunchBreakIsEnableSwitch.frame = CGRectMake(CGRectGetMaxX(self.noDisturbLunchBreakIsEnableTip.frame), 520, 60, 44);
    self.noDisturbLunchBreakTimeRangeTip.frame =  CGRectMake(40, 580, CGRectGetWidth(self.view.frame) - 40, 44);
    self.noDisturbLunchBreakStartDate.frame = CGRectMake(40, 640, 100, 44);
    self.noDisturbLunchBreakEndDate.frame = CGRectMake(CGRectGetMaxX(self.noDisturbLunchBreakStartDate.frame), 640, 100, 44);

    self.noDisturbLaunchBreak.frame = CGRectMake(CGRectGetMaxX(self.noDisturbLunchBreakEndDate.frame) + 10, 640, 100, 44);


    [self getNow];
    [self listen];
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
-(void)listen{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.settings.waterReminder.model subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {

    }];
}

-(void)getNow{
    self.detail.text = @"";
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[[WatchManager sharedInstance].currentValue.settings.waterReminder getConfigModel] subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n",@"Get Fail",error.description]];
    }];
}


-(void)showDetail:(WMReminderModel *)x{
    NSMutableString *info = [NSMutableString new];
    [info appendFormat:@"isEnabled:%d\n",x.isEnabled];
    [info appendFormat:@"timeRange:\n  start:%@\n  end:%@\n",[self getHourAndMMFromDate:x.timeRange.start],[self getHourAndMMFromDate:x.timeRange.end]];
    [info appendFormat:@"frequency:%@\n",NSStringFromWMTimeFrequencyWater(x.frequency)];
    [info appendFormat:@"noDisturbLunchBreak:\n  isEnabled:%d\n  timeRange:\n  start:%@\n  end:%@\n",x.noDisturbLunchBreak.isEnabled,[self getHourAndMMFromDate:x.noDisturbLunchBreak.timeRange.start],[self getHourAndMMFromDate:x.noDisturbLunchBreak.timeRange.end]];
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
-(void)changeFrequency:(UIButton *)sender{

    @weakify(self);
    self.pickerVC = [[PickerViewController alloc] initWithValue:self.timeFrequencys.firstObject height:300.0 data:self.timeFrequencys type:USWatchPickerDataTypeLanguage doneBlock:^(NSString * _Nonnull frequency) {
        @strongify(self);
        [self.frequencyBtn setTitle:frequency forState:UIControlStateNormal];
        self.pickerVC = nil;
        [self.popView dismiss];
        [self actionChangeFrequency:frequency];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //创建弹窗PopViiew 指定父容器self.view, 不指定默认是app window
    self.popView = [LSTPopView initWithCustomView:self.pickerVC.view
                                       parentView:self.view
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
    //弹窗位置: 居中 贴顶 贴左 贴底 贴右
    self.popView.hemStyle = LSTHemStyleBottom;
    //点击背景触发
    self.popView.bgClickBlock = ^{
        @strongify(self);
        self.pickerVC = nil;
        [ self.popView dismiss];
    };
    //弹窗显示
    [self.popView pop];
}
- (NSString *)getHourAndMMFromDate:(NSDate *)date {
    // 1. 创建一个日期格式器
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];

    // 2. 设置日期格式器的格式
    [timeFormatter setDateFormat:@"HH:mm"];

    // 3. 设置日期格式器的时区为手机当前时区
    [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];

    // 4. 使用日期格式器格式化日期，并获取结果字符串
    NSString *formattedTime = [timeFormatter stringFromDate:date];

    // 5. 返回格式化的字符串
    return formattedTime;
}
-(void)actionEnable:(UISwitch *)sender{
    self.detail.text = @"";
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMReminderModel *wMReminderModel = [WatchManager sharedInstance].currentValue.settings.waterReminder.modelValue;
    wMReminderModel.isEnabled = self.isEnableSwitch.isOn;
    [[[WatchManager sharedInstance].currentValue.settings.waterReminder setConfigModel:wMReminderModel] subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",@"Set Fail",error.description]];
    }];
}

-(void)actionNoDisturbLunchBreakIsEnable:(UISwitch *)sender{
    self.detail.text = @"";
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMReminderModel *wMReminderModel = [WatchManager sharedInstance].currentValue.settings.waterReminder.modelValue;

    wMReminderModel.noDisturbLunchBreak.isEnabled = self.noDisturbLunchBreakIsEnableSwitch.isOn;



    [[[WatchManager sharedInstance].currentValue.settings.waterReminder setConfigModel:wMReminderModel] subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",@"Set Fail",error.description]];
    }];
}

-(void)actionTimeRange{
    self.detail.text = @"";
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMReminderModel *wMReminderModel = [WatchManager sharedInstance].currentValue.settings.waterReminder.modelValue;
    wMReminderModel.timeRange.start = self.startDate.date;
    wMReminderModel.timeRange.end = self.endDate.date;
    [[[WatchManager sharedInstance].currentValue.settings.waterReminder setConfigModel:wMReminderModel] subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",@"Set Fail",error.description]];
    }];
}
-(void)actionNoDisturbLaunch:(UIButton *)sender{
    self.detail.text = @"";
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMReminderModel *wMReminderModel = [WatchManager sharedInstance].currentValue.settings.waterReminder.modelValue;
    wMReminderModel.noDisturbLunchBreak.timeRange.start = self.noDisturbLunchBreakStartDate.date;
    wMReminderModel.noDisturbLunchBreak.timeRange.end = self.noDisturbLunchBreakEndDate.date;




    [[[WatchManager sharedInstance].currentValue.settings.waterReminder setConfigModel:wMReminderModel] subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",@"Set Fail",error.description]];
    }];
}
-(void)actionChangeFrequency:(NSString *)frequency{
    self.detail.text = @"";
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    WMReminderModel *wMReminderModel = [WatchManager sharedInstance].currentValue.settings.waterReminder.modelValue;
    wMReminderModel.frequency = [self.timeFrequencys indexOfObject:frequency];
    [[[WatchManager sharedInstance].currentValue.settings.waterReminder setConfigModel:wMReminderModel] subscribeNext:^(WMReminderModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDetail:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",@"Set Fail",error.description]];
    }];
}

@end
