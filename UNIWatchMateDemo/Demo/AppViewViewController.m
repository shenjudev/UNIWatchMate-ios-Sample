//
//  AppViewViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/11.
//

#import "AppViewViewController.h"

@interface AppViewViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property(strong,nonatomic)NSArray *viewTypes;

@end

@implementation AppViewViewController
NSString* NSStringFromWMAppViewType(WMAppViewType wMAppViewType) {
    switch (wMAppViewType) {
        case WMAppViewTypeWATERFALL:
            return @"WMAppViewTypeWATERFALL";
        case WMAppViewTypeLIST:
            return @"WMAppViewTypeLIST";
        case WMAppViewTypeSTAR:
            return @"WMAppViewTypeSTAR";
            break;
        case WMAppViewTypeNINE_GRID:
            return @"WMAppViewTypeNINE_GRID";
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"App view", nil);
    [self getNow];
    [self listen];
}
-(void)listen{
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    [[[[wMPeripheral settings] appView] model] subscribeNext:^(WMAppViewModel * _Nullable x) {
        @strongify(self);
        self.viewTypes = x.views;
        self.detail.text = [NSString stringWithFormat:@"current view:%@\nsupport:\n%@",NSStringFromWMAppViewType(x.current),[[self supportViewTypes] componentsJoinedByString:@"\n"]];
    } error:^(NSError * _Nullable error) {
        self.detail.text = @"Get fail";
    }];
}
-(void)getNow{
    self.detail.text = @"";
    @weakify(self);
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    [[[[wMPeripheral settings] appView] getConfigModel] subscribeNext:^(WMAppViewModel * _Nullable x) {
        @strongify(self);
        self.viewTypes = x.views;
        self.detail.text = [NSString stringWithFormat:@"current view:%@\nsupport:\n%@",NSStringFromWMAppViewType(x.current),[[self supportViewTypes] componentsJoinedByString:@"\n"]];
    } error:^(NSError * _Nullable error) {
        self.detail.text = @"Get fail";
    }];
}
-(NSMutableArray *)supportViewTypes{
    NSMutableArray *support = [NSMutableArray new];
    for (int i = 0;i < self.viewTypes.count;i++){
        NSNumber * viewType = self.viewTypes[i];
        WMAppViewType wMAppViewType = viewType.intValue;
        [support addObject:NSStringFromWMAppViewType(wMAppViewType)];
    }
    return support;
}

- (IBAction)getInfo:(id)sender {
    [self getNow];
}
- (IBAction)WATERFALL:(id)sender {
    if ([[self supportViewTypes] containsObject:@"WMAppViewTypeWATERFALL"] == NO){
        [SVProgressHUD showErrorWithStatus:@"Not souported"];
        return;
    }
    [self setAppViuew:WMAppViewTypeWATERFALL];
}
- (IBAction)LIST:(id)sender {
    if ([[self supportViewTypes] containsObject:@"WMAppViewTypeLIST"] == NO){
        [SVProgressHUD showErrorWithStatus:@"Not souported"];
        return;
    }
    [self setAppViuew:WMAppViewTypeLIST];
}
- (IBAction)STAR:(id)sender {
    if ([[self supportViewTypes] containsObject:@"WMAppViewTypeSTAR"] == NO){
        [SVProgressHUD showErrorWithStatus:@"Not souported"];
        return;
    }
    [self setAppViuew:WMAppViewTypeSTAR];
}
- (IBAction)NINE_GRID:(id)sender {
    if ([[self supportViewTypes] containsObject:@"WMAppViewTypeNINE_GRID"] == NO){
        [SVProgressHUD showErrorWithStatus:@"Not souported"];
        return;
    }
    [self setAppViuew:WMAppViewTypeNINE_GRID];
}
-(void)setAppViuew:(WMAppViewType)wMAppViewType{
    @weakify(self);
    self.detail.text = @"";
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    WMAppViewModel *wMAppViewModel = [WatchManager sharedInstance].currentValue.settings.appView.modelValue;
    wMAppViewModel.current = wMAppViewType;
    [[[[wMPeripheral settings] appView] setConfigModel:wMAppViewModel] subscribeNext:^(WMAppViewModel * _Nullable x) {
        @strongify(self);
        self.viewTypes = x.views;
        self.detail.text = [NSString stringWithFormat:@"current view:%@\nsupport:\n%@",NSStringFromWMAppViewType(x.current),[[self supportViewTypes] componentsJoinedByString:@"\n"]];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set fail"];
    }];
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
