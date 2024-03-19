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
    self.title = NSLocalizedString(@"ota", nil);
    self.view.backgroundColor = [UIColor whiteColor];

    self.upgradeBtn.frame = CGRectMake(20, 220, CGRectGetWidth(self.view.frame) - 40, 44);

//    self.detail.text = [NSString stringWithFormat:@"Current version: %@",[WatchManager sharedInstance].currentValue.infoModel.baseinfoValue.version];
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
        [_upgradeBtn setTitle:NSLocalizedString(@"Upgrade now", nil) forState:UIControlStateNormal];
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
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"]
                                                                                                                inMode:UIDocumentPickerModeOpen];
        documentPicker.delegate = self;

        [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)sendData:(NSURL *)path{
    if ([path startAccessingSecurityScopedResource]) {
        
        @weakify(self)
        [[[WatchManager sharedInstance].currentValue.apps.fileApp startTransferFile:path fileType:WMActivityTypeOTA] subscribeNext:^(WMProgressModel * _Nullable x) {
            [SVProgressHUD showProgress:x.progress / 100.0 status:[NSString stringWithFormat:NSLocalizedString(@"Progress:%.2f%%", nil),x.progress]];
        } error:^(NSError * _Nullable error) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Ota failed.", nil)];
            [path stopAccessingSecurityScopedResource];
        } completed:^{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Ota successed.", nil)];
            [path stopAccessingSecurityScopedResource];

        }];
    }else {
        NSLog(@"startAccessingSecurityScopedResource fail");
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"startAccessingSecurityScopedResource fail", nil)];
    }
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *selectedURL = [urls firstObject];
       if (selectedURL) {
           // Verify here that the file extension is.up or.upex
           if ([[selectedURL pathExtension] isEqualToString:@"up"] || [[selectedURL pathExtension] isEqualToString:@"upex"]) {
               // Here you can continue working with.up or.upex files
               [self sendData:selectedURL];
           } else {
               // The selected file is not an.up file and can provide an error message to the user
               [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"The file format is incorrect. Please select a.up file.", nil)];
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
    [[WatchManager sharedInstance].currentValue.infoModel.wm_getBaseinfo subscribeNext:^(WMDeviceBaseInfo * _Nullable x) {
        @strongify(self);
        self.detail.text = [NSString stringWithFormat:NSLocalizedString(@"Current version: %@", nil),x.version];
    }];
}
@end
