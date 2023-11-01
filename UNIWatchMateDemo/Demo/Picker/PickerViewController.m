//
//  PickerViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/17.
//

#import "PickerViewController.h"

@interface PickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) USWatchPickerDataType type;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) void (^doneBlock)(NSString *selectedValue);
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, strong) NSArray<NSString *> *data;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic,strong) NSString *tip;
@property (nonatomic,strong) NSString *unit;

@end

@implementation PickerViewController

- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height type:(USWatchPickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock{
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
- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height data:(NSArray *)data type:(USWatchPickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock{
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
        self.doneBlock = doneBlock;
        self.cancelBlock = cancelBlock;
        self.height = height;
        self.data = data;
    }
    return self;
}
- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height data:(NSArray *)data type:(USWatchPickerDataType)type tip:(NSString *)tip unit:(NSString *)unit doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock{
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
        self.doneBlock = doneBlock;
        self.cancelBlock = cancelBlock;
        self.height = height;
        self.data = data;
        self.unit = unit;
        self.tip = tip;
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
    NSUInteger dataIndex = [self dataIndexForValue:self.value];
    for (NSInteger i = 0; i < self.pickerView.numberOfComponents; i++) {
        [self.pickerView selectRow:dataIndex inComponent:i animated:NO];
    }
    self.view.backgroundColor = [UIColor whiteColor];
}

- (NSUInteger)dataIndexForValue:(NSString *)value {
    for (NSInteger i = 0; i < self.data.count; i++) {
        NSString *title = self.data[i];
        NSString *unit = [self unitForDataType:self.type];
        if ([title rangeOfString:value].location != NSNotFound){
            NSString *val = [title stringByReplacingOccurrencesOfString:unit withString:@""];
            if ([val isEqualToString:value]){
                return i;
            }
        }
    }
    return 0;
}

- (void)appendUI {
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.pickerView];
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
    self.pickerView.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame) + 20, screenWidth, pickerViewHeight);
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
    NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
    NSString *selectedValue = self.data[selectedRow];
    if (self.doneBlock) {
        NSString *unit = [self unitForDataType:self.type];
        NSString *val = [selectedValue stringByReplacingOccurrencesOfString:unit withString:@""];
        self.doneBlock(val);
    }
}

#pragma mark - UIPickerViewDataSource and UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.data[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50.0;
}

#pragma mark - Lazy Loading

