//
//  UnitSynchronizationViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/23.
//

#import "UnitSynchronizationViewController.h"
NSString *NSStringFromLengthUnit(LengthUnit lengthUnit) {
    switch (lengthUnit) {
        case LengthUnitKM:
            return @"LengthUnitKM";
        case LengthUnitMILE:
            return @"LengthUnitMILE";
    }
}

NSString *NSStringFromWeightUnit(WeightUnit weightUnit) {
    switch (weightUnit) {
        case WeightUnitKG:
            return @"WeightUnitKG";
        case WeightUnitLB:
            return @"WeightUnitLB";
    }
}

NSString *NSStringFromTemperatureUnit(TemperatureUnit temperatureUnit) {
    switch (temperatureUnit) {
        case TemperatureUnitCELSIUS:
            return @"TemperatureUnitCELSIUS";
        case TemperatureUnitFAHRENHEIT:
            return @"TemperatureUnitFAHRENHEIT";
    }
}

NSString *NSStringFromUnitTimeFormat(TimeFormat timeFormat) {
    switch (timeFormat) {
        case TimeFormatTWELVE_HOUR:
            return @"TimeFormatTWELVE_HOUR";
        case TimeFormatTWENTY_FOUR_HOUR:
            return @"TimeFormatTWENTY_FOUR_HOUR";
    }
}
@interface UnitSynchronizationViewController ()
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIButton *changeTimeFormat;
@property (nonatomic, strong) UIButton *changeTemperatureUnit;
@property (nonatomic, strong) UIButton *changeWeightUnit;
@property (nonatomic, strong) UIButton *changeLengthUnit;
@property (nonatomic, strong) PickerViewController *pickerVC;
@property (nonatomic, strong) LSTPopView *popView;

@property (nonatomic, strong) NSArray *timeFormat;
@property (nonatomic, strong) NSArray *temperatureUnit;
@property (nonatomic, strong) NSArray *weightUnit;
@property (nonatomic, strong) NSArray *lengthUnit;

@end

@implementation UnitSynchronizationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Unit synchronization";
    self.view.backgroundColor = [UIColor whiteColor];
    [self getDetail];

    self.changeTimeFormat.frame = CGRectMake(20, 320, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeTemperatureUnit.frame = CGRectMake(20, 380, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeLengthUnit.frame = CGRectMake(20, 440, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeWeightUnit.frame = CGRectMake(20, 500, CGRectGetWidth(self.view.frame) - 40, 44);


}
-(UILabel *)detail{
    if(_detail == nil){
        _detail = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 200)];
        _detail.adjustsFontSizeToFitWidth = true;
        _detail.numberOfLines = 0;
        _detail.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_detail];
    }
    return  _detail;
}

