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
    NSInteger selectedDayTag = sender.tag;
    NSLog(@"选中了第 %ld 天", (long)selectedDayTag);
    
    sender.selected = !sender.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"Alarm Edit", nil);
    
    self.uiScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.uiScrollView.backgroundColor = [UIColor whiteColor];

    self.uiScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 800);
    self.uiScrollView.delegate = self;
    [self.view addSubview:self.uiScrollView];
       self.uiScrollView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.uiScrollView addGestureRecognizer:tapRecognizer];
    
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
    // When UIScrollView is clicked, end the editing to close the keyboard
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
    // When the user clicks the Save button, gets and saves the new value of the page element into the alarmModel
    WMAlarmModel *model = [[WMAlarmModel alloc] init];
    model.alarmName = self.nameTextField.text;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.timePicker.date];
    model.alarmHour = [components hour];
    model.alarmMinute = [components minute];
    model.isOn = self.openSwitch.isOn;
    model.repeatOptions =  [self currentRepeatOpions];
    // To handle the add button click event, you can add new alarm data to the self.alarms array
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
// Creates a method to convert colors to images
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    // Create a graphic context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Fill color
    [color setFill];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Get an image from a graphic context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // End graphic context
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
    
    // Check the selection status of each button and merge it into repeatOptions
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
    
    // repeatOptions The bit flags corresponding to all selected buttons are now included
    return repeatOptions;
}
@end
