//
//  AlarmEditViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/19.
//

#import "AlarmEditViewController.h"

@interface AlarmEditViewController ()
@property (nonatomic, strong) UILabel *nameTip;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UILabel *timeTip;
@property (nonatomic, strong) UIDatePicker *timePicker;
@property (nonatomic, strong) UILabel *openTip;
@property (nonatomic, strong) UISwitch *openSwitch;
@property (nonatomic, strong) UILabel *repeatOptionsTip;

@property (nonatomic, strong) UIButton *mondayBtn;
@property (nonatomic, strong) UIButton *tuesdayBtn;
@property (nonatomic, strong) UIButton *wednesdayBtn;
@property (nonatomic, strong) UIButton *thursdayBtn;
@property (nonatomic, strong) UIButton *fridayBtn;
@property (nonatomic, strong) UIButton *saturdayBtn;
@property (nonatomic, strong) UIButton *sundayBtn;


@end

@implementation AlarmEditViewController

- (UIButton *)mondayBtn {
    if (_mondayBtn == nil) {
        _mondayBtn = [self createButtonWithTitle:@"Monday" tag:1];
        [self.view addSubview:_mondayBtn];
    }
    return _mondayBtn;
}

- (UIButton *)tuesdayBtn {
    if (_tuesdayBtn == nil) {
        _tuesdayBtn = [self createButtonWithTitle:@"Tuesday" tag:2];
        [self.view addSubview:_tuesdayBtn];
    }
    return _tuesdayBtn;
}

- (UIButton *)wednesdayBtn {
    if (_wednesdayBtn == nil) {
        _wednesdayBtn = [self createButtonWithTitle:@"Wednesday" tag:3];
        [self.view addSubview:_wednesdayBtn];
    }
    return _wednesdayBtn;
}

- (UIButton *)thursdayBtn {
    if (_thursdayBtn == nil) {
        _thursdayBtn = [self createButtonWithTitle:@"Thursday" tag:4];
        [self.view addSubview:_thursdayBtn];
    }
    return _thursdayBtn;
}

- (UIButton *)fridayBtn {
    if (_fridayBtn == nil) {
        _fridayBtn = [self createButtonWithTitle:@"Friday" tag:5];
        [self.view addSubview:_fridayBtn];
    }
    return _fridayBtn;
}

- (UIButton *)saturdayBtn {
    if (_saturdayBtn == nil) {
        _saturdayBtn = [self createButtonWithTitle:@"Saturday" tag:6];
        [self.view addSubview:_saturdayBtn];
    }
    return _saturdayBtn;
}

- (UIButton *)sundayBtn {
    if (_sundayBtn == nil) {
        _sundayBtn = [self createButtonWithTitle:@"Sunday" tag:7];
        [self.view addSubview:_sundayBtn];
    }
    return _sundayBtn;
}

- (UIButton *)createButtonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(60, 30)] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:[UIColor blueColor] size:CGSizeMake(60, 30)] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selectDay:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    return button;
}

