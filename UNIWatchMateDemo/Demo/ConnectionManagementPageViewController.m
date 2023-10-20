//
//  ConnectionManagementPageViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/27.
//

#import "ConnectionManagementPageViewController.h"
#import "HomeViewController.h"
@interface ConnectionManagementPageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) RACReplaySubject<NSMutableArray<WMPeripheral *> *> *currents;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<WMPeripheral *> *currentsValue; // 用于保存最新的值

@property (nonatomic, strong) NSString *lastProductType;
@property (nonatomic, assign) BOOL needHiddenLoading;


@end

@implementation ConnectionManagementPageViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化属性needHiddenLoading
        _needHiddenLoading = YES; // 这里将属性初始化为YES，你可以根据需要设置不同的初始值
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    _currents = [RACReplaySubject replaySubjectWithCapacity:1];
    _currentsValue = [NSMutableArray new];
    // 初始化tableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 创建一个自定义的footer视图
    UIView *customFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    
    // 创建一个活动指示器
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(customFooterView.frame.size.width / 2 - 30, customFooterView.frame.size.height / 2);
    
    // 添加活动指示器到footer视图
    [customFooterView addSubview:activityIndicator];
    
    // 设置footer视图的文本
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, customFooterView.frame.size.width, 44)];
    label.text = NSLocalizedString(@"scanning...", nil);
    label.textAlignment = NSTextAlignmentLeft;
    
    // 设置 "扫描中" 文本和活动指示器整体居中
    CGRect labelFrame = label.frame;
    labelFrame.origin.x = activityIndicator.frame.origin.x + activityIndicator.frame.size.width + 5;
    label.frame = labelFrame;
    
    // 添加文本标签到footer视图
    [customFooterView addSubview:label];
    
    // 将自定义footer视图设置为tableView的footerView
    if (self.needHiddenLoading == NO){
        self.tableView.tableFooterView = customFooterView;
    }
    
    // 开始活动指示器动画
    [activityIndicator startAnimating];
    
    
    
    
    
    // 订阅 currents 来更新 currentsValue
    [self.currents subscribeNext:^(NSMutableArray<WMPeripheral *> *peripherals) {
        self.currentsValue = peripherals;
        [self.tableView reloadData]; // 刷新表格数据
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
-(void)connectDeviceByQRCode:(NSString *)qrCode{
    self.needHiddenLoading = YES;
    [SVProgressHUD showWithStatus:nil];
    NSString *code = qrCode;
    @weakify(self);
    [[[WMManager sharedInstance] findWatchFromQRCode:code] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        [self bindDevice:x];
    } error:^(NSError * _Nullable error) {
        
    }];
}
-(void)connectDeviceByMac:(NSString *)mac productType:(NSString *)productType{
    [SVProgressHUD showWithStatus:nil];
    self.needHiddenLoading = YES;
    self.lastProductType = productType;
    WMPeripheralTargetModel *model = [[WMPeripheralTargetModel alloc]init];
    model.type = UNIWPeripheralFormTypeMac;
    model.name = @"";
    model.mac = mac;
    
    @weakify(self);
    [[[WMManager sharedInstance] findWatchFromTarget:model product:productType] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        [self bindDevice:x];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [SVProgressHUD dismiss];
        if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
            // 在超时时执行的代码
            XLOG_INFO(@"Connect by mac:Signal timed out");
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
            
        } else {
            // 处理其他错误
            XLOG_INFO(@"Connect by mac:Error: %@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
        }
        [self failBack];
    }];
}
-(void)connectDeviceBySearchProductType:(NSString *)productType{
    self.needHiddenLoading = NO;
    self.lastProductType = productType;
    @weakify(self);
    [[[WMManager sharedInstance] findWatchFromSearch:productType] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        [self addNewDevice:x];
    } error:^(NSError * _Nullable error) {
        
    }];
}
-(void)addNewDevice:(WMPeripheral * _Nullable)x{
    
    for (WMPeripheral  *obj in self.currentsValue) {
        if ([obj.infoModel.baseinfoValue.macAddress isEqualToString:x.infoModel.baseinfoValue.macAddress]) {
            return;
        }
    }
    [self.currentsValue addObject:x];
    [self.currents sendNext:self.currentsValue];
}
-(void)selectedDevice:(WMPeripheral * _Nullable)x{
    [SVProgressHUD showWithStatus:nil];
    [[WMManager sharedInstance] stopSearch:self.lastProductType];
    [self bindDevice:x];
}
/// 绑定设备
/// - Parameter device: 需要绑定的设备
- (void)bindDevice:(WMPeripheral *)device {
    [[WatchManager sharedInstance].current sendNext:device];
    NSString *name = device.target.name;
    NSString *mac = device.target.mac;
    @weakify(self);
    //    [[[device.connect.isConnected  skip:1] timeout:20 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber * _Nullable x) {
    //        @strongify(self);
    //        BOOL isConnected = [x boolValue];
    //        XLOG_INFO(@"%@, %@", mac, isConnected ? @"已连接":@"未连接");
    //        if (isConnected == true){
    //        }else{
    //            [SVProgressHUD dismiss];
    //            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Connection failure", nil)];
    //            [self failBack];
    //        }
    //    } error:^(NSError * _Nullable error) {
    //        @strongify(self);
    //        [SVProgressHUD dismiss];
    //        if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
    //            // 在超时时执行的代码
    //            XLOG_INFO(@"Connect:Signal timed out");
    //            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
    //
    //        } else {
    //            // 处理其他错误
    //            XLOG_INFO(@"Connect:Error: %@", error.localizedDescription);
    //            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    //
    //        }
    //        [self failBack];
    //    }];
    
    
    // ready == YES; 表示APP可以与设备进行交互，并且以获取所有设备信息
    @weakify(device);
    [[[device.connect.isReady skip:1] timeout:25 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        XLOG_INFO(@"可以进行交互");
        [SVProgressHUD dismiss];
        BOOL isReady = [x boolValue];
        if (isReady == true){
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Connection successful", nil)];
            [self goHome];
        }else{
            [self failBack];
        }
        
    }error:^(NSError * _Nullable error) {
        @strongify(self);
        if (self == nil || self.navigationController.viewControllers.lastObject != self){
            return;
        }
        if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
            // 在超时时执行的代码
            XLOG_INFO(@"isReady:Signal timed out");
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
            
        } else {
            // 处理其他错误
            XLOG_INFO(@"isReady:Error: %@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
        }
        [self failBack];
    }];
    
    [[device.connect.isReady flattenMap:^__kindof RACSignal * _Nullable(NSNumber * _Nullable value) {
        @strongify(device);
        return device.infoModel.baseinfo;
    }] subscribeNext:^(id  _Nullable x) {
        WMDeviceInfoModel *infoModel = x;
        XLOG_INFO(@"设备信息:%@", infoModel);
    }];
    
    // 开始连接
    [device.connect connect];
}
-(void)failBack{
    //延迟5秒返回
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self == nil || self.navigationController.viewControllers.lastObject != self){
            return;
        }
        [self.navigationController popViewControllerAnimated:true];
    });
}
-(void)goHome{
    UIViewController *viewController = [HomeViewController new];
    NSString *deviceName = [WatchManager sharedInstance].currentValue.infoModel.baseinfoValue.deviceName;
    viewController.title = deviceName;
    [WatchManager sharedInstance].lastConnectedMac =  [WatchManager sharedInstance].currentValue.infoModel.baseinfoValue.macAddress;
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentsValue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMPeripheral *peripheral = self.currentsValue[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    }
    // 设置左侧标签
    cell.textLabel.text = peripheral.target.name;
    // 设置右侧详情文本
    cell.detailTextLabel.text = peripheral.target.mac;
    // 设置尖头样式
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WMPeripheral *selectedPeripheral = self.currentsValue[indexPath.row];
    XLOG_INFO(@"Selected Peripheral: %@", selectedPeripheral.target.mac);
    [self selectedDevice:selectedPeripheral];
    // 在这里处理选中项的其他逻辑
}
@end
