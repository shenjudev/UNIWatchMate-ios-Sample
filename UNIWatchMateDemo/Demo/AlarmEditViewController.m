//
//  AlarmEditViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/19.
//

#import "AlarmEditViewController.h"

@interface AlarmEditViewController () <UIScrollViewDelegate>
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
@property (nonatomic, strong) UIScrollView *uiScrollView;


@end

@implementation AlarmEditViewController

- (UIButton *)mondayBtn {
    if (_mondayBtn == nil) {
        _mondayBtn = [self createButtonWithTitle:NSLocalizedString(@"Monday", nil) tag:1];
        [self.uiScrollView addSubview:_mondayBtn];
    }
    return _mondayBtn;
}

- (UIButton *)tuesdayBtn {
    if (_tuesdayBtn == nil) {
        _tuesdayBtn = [self createButtonWithTitle:NSLocalizedString(@"Tuesday", nil) tag:2];
        [self.uiScrollView addSubview:_tuesdayBtn];
    }
    return _tuesdayBtn;
}

- (UIButton *)wednesdayBtn {
    if (_wednesdayBtn == nil) {
        _wednesdayBtn = [self createButtonWithTitle:NSLocalizedString(@"Wednesday", nil) tag:3];
        [self.uiScrollView addSubview:_wednesdayBtn];
    }
    return _wednesdayBtn;
}

- (UIButton *)thursdayBtn {
    if (_thursdayBtn == nil) {
        _thursdayBtn = [self createButtonWithTitle:NSLocalizedString(@"Thursday", nil) tag:4];
        [self.uiScrollView addSubview:_thursdayBtn];
    }
    return _thursdayBtn;
}

- (UIButton *)fridayBtn {
    if (_fridayBtn == nil) {
        _fridayBtn = [self createButtonWithTitle:NSLocalizedString(@"Friday", nil) tag:5];
        [self.uiScrollView addSubview:_fridayBtn];
    }
    return _fridayBtn;
}

- (UIButton *)saturdayBtn {
    if (_saturdayBtn == nil) {
        _saturdayBtn = [self createButtonWithTitle:NSLocalizedString(@"Saturday", nil) tag:6];
        [self.uiScrollView addSubview:_saturdayBtn];
    }
    return _saturdayBtn;
}

- (UIButton *)sundayBtn {
    if (_sundayBtn == nil) {
        _sundayBtn = [self createButtonWithTitle:NSLocalizedString(@"Sunday", nil) tag:7];
        [self.uiScrollView addSubview:_sundayBtn];
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
    self.title = NSLocalizedString(@"Alarm Edit", nil);
    
    self.uiScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.uiScrollView.backgroundColor = [UIColor whiteColor];

    // 假设我们要滚动的内容高度是900
    self.uiScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 800);
    self.uiScrollView.delegate = self;
    [self.view addSubview:self.uiScrollView];
    // 确保子视图允许用户交互
       self.uiScrollView.userInteractionEnabled = YES;

       // 创建 UITapGestureRecognizer 实例
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    tapRecognizer.cancelsTouchesInView = NO; // 确保触摸事件可以继续传递给子视图
    [self.uiScrollView addGestureRecognizer:tapRecognizer];
    // 现在可以在scrollView上添加其他视图，如UILabels, UIImageViews等
    
    // 创建和布局页面元素，包括文本字段、日期选择器和开关
    _nameTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame) - 40, 30)];
    _nameTip.text = NSLocalizedString(@"Name", nil);
    [self.uiScrollView addSubview:_nameTip];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 50, CGRectGetWidth(self.view.frame) - 40, 40)];
    self.nameTextField.placeholder = NSLocalizedString(@"Alarm name", nil);
    [self.uiScrollView addSubview:self.nameTextField];
    
    
    _timeTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 30)];
    _timeTip.text = NSLocalizedString(@"Time", nil);
    [self.uiScrollView addSubview:_timeTip];
    
    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(20, 130, CGRectGetWidth(self.view.frame) - 40, 200)];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    if (@available(iOS 13.4, *)) {
        [self.timePicker setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    }
    [self.uiScrollView addSubview:self.timePicker];
    
    _openTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 340, 100, 30)];
    _openTip.text = NSLocalizedString(@"Enable", nil);
    _openTip.adjustsFontSizeToFitWidth = YES;
    [self.uiScrollView addSubview:_openTip];
    
    self.openSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 340, 100, 40)];
    [self.uiScrollView addSubview:self.openSwitch];
    
    // 设置页面元素的初始值为从 alarmModel 中获取的值
    self.nameTextField.text = self.alarmModel.alarmName;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:self.alarmModel.alarmHour];
    [components setMinute:self.alarmModel.alarmMinute];
    self.timePicker.date = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    self.openSwitch.on = self.alarmModel.isOn;
    
    _repeatOptionsTip = [[UILabel alloc] initWithFrame:CGRectMake(20, 420, 100, 30)];
    _repeatOptionsTip.text = NSLocalizedString(@"Repeat Options", nil);
    _repeatOptionsTip.adjustsFontSizeToFitWidth = YES;
    [self.uiScrollView addSubview:_repeatOptionsTip];
    
    CGFloat width = 80;
    self.mondayBtn.frame = CGRectMake(40, 460, width, 30);
    self.tuesdayBtn.frame = CGRectMake(CGRectGetMaxX(self.mondayBtn.frame) + 10, 460, width, 30);
    
    self.wednesdayBtn.frame = CGRectMake(40, 500, width, 30);
    self.thursdayBtn.frame = CGRectMake(CGRectGetMaxX(self.mondayBtn.frame) + 10, 500, width, 30);
    
    self.fridayBtn.frame = CGRectMake(40, 540, width, 30);
    self.saturdayBtn.frame = CGRectMake(CGRectGetMaxX(self.mondayBtn.frame) + 10, 540, width, 30);
    
    self.sundayBtn.frame = CGRectMake(40, 660, width, 30);
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 5;
    [addBtn setBackgroundColor:[UIColor blueColor]];
    [addBtn addTarget:self action:@selector(saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    addBtn.frame = CGRectMake(20, 600,CGRectGetWidth(self.view.frame) - 40, 44);
    [self.uiScrollView addSubview:addBtn];
    
    [self reloadRepeatOpions];
}
- (void)scrollViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    // 当 UIScrollView 被点击时，结束编辑以关闭键盘
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)saveButtonTapped {
    if (self.nameTextField.text.length == 0){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Alarms name cannot be empty", nil)];
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
        [self.alarmModels addObject: model];
        
        [[[WatchManager sharedInstance].currentValue.apps.alarmApp syncAlarmList:self.alarmModels] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
            @strongify(self);
            [SVProgressHUD dismiss];
            if(self.completionHandler){
                self.completionHandler(@"");
            }
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Save Fail\n%@",error.description]];
        }];
        return;
    }
    self.alarmModel.alarmHour = model.alarmHour;
    self.alarmModel.alarmMinute = model.alarmMinute;
    self.alarmModel.isOn = model.isOn;
    self.alarmModel.repeatOptions = model.repeatOptions;
    self.alarmModel.identifier = model.identifier;
    [[[WatchManager sharedInstance].currentValue.apps.alarmApp syncAlarmList:self.alarmModels] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        if(self.completionHandler){
            self.completionHandler(@"");
        }
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
