//
//  DatePickerViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/19.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *tip;
@property (nonatomic, assign) DatePickerDataType type;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) void (^doneBlock)(NSString *selectedValue);
@property (nonatomic, copy) void (^cancelBlock)(void);

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *doneButton;
@end

@implementation DatePickerViewController

- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height type:(DatePickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock{
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
        self.doneBlock = doneBlock;
        self.cancelBlock = cancelBlock;
        self.height = height;
    }
    return self;
}
- (instancetype)initWithValue:(NSString *)value title:(NSString *)title height:(CGFloat)height type:(DatePickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock{
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
        self.doneBlock = doneBlock;
        self.cancelBlock = cancelBlock;
        self.height = height;
        self.tip = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setting];
    [self appendUI];
    [self actionsHandler];
}

- (void)setting {
    
    self.view.backgroundColor = [UIColor whiteColor];
}



- (void)appendUI {
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.datePicker];
    [self.view addSubview:self.doneButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat screenHeight = CGRectGetHeight(self.view.bounds);
    CGFloat topMargin = 18;
    CGFloat horizontalMargin = 16;
    CGFloat closeButtonWidth = 100;
    CGFloat closeButtonHeight= 44;

    self.titleLabel.frame = CGRectMake(screenWidth / 2 - 100, topMargin, 200, closeButtonHeight);
    
    self.closeButton.frame = CGRectMake(horizontalMargin, topMargin, closeButtonWidth, closeButtonHeight);
    self.doneButton.frame = CGRectMake(screenWidth - closeButtonWidth - horizontalMargin, topMargin, closeButtonWidth, closeButtonHeight);

    self.lineView.frame = CGRectMake(0, CGRectGetMaxY(self.closeButton.frame) + topMargin, screenWidth, 1);
    
    CGFloat pickerViewHeight = 240;
    self.datePicker.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame) + 20, screenWidth, pickerViewHeight);
    self.view.frame = CGRectMake(0, screenHeight - self.height, screenWidth,self.height);
}


- (void)actionsHandler {
    [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeButtonTapped {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)doneButtonTapped {
    NSDate *selectedDate = self.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设置日期格式，例如: yyyy MM dd
    [dateFormatter setDateFormat:@"yyyy MM dd"];
    NSString *formattedDate = [dateFormatter stringFromDate:selectedDate];
    if (self.doneBlock) {
        self.doneBlock(formattedDate);
    }
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.text = [self titleForDataType:self.type];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    }
    return _closeButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor clearColor];
    }
    return _lineView;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.backgroundColor = [UIColor blueColor];
        [_doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _doneButton.layer.cornerRadius = 14;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}
- (UIDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate; // 选择日期模式
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"en"]; // 使用当前环境的语言和区域设置
        // 获取当前日期
        NSDate *currentDate = [NSDate date];

        // 获取10个月前的日期
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        if (_type == DatePickerDataTypeMostRecentMenstruation){
            [offsetComponents setMonth:-10];
        }else if (_type == DatePickerDataTypeBirthday){
            [offsetComponents setMonth:-150 * 12];
        }else{
            [offsetComponents setMonth:-150 * 12];
        }
        NSDate *tenMonthsAgo = [calendar dateByAddingComponents:offsetComponents toDate:currentDate options:0];

        // 设置最大和最小日期
        _datePicker.maximumDate = currentDate;
        _datePicker.minimumDate = tenMonthsAgo;
    }
    return _datePicker;
}
- (NSString *)titleForDataType:(DatePickerDataType)dataType {
    switch (dataType) {
        case DatePickerDataTypeMostRecentMenstruation:
            return NSLocalizedString(@"wh_menstruation_latest", nil);
        case DatePickerDataTypeBirthday:
            return NSLocalizedString(@"birthday", nil);
        case DatePickerDataTypeCustom:
            return _tip;

    }
}


@end
