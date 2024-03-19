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
@property (nonatomic, strong) NSMutableArray<WMPeripheral *> *currentsValue; // Used to save the latest values

@property (nonatomic, strong) NSString *lastProductType;
@property (nonatomic, assign) BOOL needHiddenLoading;


@end

@implementation ConnectionManagementPageViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化属性needHiddenLoading
        _needHiddenLoading = YES; // This initializes the property to YES, and you can set different initial values according to your needs
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    _currents = [RACReplaySubject replaySubjectWithCapacity:1];
    _currentsValue = [NSMutableArray new];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // Create a custom footer view
    UIView *customFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    
    // Create an activity indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(customFooterView.frame.size.width / 2 - 30, customFooterView.frame.size.height / 2);
    
    // Add an activity indicator to the footer view
    [customFooterView addSubview:activityIndicator];
    
    // Set the text for the footer view
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, customFooterView.frame.size.width, 44)];
    label.text = NSLocalizedString(@"scanning...", nil);
    label.textAlignment = NSTextAlignmentLeft;
    
    // Set the Scanning text and activity indicator to center overall
    CGRect labelFrame = label.frame;
    labelFrame.origin.x = activityIndicator.frame.origin.x + activityIndicator.frame.size.width + 5;
    label.frame = labelFrame;
    
    // Add a text label to the footer view
    [customFooterView addSubview:label];
    
    // Set the custom footer view to the footerView of tableView
    if (self.needHiddenLoading == NO){
        self.tableView.tableFooterView = customFooterView;
    }
    
    // Start the activity indicator animation
    [activityIndicator startAnimating];
    
    
    
    
    
    // Subscribe to currents to update currentsValue
    [self.currents subscribeNext:^(NSMutableArray<WMPeripheral *> *peripherals) {
        self.currentsValue = peripherals;
        [self.tableView reloadData]; // Refresh table data
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
    //uid is usually the unique id of the login user, and "1" is used in the demo
    [[[WMManager sharedInstance] findWatchFromQRCode:code uid:@"1"] subscribeNext:^(WMPeripheral * _Nullable x) {
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
    //uid is usually the unique id of the login user, and "1" is used in the demo
    [[[WMManager sharedInstance] findWatchFromTarget:model product:productType uid:@"1"] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        [self bindDevice:x];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [SVProgressHUD dismiss];
        if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
            // Code that executes on timeout
            XLOG_INFO(@"Connect by mac:Signal timed out");
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
            
        } else {
            // Handle other errors
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
    //uid is usually the unique id of the login user, and "1" is used in the demo
    [[[WMManager sharedInstance] findWatchFromSearch:productType uid:@"1"] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        [self addNewDevice:x];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [SVProgressHUD dismiss];
        if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
           
            XLOG_INFO(@"connectDeviceBySearchProductType:Signal timed out");
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
            
        } else {
            
            XLOG_INFO(@"connectDeviceBySearchProductType:Error: %@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
        }
        [self failBack];
    }];
}
-(void)addNewDevice:(WMPeripheral * _Nullable)x{
    
    for (WMPeripheral  *obj in self.currentsValue) {
        if ([obj.target.mac isEqualToString:x.target.mac]) {
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
/// Bind device
/// - Parameter device: The device to be bound
- (void)bindDevice:(WMPeripheral *)device {
    [[WatchManager sharedInstance].current sendNext:device];
    NSString *name = device.target.name;
    NSString *mac = device.target.mac;
    @weakify(self);
//        [[[device.connect.isConnected  skip:1] timeout:20 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber * _Nullable x) {
//            @strongify(self);
//            BOOL isConnected = [x boolValue];
//            XLOG_INFO(@"%@, %@", mac, isConnected ? @"Connected":@"unconnected");
//            if (isConnected == true){
//            }else{
//                [SVProgressHUD dismiss];
//                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Connection failure", nil)];
//                [self failBack];
//            }
//        } error:^(NSError * _Nullable error) {
//            @strongify(self);
//            [SVProgressHUD dismiss];
//            if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
//                // Code that executes on timeout
//                XLOG_INFO(@"Connect:Signal timed out");
//                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
//
//            } else {
//                // Handle other errors
//                XLOG_INFO(@"Connect:Error: %@", error.localizedDescription);
//                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//
//            }
//            [self failBack];
//        }];
    
    
    // ready == YES; Indicates that the APP can interact with the device and obtain all device information
    @weakify(device);
    [[[device.connect.isReady skip:1] timeout:25 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        XLOG_INFO(@"Can interact");
      
        BOOL isReady = [x boolValue];
        if (isReady == true){
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Connection successful", nil)];
            [self goHome:name macAdress:mac];
        }
        
    }error:^(NSError * _Nullable error) {
        @strongify(self);
        [SVProgressHUD dismiss];
        if (self == nil || self.navigationController.viewControllers.lastObject != self){
            return;
        }
        if ([error.domain isEqualToString:RACSignalErrorDomain] && error.code == RACSignalErrorTimedOut) {
            //Code that executes on timeout
            XLOG_INFO(@"isReady:Signal timed out");
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Time out", nil)];
            
        } else {
            // Handle other errors
            XLOG_INFO(@"isReady:Error: %@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
        }
        [self failBack];
    }];
    
    
 
    
    
    [[device.connect.isReady flattenMap:^__kindof RACSignal * _Nullable(NSNumber * _Nullable value) {
        @strongify(device);
        return device.infoModel.wm_getBaseinfo;
    }] subscribeNext:^(id  _Nullable x) {
        WMDeviceInfoModel *infoModel = x;
        XLOG_INFO(@"Device information:%@", infoModel);
    }];
    
    // Start connection
    [device.connect connect];
}
-(void)failBack{
    //Delay 5 seconds return
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self == nil || self.navigationController.viewControllers.lastObject != self){
            return;
        }
        [self.navigationController popViewControllerAnimated:true];
    });
}
-(void)goHome:(NSString *)deviceName macAdress:(NSString *)mac{
    UIViewController *viewController = [HomeViewController new];
    viewController.title = deviceName;
    [WatchManager sharedInstance].lastConnectedMac =  mac;
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
    // Set left TAB
    cell.textLabel.text = peripheral.target.name;
    // Set the details text on the right
    cell.detailTextLabel.text = peripheral.target.mac;
    // Set arrow style
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WMPeripheral *selectedPeripheral = self.currentsValue[indexPath.row];
    XLOG_INFO(@"Selected Peripheral: %@", selectedPeripheral.target.mac);
    [self selectedDevice:selectedPeripheral];
    // The rest of the logic for the selected item is handled here
}
@end