- (void)selectDay:(UIButton *)sender {
    // 处理选择按钮的点击事件，可以根据按钮的tag属性来确定选择的是哪一天
    NSInteger selectedDayTag = sender.tag;
    NSLog(@"选中了第 %ld 天", (long)selectedDayTag);
    
    // 如果需要在按钮之间切换选择状态，可以在这里进行状态切换
    sender.selected = !sender.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Alarm Edit";
    
    // 创建和布局页面元素，包括文本字段、日期选择器和开关
    _nameTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 30)];
    _nameTip.text = @"Name";
    [self.view addSubview:_nameTip];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 130, CGRectGetWidth(self.view.frame) - 40, 40)];
    self.nameTextField.placeholder = @"Alarm name";
    [self.view addSubview:self.nameTextField];
    
    
    _timeTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, CGRectGetWidth(self.view.frame) - 40, 30)];
    _timeTip.text = @"Time";
    [self.view addSubview:_timeTip];
    
    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(20, 210, CGRectGetWidth(self.view.frame) - 40, 200)];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    if (@available(iOS 13.4, *)) {
        [self.timePicker setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    }
    [self.view addSubview:self.timePicker];
    
    _openTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 420, 100, 30)];
    _openTip.text = @"Enable";
    _openTip.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_openTip];
    
    self.openSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 420, 100, 40)];
    [self.view addSubview:self.openSwitch];
    
    // 设置页面元素的初始值为从 alarmModel 中获取的值
    self.nameTextField.text = self.alarmModel.alarmName;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:self.alarmModel.alarmHour];
    [components setMinute:self.alarmModel.alarmMinute];
    self.timePicker.date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    self.openSwitch.on = self.alarmModel.isOn;
    
    _repeatOptionsTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 500, 100, 30)];
    _repeatOptionsTip.text = @"Repeat Options";
    _repeatOptionsTip.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_repeatOptionsTip];
    
    CGFloat width = 80;
    self.mondayBtn.frame = CGRectMake(40, 540, width, 30);
    self.tuesdayBtn.frame = CGRectMake(CGRectGetMaxX(self.mondayBtn.frame) + 10, 540, width, 30);
    
    self.wednesdayBtn.frame = CGRectMake(40, 580, width, 30);
    self.thursdayBtn.frame = CGRectMake(CGRectGetMaxX(self.mondayBtn.frame) + 10, 580, width, 30);
    
    self.fridayBtn.frame = CGRectMake(40, 620, width, 30);
    self.saturdayBtn.frame = CGRectMake(CGRectGetMaxX(self.mondayBtn.frame) + 10, 620, width, 30);
    
    self.sundayBtn.frame = CGRectMake(40, 660, width, 30);
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:@"Save" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 5;
    [addBtn setBackgroundColor:[UIColor blueColor]];
    [addBtn addTarget:self action:@selector(saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    addBtn.frame = CGRectMake(20, 720,CGRectGetWidth(self.view.frame) - 40, 44);
    [self.view addSubview:addBtn];
    
    [self reloadRepeatOpions];
}

- (void)saveButtonTapped {
    if (self.nameTextField.text.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Alarms name cannot be empty"];
        return;
    }
    // 当用户点击保存按钮时，获取并保存页面元素的新值到 alarmModel 中
    WMAlarmModel *model = [[WMAlarmModel alloc] init];
    model.alarmName = self.nameTextField.text;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.timePicker.date];
    model.alarmHour = [components hour];
    model.alarmMinute = [components minute];
    model.isOn = self.openSwitch.isOn;
    model.repeatOptions =  [self currentRepeatOpions];
    // 处理添加按钮点击事件，可以添加新的闹钟数据到self.alarms数组
    model.identifier = (self.alarmModel.identifier == nil ? 0:self.alarmModel.identifier);
    
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    if (self.alarmModel == nil){
        [[[WatchManager sharedInstance].currentValue.apps.alarmApp addAlarm:model] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Save Fail\n%@",error.description]];
        }];
        return;
    }
    [[[WatchManager sharedInstance].currentValue.apps.alarmApp updateAlarm:model] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Save Fail\n%@",error.description]];
    }];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
// 创建一个方法，将颜色转换为图像
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    // 创建一个图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充颜色
    [color setFill];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // 从图形上下文中获取图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return image;
}
-(void)reloadRepeatOpions{
    NSInteger repeatOptions = 0;
    if (self.alarmModel != nil){
        repeatOptions = self.alarmModel.repeatOptions;
    }
    self.mondayBtn.selected = repeatOptions & WMAlarmRepeatMonday;
    self.tuesdayBtn.selected = repeatOptions & WMAlarmRepeatTuesday;
    self.wednesdayBtn.selected = repeatOptions & WMAlarmRepeatWednesday;
    self.thursdayBtn.selected = repeatOptions & WMAlarmRepeatThursday;
    self.fridayBtn.selected = repeatOptions & WMAlarmRepeatFriday;
    self.saturdayBtn.selected = repeatOptions & WMAlarmRepeatSaturday;
    self.sundayBtn.selected = repeatOptions & WMAlarmRepeatSunday;
}
-(NSInteger)currentRepeatOpions{
    NSInteger repeatOptions = 0;
    
    // 检查每个按钮的选择状态并合并到repeatOptions中
    if (self.mondayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatMonday;
    }
    if (self.tuesdayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatTuesday;
    }
    if (self.wednesdayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatWednesday;
    }
    if (self.thursdayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatThursday;
    }
    if (self.fridayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatFriday;
    }
    if (self.saturdayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatSaturday;
    }
    if (self.sundayBtn.isSelected == YES) {
        repeatOptions |= WMAlarmRepeatSunday;
    }
    
    // repeatOptions 现在包含了所有选中的按钮对应的位标志
    return repeatOptions;
}
@end