-(UIButton *)changeLengthUnit{
    if (_changeLengthUnit == nil){
        _changeLengthUnit = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeLengthUnit setTitle:@"Change length unit" forState:UIControlStateNormal];
        [_changeLengthUnit addTarget:self action:@selector(actionChangeLengthUnit) forControlEvents:UIControlEventTouchUpInside];
        _changeLengthUnit.layer.masksToBounds = YES;
        _changeLengthUnit.layer.cornerRadius = 5;
        [_changeLengthUnit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeLengthUnit setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeLengthUnit];
    }
    return _changeLengthUnit;
}
-(NSArray *)lengthUnit{
    if (_lengthUnit == nil){
        _lengthUnit = @[
            NSStringFromLengthUnit(LengthUnitKM),
            NSStringFromLengthUnit(LengthUnitMILE),
        ];
    }
    return  _lengthUnit;
}
-(void)actionChangeLengthUnit{

    @weakify(self);
    self.pickerVC = [[PickerViewController alloc] initWithValue:self.lengthUnit.firstObject height:300.0 data:self.lengthUnit type:USWatchPickerDataTypeLanguage tip:@"Length unit" unit:@"" doneBlock:^(NSString * _Nonnull x) {
        @strongify(self);
        [self actionChangeLengthUnit:[self.lengthUnit indexOfObject:x]];
        self.pickerVC = nil;
        [self.popView dismiss];
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
-(void)actionChangeLengthUnit:(NSInteger )lengthUnit{
    [SVProgressHUD showWithStatus:nil];
    WMUnitInfoModel *wMUnitInfoModel = [WMUnitInfoModel new];
    wMUnitInfoModel.lengthUnit = lengthUnit;
    self.detail.text = @"";
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.unitInfo setConfigModel:wMUnitInfoModel] subscribeNext:^(WMUnitInfoModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeTimeFormat{
    if (_changeTimeFormat == nil){
        _changeTimeFormat = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeTimeFormat setTitle:@"change time format" forState:UIControlStateNormal];
        [_changeTimeFormat addTarget:self action:@selector(actionChangeTimeFormat) forControlEvents:UIControlEventTouchUpInside];
        _changeTimeFormat.layer.masksToBounds = YES;
        _changeTimeFormat.layer.cornerRadius = 5;
        [_changeTimeFormat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeTimeFormat setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeTimeFormat];
    }
    return _changeTimeFormat;
}
-(NSArray *)timeFormat{
    if (_timeFormat == nil){
        _timeFormat = @[
            NSStringFromUnitTimeFormat(TimeFormatTWELVE_HOUR),
            NSStringFromUnitTimeFormat(TimeFormatTWENTY_FOUR_HOUR),
        ];
    }
    return  _timeFormat;
}
-(void)actionChangeTimeFormat{
    @weakify(self);
    self.pickerVC = [[PickerViewController alloc] initWithValue:self.timeFormat.firstObject height:300.0 data:self.timeFormat type:USWatchPickerDataTypeLanguage tip:@"Time format" unit:@"" doneBlock:^(NSString * _Nonnull x) {
        @strongify(self);
        [self actionTimeFormat:[self.timeFormat indexOfObject:x]];
        self.pickerVC = nil;
        [self.popView dismiss];
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
-(void)actionTimeFormat:(NSInteger )timeFormat{
    [SVProgressHUD showWithStatus:nil];
    WMUnitInfoModel *wMUnitInfoModel = [WatchManager sharedInstance].currentValue.settings.unitInfo.modelValue;
    wMUnitInfoModel.timeFormat = timeFormat;
    self.detail.text = @"";
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.unitInfo setConfigModel:wMUnitInfoModel] subscribeNext:^(WMUnitInfoModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];
}
-(UIButton *)changeWeightUnit{
    if (_changeWeightUnit == nil){
        _changeWeightUnit = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeWeightUnit setTitle:@"change weight unit" forState:UIControlStateNormal];
        [_changeWeightUnit addTarget:self action:@selector(actionChangeWeightUnit) forControlEvents:UIControlEventTouchUpInside];
        _changeWeightUnit.layer.masksToBounds = YES;
        _changeWeightUnit.layer.cornerRadius = 5;
        [_changeWeightUnit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeWeightUnit setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeWeightUnit];
    }
    return _changeWeightUnit;
}
-(NSArray *)weightUnit{
    if (_weightUnit == nil){
        _weightUnit = @[
            NSStringFromWeightUnit(WeightUnitKG),
            NSStringFromWeightUnit(WeightUnitLB),
        ];
    }
    return  _weightUnit;
}
-(void)actionChangeWeightUnit{
    @weakify(self);
    self.pickerVC = [[PickerViewController alloc] initWithValue:self.weightUnit.firstObject height:300.0 data:self.weightUnit type:USWatchPickerDataTypeLanguage tip:@"Weight unit" unit:@"" doneBlock:^(NSString * _Nonnull x) {
        @strongify(self);
        [self actionWeightUnit:[self.weightUnit indexOfObject:x]];
        self.pickerVC = nil;
        [self.popView dismiss];
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
-(void)actionWeightUnit:(NSInteger )weightUnit{
    [SVProgressHUD showWithStatus:nil];
    WMUnitInfoModel *wMUnitInfoModel = [WatchManager sharedInstance].currentValue.settings.unitInfo.modelValue;
    wMUnitInfoModel.weightUnit = weightUnit;
    self.detail.text = @"";
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.unitInfo setConfigModel:wMUnitInfoModel] subscribeNext:^(WMUnitInfoModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeTemperatureUnit{
    if (_changeTemperatureUnit == nil){
        _changeTemperatureUnit = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeTemperatureUnit setTitle:@"change temperature unit" forState:UIControlStateNormal];
        [_changeTemperatureUnit addTarget:self action:@selector(actionChangeTemperatureUnit) forControlEvents:UIControlEventTouchUpInside];
        _changeTemperatureUnit.layer.masksToBounds = YES;
        _changeTemperatureUnit.layer.cornerRadius = 5;
        [_changeTemperatureUnit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeTemperatureUnit setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeTemperatureUnit];
    }
    return _changeTemperatureUnit;
}
-(NSArray *)temperatureUnit{
    if (_temperatureUnit == nil){
        _temperatureUnit = @[
            NSStringFromTemperatureUnit(TemperatureUnitCELSIUS),
            NSStringFromTemperatureUnit(TemperatureUnitFAHRENHEIT),
        ];
    }
    return  _temperatureUnit;
}

-(void)actionChangeTemperatureUnit{
    @weakify(self);
    self.pickerVC = [[PickerViewController alloc] initWithValue:self.temperatureUnit.firstObject height:300.0 data:self.temperatureUnit type:USWatchPickerDataTypeLanguage tip:@"Temperature unit" unit:@"" doneBlock:^(NSString * _Nonnull x) {
        @strongify(self);
        [self actionTemperatureUnit:[self.temperatureUnit indexOfObject:x]];
        self.pickerVC = nil;
        [self.popView dismiss];
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
-(void)actionTemperatureUnit:(NSInteger )temperatureUnit{
    [SVProgressHUD showWithStatus:nil];
    WMUnitInfoModel *wMUnitInfoModel = [WatchManager sharedInstance].currentValue.settings.unitInfo.modelValue;
    wMUnitInfoModel.temperatureUnit = temperatureUnit;
    self.detail.text = @"";
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.unitInfo setConfigModel:wMUnitInfoModel] subscribeNext:^(WMUnitInfoModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];
}

-(void)getDetail{
    self.detail.text = @"";
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.settings.unitInfo.getConfigModel subscribeNext:^(WMUnitInfoModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
    }];
}
-(void)listen{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.settings.unitInfo.model subscribeNext:^(WMUnitInfoModel * _Nullable x) {
        @strongify(self);
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {

    }];
}
-(void)showInfo:(WMUnitInfoModel *)x{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"timeFormat:%@\n",NSStringFromUnitTimeFormat(x.timeFormat)];
    [string appendFormat:@"temperatureUnit:%@\n",NSStringFromTemperatureUnit(x.temperatureUnit)];
    [string appendFormat:@"lengthUnit:%@\n",NSStringFromLengthUnit(x.lengthUnit)];
    [string appendFormat:@"weightUnit:%@\n",NSStringFromWeightUnit(x.weightUnit)];

    self.detail.text = string;
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
