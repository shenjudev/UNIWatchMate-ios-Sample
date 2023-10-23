//
//  OtaViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/23.
//

#import "OtaViewController.h"

@interface OtaViewController () <UIDocumentPickerDelegate>
@property (nonatomic, strong) UIButton *upgradeBtn;
@property (nonatomic, strong) UILabel *detail;

@end

@implementation OtaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Ota";
    self.view.backgroundColor = [UIColor whiteColor];

    self.upgradeBtn.frame = CGRectMake(20, 220, CGRectGetWidth(self.view.frame) - 40, 44);

    self.detail.text = [NSString stringWithFormat:@"Current version: %@",[WatchManager sharedInstance].currentValue.infoModel.baseinfoValue.version];
    [self monitorChange];
}

-(UILabel *)detail{
    if(_detail == nil){
        _detail = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, 100)];
        _detail.adjustsFontSizeToFitWidth = true;
        _detail.numberOfLines = 0;
        _detail.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_detail];
    }
    return  _detail;
}

-(UIButton *)upgradeBtn{
    if (_upgradeBtn == nil){
        _upgradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upgradeBtn setTitle:@"Upgrade now" forState:UIControlStateNormal];
        [_upgradeBtn addTarget:self action:@selector(upgrade) forControlEvents:UIControlEventTouchUpInside];
        _upgradeBtn.layer.masksToBounds = YES;
        _upgradeBtn.layer.cornerRadius = 5;
        [_upgradeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_upgradeBtn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_upgradeBtn];
    }
    return _upgradeBtn;
}

-(void)upgrade{
    // 创建文件选择器
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"]
                                                                                                                inMode:UIDocumentPickerModeOpen];
        documentPicker.delegate = self;

        // 弹出文件选择器
        [self presentViewController:documentPicker animated:YES completion:nil];
}
- (void)sendData:(NSURL *)path{
    @weakify(self)
    [[[WatchManager sharedInstance].currentValue.apps.fileApp startTransferFile:path fileType:WMActivityTypeDIAL] subscribeNext:^(WMProgressModel * _Nullable x) {
        [SVProgressHUD showProgress:x.progress / 100.0 status:[NSString stringWithFormat:@"Progress:%.2f%%",x.progress]];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Ota failed."];
    } completed:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Ota successed."];
    }];
}

// 实现UIDocumentPickerDelegate的代理方法
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *selectedURL = [urls firstObject];
       if (selectedURL) {
           // 在这里验证文件扩展名是否为 .up
           if ([[selectedURL pathExtension] isEqualToString:@"up"]) {
               // 在这里可以继续处理 .up 文件
               [self sendData:selectedURL];
           } else {
               // 选择的文件不是 .up 文件，可以提供错误消息给用户
               [SVProgressHUD showErrorWithStatus:@"The file format is incorrect. Please select a.up file."];
           }
       }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)monitorChange{
    @weakify(self)
    [[WatchManager sharedInstance].currentValue.infoModel.baseinfo subscribeNext:^(WMDeviceBaseInfo * _Nullable x) {
        @strongify(self);
        self.detail.text = [NSString stringWithFormat:@"Current version: %@",x.version];
    }];
}
@end
