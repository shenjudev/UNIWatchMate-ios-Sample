//
//  EditUserInfoViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/24.
//

#import "EditUserInfoViewController.h"
NSString *NSStringFromGender(Gender gender)
{
    switch (gender) {
        case GenderMale:
            return @"GenderMale";
        case GenderFemale:
            return @"GenderFemale";
        case GenderOther:
            return @"GenderOther";
    }
}

@interface EditUserInfoViewController ()
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIButton *changHeight;
@property (nonatomic, strong) UIButton *changeWeight;
@property (nonatomic, strong) UIButton *changeGender;
@property (nonatomic, strong) UIButton *changeBirthDate;
@property (nonatomic, strong) PickerViewController *pickerVC;
@property (nonatomic, strong) LSTPopView *popView;
@property (nonatomic, strong) UIButton *getNowBtn;

@property (nonatomic, strong) NSArray *genders;
@property (nonatomic, strong) DatePickerViewController *datePicker;
@property (nonatomic, strong) WMPersonalInfoModel *wMPersonalInfoModel;
@end

@implementation EditUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"User info", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self getDetail];

    self.getNowBtn.frame = CGRectMake(20, 320, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changHeight.frame = CGRectMake(20, 380, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeWeight.frame = CGRectMake(20, 440, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeGender.frame = CGRectMake(20, 500, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeBirthDate.frame = CGRectMake(20, 560, CGRectGetWidth(self.view.frame) - 40, 44);
    self.wMPersonalInfoModel = [WMPersonalInfoModel new];
    self.wMPersonalInfoModel.height = 170;
    self.wMPersonalInfoModel.weight = 70;
    self.wMPersonalInfoModel.gender = GenderMale;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *dateString = @"19950709";
    NSDate *date = [dateFormatter dateFromString:dateString];
    self.wMPersonalInfoModel.birthDate = date;
    
    _genders = @[
        NSStringFromGender(GenderMale),
        NSStringFromGender(GenderFemale),
        NSStringFromGender(GenderOther),

    ];
}

-(UIButton *)getNowBtn{
    if (_getNowBtn == nil){
        _getNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getNowBtn setTitle:NSLocalizedString(@"Get Now", nil) forState:UIControlStateNormal];
        [_getNowBtn addTarget:self action:@selector(getDetail) forControlEvents:UIControlEventTouchUpInside];
        _getNowBtn.layer.masksToBounds = YES;
        _getNowBtn.layer.cornerRadius = 5;
        [_getNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getNowBtn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_getNowBtn];
    }
    return _getNowBtn;
}

-(void)getDetail{
    self.detail.text = @"";
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.settings.personalInfo.getConfigModel subscribeNext:^(WMPersonalInfoModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        _wMPersonalInfoModel = x;
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
    }];
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

-(void)showInfo:(WMPersonalInfoModel *)x{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"height: %ld cm\n",(long)x.height];
    [string appendFormat:@"weight: %.0ld kg\n",(long)x.weight];
    [string appendFormat:@"gender: %@\n",NSStringFromGender(x.gender)];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy.MM.dd";
    NSString *dateStr = [formatter stringFromDate:x.birthDate];
    [string appendFormat:@"birthDate: %@\n",dateStr];

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

-(UIButton *)changHeight{
    if (_changHeight == nil){
        _changHeight = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changHeight setTitle:NSLocalizedString(@"Change height", nil) forState:UIControlStateNormal];
        [_changHeight addTarget:self action:@selector(actionChangeHeight) forControlEvents:UIControlEventTouchUpInside];
        _changHeight.layer.masksToBounds = YES;
        _changHeight.layer.cornerRadius = 5;
        [_changHeight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changHeight setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changHeight];
    }
    return _changHeight;
}
-(void)actionChangeHeight{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:@"30" height:300.0 type:USWatchPickerDataTypeHeight doneBlock:^(NSString * _Nonnull uesrHeight){
        @strongify(self);
        [self actionChangeHeight:uesrHeight];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //PopViiew specifies the parent container self.view, not app window by default
    self.popView = [LSTPopView initWithCustomView:self.pickerVC.view
                                       parentView:self.view
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
    //Pop-up window position: center stick top stick left stick bottom stick right
    self.popView.hemStyle = LSTHemStyleBottom;
    //Click background trigger
    self.popView.bgClickBlock = ^{
        @strongify(self);
        self.pickerVC = nil;
        [ self.popView dismiss];
    };
    //Pop-up display
    [self.popView pop];
}
-(void)actionChangeHeight:(NSString *) uesrHeight{
    [SVProgressHUD showWithStatus:nil];
    if ( _wMPersonalInfoModel == nil){
        [SVProgressHUD dismiss];
        return;
    }
    @weakify(self);
    _wMPersonalInfoModel.height = uesrHeight.integerValue;
    [[[WatchManager sharedInstance].currentValue.settings.personalInfo setConfigModel:_wMPersonalInfoModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:self.wMPersonalInfoModel];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeWeight{
    if (_changeWeight == nil){
        _changeWeight = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeWeight setTitle:NSLocalizedString(@"Change weight", nil) forState:UIControlStateNormal];
        [_changeWeight addTarget:self action:@selector(actionChangeWeight) forControlEvents:UIControlEventTouchUpInside];
        _changeWeight.layer.masksToBounds = YES;
        _changeWeight.layer.cornerRadius = 5;
        [_changeWeight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeWeight setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeWeight];
    }
    return _changeWeight;
}

-(void)actionChangeWeight{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:@"30" height:300.0 type:USWatchPickerDataTypeWeight doneBlock:^(NSString * _Nonnull weight){
        @strongify(self);
        [self actionChangeWeight:weight];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //PopViiew specifies the parent container self.view, not app window by default
    _popView = [LSTPopView initWithCustomView:self.pickerVC.view
                                       parentView:self.view
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
    //Pop-up window position: center stick top stick left stick bottom stick right
    self.popView.hemStyle = LSTHemStyleBottom;
    //Click background trigger
    self.popView.bgClickBlock = ^{
        @strongify(self);
        self.pickerVC = nil;
        [ self.popView dismiss];
    };
    //Pop-up display
    [self.popView pop];
}

-(void)actionChangeWeight:(NSString *) weight{
    [SVProgressHUD showWithStatus:nil];
    if ( _wMPersonalInfoModel == nil){
        [SVProgressHUD dismiss];
        return;
    }
    @weakify(self);
    _wMPersonalInfoModel.weight = weight.integerValue;
    [[[WatchManager sharedInstance].currentValue.settings.personalInfo setConfigModel:_wMPersonalInfoModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:self.wMPersonalInfoModel];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeGender{
    if (_changeGender == nil){
        _changeGender = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeGender setTitle:NSLocalizedString(@"Change gender", nil) forState:UIControlStateNormal];
        [_changeGender addTarget:self action:@selector(actionChangeGender) forControlEvents:UIControlEventTouchUpInside];
        _changeGender.layer.masksToBounds = YES;
        _changeGender.layer.cornerRadius = 5;
        [_changeGender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeGender setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeGender];
    }
    return _changeGender;
}

-(void)actionChangeGender{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:self.genders.firstObject height:300.0 data:self.genders type:USWatchPickerDataTypeCustomer tip:@"gender" unit:@"" doneBlock:^(NSString * _Nonnull gender){
        @strongify(self);
        [self actionChangeGender:gender];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //PopViiew specifies the parent container self.view, not app window by default
    _popView = [LSTPopView initWithCustomView:self.pickerVC.view
                                       parentView:self.view
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
    //Pop-up window position: center stick top stick left stick bottom stick right
    self.popView.hemStyle = LSTHemStyleBottom;
    //Click background trigger
    self.popView.bgClickBlock = ^{
        @strongify(self);
        self.pickerVC = nil;
        [ self.popView dismiss];
    };
    //Pop-up display
    [self.popView pop];
}

-(void)actionChangeGender:(NSString *) gender{
    [SVProgressHUD showWithStatus:nil];
    if ( _wMPersonalInfoModel == nil){
        [SVProgressHUD dismiss];
        return;
    }
    @weakify(self);
    _wMPersonalInfoModel.gender = [self.genders indexOfObject:gender];
    [[[WatchManager sharedInstance].currentValue.settings.personalInfo setConfigModel:_wMPersonalInfoModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:self.wMPersonalInfoModel];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeBirthDate{
    if (_changeBirthDate == nil){
        _changeBirthDate = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeBirthDate setTitle:NSLocalizedString(@"Change birth date", nil) forState:UIControlStateNormal];
        [_changeBirthDate addTarget:self action:@selector(actionChangeBirthDate) forControlEvents:UIControlEventTouchUpInside];
        _changeBirthDate.layer.masksToBounds = YES;
        _changeBirthDate.layer.cornerRadius = 5;
        [_changeBirthDate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeBirthDate setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeBirthDate];
    }
    return _changeBirthDate;
}

-(void)actionChangeBirthDate{

    @weakify(self);
    _datePicker = [[DatePickerViewController alloc] initWithValue:@"" height:300.0 type:DatePickerDataTypeBirthday doneBlock:^(NSString * _Nonnull birthday) {
        @strongify(self);
        [self actionChangeBirthDate:birthday];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //PopViiew specifies the parent container self.view, not app window by default
    _popView = [LSTPopView initWithCustomView:self.datePicker.view
                                       parentView:self.view
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
    //Pop-up window position: center stick top stick left stick bottom stick right
    self.popView.hemStyle = LSTHemStyleBottom;
    //Click background trigger
    self.popView.bgClickBlock = ^{
        @strongify(self);
        self.pickerVC = nil;
        [ self.popView dismiss];
    };
    //Pop-up display
    [self.popView pop];
}

-(void)actionChangeBirthDate:(NSString *) birthday{
    [SVProgressHUD showWithStatus:nil];
    if ( _wMPersonalInfoModel == nil){
        [SVProgressHUD dismiss];
        return;
    }
    @weakify(self);

    NSString *dateFormat = @"yyyy MM dd"; // Enter a date string format. Change the format based on site requirements
    // Create an NSDateFormatter object and format the date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    // Convert a string to NSDate using a date formatter
    NSDate *date = [dateFormatter dateFromString:birthday];
    _wMPersonalInfoModel.birthDate = date;
    [[[WatchManager sharedInstance].currentValue.settings.personalInfo setConfigModel:_wMPersonalInfoModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:self.wMPersonalInfoModel];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

@end