- (NSArray<NSString *> *)data {
    if (!_data) {
        NSString *unit = [self unitForDataType:self.type];
        switch (self.type) {
            case USWatchPickerDataTypeSteps: {
                NSMutableArray<NSString *> *stepsData = [NSMutableArray array];
                for (NSInteger i = 1; i <= 50; i++) {
                    NSString *stepString = [NSString stringWithFormat:@"%ld%@", (long)i * 1000,unit];
                    [stepsData addObject:stepString];
                }
                _data = stepsData;
                break;
            }
            case USWatchPickerDataTypeCalories: {
                NSMutableArray<NSString *> *caloriesData = [NSMutableArray array];
                for (NSInteger i = 1; i <= 50; i++) {
                    NSString *calorieString = [NSString stringWithFormat:@"%ld%@", (long)i * 30 * 1000,unit];
                    [caloriesData addObject:calorieString];
                }
                _data = caloriesData;
                break;
            }
            case USWatchPickerDataTypeDistance: {
                NSMutableArray<NSString *> *distanceData = [NSMutableArray array];
                for (NSInteger i = 1; i <= 100; i++) {
                    NSString *distanceString = [NSString stringWithFormat:@"%.0f%@", (double)i * 1000,unit];
                    [distanceData addObject:distanceString];
                }
                _data = distanceData;
                break;
            }
            case USWatchPickerDataTypeHeight: {
                NSMutableArray<NSString *> *heightData = [NSMutableArray array];
                for (NSInteger i = 10; i <= 300; i++) {
                    NSString *heightString = [NSString stringWithFormat:@"%ldcm", (long)i];
                    [heightData addObject:heightString];
                }
                _data = heightData;
                break;
            }
            case USWatchPickerDataTypeWeight: {
                NSMutableArray<NSString *> *weightData = [NSMutableArray array];
                for (NSInteger i = 10; i <= 500; i++) {
                    NSString *weightString = [NSString stringWithFormat:@"%ldkg", (long)i];
                    [weightData addObject:weightString];
                }
                _data = weightData;
                break;
            }
            case USWatchPickerDataTypeBirthday: {
                NSMutableArray<NSString *> *birthdayData = [NSMutableArray array];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
                NSInteger currentYear = [components year];
                for (NSInteger i = 1900; i <= currentYear; i++) {
                    NSString *birthdayString = [NSString stringWithFormat:@"%ld年", (long)i];
                    [birthdayData addObject:birthdayString];
                }
                _data = birthdayData;
                break;
            }
            case USWatchPickerDataTypeMenstrualLength: {
                NSMutableArray<NSString *> *caloriesData = [NSMutableArray array];
                for (NSInteger i = 3; i <= 15; i++) {
                    NSString *calorieString = [NSString stringWithFormat:@"%ld%@", (long)i,unit];
                    [caloriesData addObject:calorieString];
                }
                _data = caloriesData;
                break;
            }
            case USWatchPickerDataTypeMenstrualCycleLength: {
                NSMutableArray<NSString *> *caloriesData = [NSMutableArray array];
                for (NSInteger i = 17; i <= 60; i++) {
                    NSString *calorieString = [NSString stringWithFormat:@"%ld%@", (long)i,unit];
                    [caloriesData addObject:calorieString];
                }
                _data = caloriesData;
                break;
            }
            case USWatchPickerDataTypeMenstrualStartReminder: {
                NSMutableArray<NSString *> *caloriesData = [NSMutableArray array];
                for (NSInteger i = 1; i <= 3; i++) {
                    NSString *calorieString = [NSString stringWithFormat:@"%ld%@", (long)i,unit];
                    [caloriesData addObject:calorieString];
                }
                _data = caloriesData;
                break;
            }
            case USWatchPickerDataTypeMenstrualReminderTime: {
                NSMutableArray<NSString *> *caloriesData = [NSMutableArray array];
                for (NSInteger i = 0; i <= 23; i++) {
                    NSString *calorieString = [NSString stringWithFormat:@"%02ld%@", (long)i,unit];
                    [caloriesData addObject:calorieString];
                }
                _data = caloriesData;
                break;
            }
            case  USWatchPickerDataTypeLanguage:{
                break;
            }
            case  USWatchPickerDataTypeCustomer:{
                break;
            }
            case USWatchPickerDataTypeActivityDuration: {
                NSMutableArray<NSString *> *caloriesData = [NSMutableArray array];
                for (NSInteger i = 1; i <= 200; i++) {
                    NSString *calorieString = [NSString stringWithFormat:@"%ld%@", (long)i,unit];
                    [caloriesData addObject:calorieString];
                }
                _data = caloriesData;
                break;
            }
        }
    }
    return _data;
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
- (UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}
- (NSString *)titleForDataType:(USWatchPickerDataType)dataType {
    switch (dataType) {
        case USWatchPickerDataTypeSteps:
            return @"exercise goal step";
        case USWatchPickerDataTypeCalories:
            return @"exercise goal calories";
        case USWatchPickerDataTypeDistance:
            return @"exercise goal distance";
        case USWatchPickerDataTypeHeight:
            return @"height";
        case USWatchPickerDataTypeWeight:
            return @"weight";
        case USWatchPickerDataTypeBirthday:
            return @"birthday";
        case USWatchPickerDataTypeMenstrualLength:
            return NSLocalizedString(@"wh_menstruation_duration", nil);
        case USWatchPickerDataTypeMenstrualCycleLength:
            return NSLocalizedString(@"wh_menstruation_cycle", nil);
        case USWatchPickerDataTypeMenstrualStartReminder:
            return NSLocalizedString(@"wh_menstruation_advance", nil);
        case USWatchPickerDataTypeMenstrualReminderTime:
            return NSLocalizedString(@"wh_remind_time", nil);
        case USWatchPickerDataTypeLanguage:
            return NSLocalizedString(@"select language", nil);
        case USWatchPickerDataTypeCustomer:
            return _tip;
        case USWatchPickerDataTypeActivityDuration:
            return NSLocalizedString(@"select activity duration", nil);
    }
}
- (NSString *)unitForDataType:(USWatchPickerDataType)dataType {
    switch (dataType) {
        case USWatchPickerDataTypeSteps:
            return @"";
        case USWatchPickerDataTypeCalories:
            return @"calories";
        case USWatchPickerDataTypeDistance:
            return @"meter";
        case USWatchPickerDataTypeHeight:
            return @"cm";
        case USWatchPickerDataTypeWeight:
            return @"kg";
        case USWatchPickerDataTypeBirthday:
            return NSLocalizedString(@"unit_step", nil);
        case USWatchPickerDataTypeMenstrualLength:
            return NSLocalizedString(@"unit_day_count", nil);
        case USWatchPickerDataTypeMenstrualCycleLength:
            return NSLocalizedString(@"unit_day_count", nil);
        case USWatchPickerDataTypeMenstrualStartReminder:
            return NSLocalizedString(@"unit_day_count", nil);
        case USWatchPickerDataTypeMenstrualReminderTime:
            return @":00";
        case USWatchPickerDataTypeLanguage:
            return NSLocalizedString(@"", nil);
        case USWatchPickerDataTypeCustomer:
            return _unit;
        case USWatchPickerDataTypeActivityDuration:
            return NSLocalizedString(@"minutes", nil);
    }
}

@end
