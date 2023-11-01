//
//  ExerciseGoalViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/24.
//

#import "ExerciseGoalViewController.h"

@interface ExerciseGoalViewController ()
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIButton *changSteps;
@property (nonatomic, strong) UIButton *changeCalories;
@property (nonatomic, strong) UIButton *changeDistance;
@property (nonatomic, strong) UIButton *changeActivityDuration;
@property (nonatomic, strong) PickerViewController *pickerVC;
@property (nonatomic, strong) LSTPopView *popView;
@property (nonatomic, strong) UIButton *getNowBtn;

@end

@implementation ExerciseGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Exercise goal";
    self.view.backgroundColor = [UIColor whiteColor];
    [self getDetail];

    self.getNowBtn.frame = CGRectMake(20, 320, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changSteps.frame = CGRectMake(20, 380, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeCalories.frame = CGRectMake(20, 440, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeDistance.frame = CGRectMake(20, 500, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changeActivityDuration.frame = CGRectMake(20, 560, CGRectGetWidth(self.view.frame) - 40, 44);
}

-(UIButton *)getNowBtn{
    if (_getNowBtn == nil){
        _getNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getNowBtn setTitle:@"Get Now" forState:UIControlStateNormal];
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
    [[WatchManager sharedInstance].currentValue.settings.sportGoal.getConfigModel subscribeNext:^(WMSportGoalModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
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

-(void)showInfo:(WMSportGoalModel *)x{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"steps: %ld\n",(long)x.steps];
    [string appendFormat:@"calories: %.0f calories\n",x.calories];
    [string appendFormat:@"distance: %.0f meter\n",x.distance];
    [string appendFormat:@"activityDuration: %ld minutes\n",x.activityDuration];

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

-(UIButton *)changSteps{
    if (_changSteps == nil){
        _changSteps = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changSteps setTitle:@"Change steps" forState:UIControlStateNormal];
        [_changSteps addTarget:self action:@selector(actionChangeSteps) forControlEvents:UIControlEventTouchUpInside];
        _changSteps.layer.masksToBounds = YES;
        _changSteps.layer.cornerRadius = 5;
        [_changSteps setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changSteps setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changSteps];
    }
    return _changSteps;
}
-(void)actionChangeSteps{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:@"1000" height:300.0 type:USWatchPickerDataTypeSteps doneBlock:^(NSString * _Nonnull steps){
        @strongify(self);
        [self actionChangeSteps:steps];
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
-(void)actionChangeSteps:(NSString *) steps{
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    WMSportGoalModel *wMSportGoalModel = [WatchManager sharedInstance].currentValue.settings.sportGoal.modelValue;
    wMSportGoalModel.steps = steps.integerValue;
    [[[WatchManager sharedInstance].currentValue.settings.sportGoal setConfigModel:wMSportGoalModel] subscribeNext:^(WMSportGoalModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeCalories{
    if (_changeCalories == nil){
        _changeCalories = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeCalories setTitle:@"Change calories" forState:UIControlStateNormal];
        [_changeCalories addTarget:self action:@selector(actionChangeCalories) forControlEvents:UIControlEventTouchUpInside];
        _changeCalories.layer.masksToBounds = YES;
        _changeCalories.layer.cornerRadius = 5;
        [_changeCalories setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeCalories setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeCalories];
    }
    return _changeCalories;
}

-(void)actionChangeCalories{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:@"30" height:300.0 type:USWatchPickerDataTypeCalories doneBlock:^(NSString * _Nonnull calories){
        @strongify(self);
        [self actionChangeCalories:calories];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //创建弹窗PopViiew 指定父容器self.view, 不指定默认是app window
    _popView = [LSTPopView initWithCustomView:self.pickerVC.view
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

-(void)actionChangeCalories:(NSString *) calories{
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    WMSportGoalModel *wMSportGoalModel = [WatchManager sharedInstance].currentValue.settings.sportGoal.modelValue;
    wMSportGoalModel.calories = calories.integerValue;
    [[[WatchManager sharedInstance].currentValue.settings.sportGoal setConfigModel:wMSportGoalModel] subscribeNext:^(WMSportGoalModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeDistance{
    if (_changeDistance == nil){
        _changeDistance = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeDistance setTitle:@"Change distance" forState:UIControlStateNormal];
        [_changeDistance addTarget:self action:@selector(actionChangeDistance) forControlEvents:UIControlEventTouchUpInside];
        _changeDistance.layer.masksToBounds = YES;
        _changeDistance.layer.cornerRadius = 5;
        [_changeDistance setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeDistance setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeDistance];
    }
    return _changeDistance;
}

-(void)actionChangeDistance{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:@"1.0" height:300.0 type:USWatchPickerDataTypeDistance doneBlock:^(NSString * _Nonnull distance){
        @strongify(self);
        [self actionChangeDistance:distance];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //创建弹窗PopViiew 指定父容器self.view, 不指定默认是app window
    _popView = [LSTPopView initWithCustomView:self.pickerVC.view
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

-(void)actionChangeDistance:(NSString *) distance{
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    WMSportGoalModel *wMSportGoalModel = [WatchManager sharedInstance].currentValue.settings.sportGoal.modelValue;
    wMSportGoalModel.distance = distance.integerValue;
    [[[WatchManager sharedInstance].currentValue.settings.sportGoal setConfigModel:wMSportGoalModel] subscribeNext:^(WMSportGoalModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}

-(UIButton *)changeActivityDuration{
    if (_changeActivityDuration == nil){
        _changeActivityDuration = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeActivityDuration setTitle:@"Change activity duration" forState:UIControlStateNormal];
        [_changeActivityDuration addTarget:self action:@selector(actionChangeActivityDuration) forControlEvents:UIControlEventTouchUpInside];
        _changeActivityDuration.layer.masksToBounds = YES;
        _changeActivityDuration.layer.cornerRadius = 5;
        [_changeActivityDuration setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changeActivityDuration setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changeActivityDuration];
    }
    return _changeActivityDuration;
}

-(void)actionChangeActivityDuration{

    @weakify(self);
    _pickerVC = [[PickerViewController alloc] initWithValue:@"1" height:300.0 type:USWatchPickerDataTypeActivityDuration doneBlock:^(NSString * _Nonnull distance){
        @strongify(self);
        [self actionChangeActivityDuration:distance];
        self.pickerVC = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.pickerVC = nil;
        [self.popView dismiss];
    }];

    //创建弹窗PopViiew 指定父容器self.view, 不指定默认是app window
    _popView = [LSTPopView initWithCustomView:self.pickerVC.view
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

-(void)actionChangeActivityDuration:(NSString *) activityDuration{
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    WMSportGoalModel *wMSportGoalModel = [WatchManager sharedInstance].currentValue.settings.sportGoal.modelValue;
    wMSportGoalModel.activityDuration = activityDuration.integerValue;
    [[[WatchManager sharedInstance].currentValue.settings.sportGoal setConfigModel:wMSportGoalModel] subscribeNext:^(WMSportGoalModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"set Fail\n%@",error.description]];
    }];
}
@end
