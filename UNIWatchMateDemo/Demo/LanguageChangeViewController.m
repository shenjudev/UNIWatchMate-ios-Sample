//
//  LanguageChangeViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/20.
//

#import "LanguageChangeViewController.h"


@interface LanguageChangeViewController ()
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UIButton *getNowBtn;
@property (nonatomic, strong) UIButton *changelangBtn;
@property (nonatomic, strong) PickerViewController *pickerVC;
@property (nonatomic, strong) LSTPopView *popView;

@end

@implementation LanguageChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Language Change";
    self.view.backgroundColor = [UIColor whiteColor];
    self.getNowBtn.frame = CGRectMake(20, 320, CGRectGetWidth(self.view.frame) - 40, 44);
    self.changelangBtn.frame = CGRectMake(20, 380, CGRectGetWidth(self.view.frame) - 40, 44);
    [self getDetail];
    [self listen];
    
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
-(UIButton *)changelangBtn{
    if (_changelangBtn == nil){
        _changelangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changelangBtn setTitle:@"Change language" forState:UIControlStateNormal];
        [_changelangBtn addTarget:self action:@selector(showStringPicker) forControlEvents:UIControlEventTouchUpInside];
        _changelangBtn.layer.masksToBounds = YES;
        _changelangBtn.layer.cornerRadius = 5;
        [_changelangBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_changelangBtn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_changelangBtn];
    }
    return _changelangBtn;
}
-(void)getDetail{
    self.detail.text = @"";
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.settings.language.getConfigModel subscribeNext:^(WMLanguageModel * _Nullable x) {
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
    [[WatchManager sharedInstance].currentValue.settings.language.model subscribeNext:^(WMLanguageModel * _Nullable x) {
        @strongify(self);
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {

    }];
}
-(void)showInfo:(WMLanguageModel *)x{
    if (x == nil){
        self.data = nil;
        self.detail.text = nil;
        return ;
    }
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"current:%@\n\n",x.language];
    [string appendFormat:@"supported:%@",[x.languages componentsJoinedByString:@"  "]];
    self.detail.text = string;
    self.data = x.languages;
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)showStringPicker {
    
    @weakify(self);
    self.pickerVC = [[PickerViewController alloc] initWithValue:self.data.firstObject height:300.0 data:self.data type:USWatchPickerDataTypeLanguage doneBlock:^(NSString * _Nonnull BCD) {
        @strongify(self);
        [self setBCD:BCD];
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
-(void)setBCD:(NSString *)BCD{
    [SVProgressHUD showWithStatus:nil];
    WMLanguageModel *wMLanguageModel = [WMLanguageModel new];
    wMLanguageModel.language = BCD;
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.language setConfigModel:wMLanguageModel] subscribeNext:^(WMLanguageModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showInfo:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];
}
@end
