//
//  HomeViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/19.
//

#import "HomeViewController.h"
#import "CameraAppDelegate.h"

#import "DateAndTimeSynchronizedViewController.h"
#import "SoundAndTouchFeedbackViewController.h"
#import "AppViewViewController.h"
#import "DialManagerViewController.h"
#import "CameraControlViewController.h"
#import "SleepSettingViewController.h"
#import "AboutDeviceViewController.h"
#import "AlarmsViewController.h"
#import "LanguageChangeViewController.h"

@interface TableViewHeader : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;

- (instancetype)initWithFrame:(CGRect)frame;

@end

@implementation TableViewHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 创建标签
        _label = [[UILabel alloc] init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO; // 关闭AutoresizingMask，以使用Auto Layout
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        
        // 创建按钮
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        self.button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.button setBackgroundColor:[UIColor blueColor]];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.button.layer.cornerRadius = 5;
        self.button.layer.masksToBounds = YES;
        [self addSubview:self.button];
        
        // 使用Auto Layout布局标签和按钮
        [self.label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16].active = YES;
        [self.label.trailingAnchor constraintEqualToAnchor:self.button.leadingAnchor constant:-16].active = YES; // 更新约束，使标签不覆盖按钮
        [self.label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        
        [self.button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
        [self.button.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        
        
    }
    return self;
}

@end

@interface TableViewFooter : UIView

@property (nonatomic, strong) UIButton *disconnect;
@property (nonatomic, strong) UIButton *unbind;

- (instancetype)initWithFrame:(CGRect)frame;

@end
@implementation TableViewFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 创建按钮1
        self.disconnect = [UIButton buttonWithType:UIButtonTypeSystem];
        self.disconnect.translatesAutoresizingMaskIntoConstraints = NO;
        [self.disconnect setBackgroundColor:[UIColor blueColor]];
        [self.disconnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.disconnect setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.disconnect.layer.cornerRadius = 5;
        self.disconnect.layer.masksToBounds = YES;
        [self addSubview:self.disconnect];
        
        // 创建按钮2
        self.unbind = [UIButton buttonWithType:UIButtonTypeSystem];
        self.unbind.translatesAutoresizingMaskIntoConstraints = NO;
        [self.unbind setBackgroundColor:[UIColor redColor]];
        [self.unbind setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.unbind setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.unbind.layer.cornerRadius = 5;
        self.unbind.layer.masksToBounds = YES;
        [self addSubview:self.unbind];
        
        // 使用Auto Layout布局按钮1和按钮2
        [self.disconnect.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16].active = YES;
        [self.disconnect.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
        [self.disconnect.topAnchor constraintEqualToAnchor:self.topAnchor constant:16].active = YES;
        [self.disconnect.heightAnchor constraintEqualToConstant:44].active = YES;
        
        [self.unbind.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16].active = YES;
        [self.unbind.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
        [self.unbind.topAnchor constraintEqualToAnchor:self.disconnect.bottomAnchor constant:60].active = YES;
        [self.unbind.heightAnchor constraintEqualToConstant:44].active = YES;
        
    }
    return self;
}

@end

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RACReplaySubject<NSMutableArray<id> *> *currents;
@property (nonatomic, strong) NSMutableArray *currentsValue; // 用于保存最新的值
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIView *tableViewHeader;
@property (nonatomic, strong) UIView *tableViewFooter;

@property (nonatomic, strong) TableViewHeader *tableViewHeaderView;
@property (nonatomic, strong) TableViewFooter *tableViewFooterView;


@end

@implementation HomeViewController
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
    }
    return  _tableView;
}


-(void)observerTableViewData{
    @weakify(self);
    // 订阅 currents 来更新 currentsValue
    [self.currents subscribeNext:^(NSMutableArray<NSMutableArray<id>*> *peripherals) {
        @strongify(self);
        self.currentsValue = peripherals;
        [self.tableView reloadData]; // 刷新表格数据
    }];
}
- (void)dealloc
{
    if (self.alertController != nil){
        [self.alertController dismissViewControllerAnimated:false completion:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _currents = [RACReplaySubject replaySubjectWithCapacity:1];
    _currentsValue = [NSMutableArray new];
    self.tableView.tableHeaderView = self.tableViewHeader;
    self.tableView.tableFooterView = self.tableViewFooter;
    [self observerTableViewData];
    [self config];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.currentsValue.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currentsValue[section][@"data"] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    }
    NSString *title = self.currentsValue[indexPath.section][@"data"][indexPath.row][@"title"];
    NSString *subtitle = self.currentsValue[indexPath.section][@"data"][indexPath.row][@"subtitle"];
    NSString *accessoryType = self.currentsValue[indexPath.section][@"data"][indexPath.row][@"accessoryType"];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    cell.accessoryType = [self accessoryTypeFrom:accessoryType];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UITableViewCellAccessoryType)accessoryTypeFrom:(NSString *)accessoryTypeString{
    if ([accessoryTypeString isEqualToString:@"UITableViewCellAccessoryNone"]){
        return  UITableViewCellAccessoryNone;
    }else if ([accessoryTypeString isEqualToString:@"UITableViewCellAccessoryDisclosureIndicator"]){
        return  UITableViewCellAccessoryDisclosureIndicator;
    }else if ([accessoryTypeString isEqualToString:@"UITableViewCellAccessoryDetailDisclosureButton"]){
        return  UITableViewCellAccessoryDetailDisclosureButton;
    }else if ([accessoryTypeString isEqualToString:@"UITableViewCellAccessoryCheckmark"]){
        return  UITableViewCellAccessoryCheckmark;
    }else if ([accessoryTypeString isEqualToString:@"UITableViewCellAccessoryDetailButton"]){
        return  UITableViewCellAccessoryDetailButton;
    }else{
        return  UITableViewCellAccessoryNone;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 从字典中获取选择器字符串
    NSString *selectorString = self.currentsValue[indexPath.section][@"data"][indexPath.row][@"selector"];
    // 将选择器字符串转换为 SEL 对象
    SEL selector = NSSelectorFromString(selectorString);
    
    if ([self respondsToSelector:selector]) {
        // 创建参数
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // 举例，您可以根据需要创建合适的 indexPath
        // 使用 performSelector 调用方法并传递参数
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self performSelector:selector withObject:cell withObject:indexPath];
    } else {
        // 处理选择器不存在的情况
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
-(UIView *)tableViewHeader{
    if(_tableViewHeader == nil){
        _tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        [_tableViewHeader addSubview:self.tableViewHeaderView];
    }
    return _tableViewHeader;
}
-(UIView *)tableViewFooter{
    if(_tableViewFooter == nil){
        _tableViewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        [_tableViewFooter addSubview:self.tableViewFooterView];
    }
    return _tableViewFooter;
}

- (TableViewHeader *)tableViewHeaderView
{
    if (_tableViewHeaderView == nil) {
        _tableViewHeaderView = [[TableViewHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        [self.tableViewHeaderView.button setTitle:@"get now" forState:UIControlStateNormal];
        [_tableViewHeaderView.button addTarget:self action:@selector(getBatteryNow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tableViewHeaderView;
}
- (TableViewFooter *)tableViewFooterView
{
    if (_tableViewFooterView == nil) {
        _tableViewFooterView = [[TableViewFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        [_tableViewFooterView.disconnect addTarget:self action:@selector(disconnectedDevice) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewFooterView.disconnect setTitle:@"Disconnect device" forState:UIControlStateNormal];
        [_tableViewFooterView.unbind addTarget:self action:@selector(unbindDevice) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewFooterView.unbind setTitle:@"Unbind device" forState:UIControlStateNormal];
    }
    return  _tableViewFooterView;
}

/**
 UITableViewCellAccessoryNone,                                                      // don't show any accessory view
 UITableViewCellAccessoryDisclosureIndicator,                                       // regular chevron. doesn't track
 UITableViewCellAccessoryDetailDisclosureButton API_UNAVAILABLE(tvos),                 // info button w/ chevron. tracks
 UITableViewCellAccessoryCheckmark,                                                 // checkmark. doesn't track
 UITableViewCellAccessoryDetailButton API_AVAILABLE(ios(7.0))  API_UNAVAILABLE(tvos) // i
 */
-(void)config{
    [self.currentsValue addObjectsFromArray:@[
        @{
            @"title":@"",
            @"data":@[
                @{
                    @"title":@"The date and time are synchronized",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(dateAndTimeSynchronizedViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"Sound and touch feedback",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(soundAndTouchFeedbackViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"App view",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(appViewViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"Dial manager",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(dialManagerViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"Camera Control",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(cameraControlViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"Sleep Setting",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(sleepSettingViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"Alarms",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(alarmsViewController:didSeletIndexPath:))
                },
                @{
                    @"title":@"Device language",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(languageChangeViewController:didSeletIndexPath:))
                },
            ]
        },
        @{
            @"title":@"",
            @"data":@[
                @{
                    @"title":@"About evice",
                    @"subtitle":@"",
                    @"accessoryType":@"UITableViewCellAccessoryDisclosureIndicator",
                    @"selector": NSStringFromSelector(@selector(aboutDeviceViewController:didSeletIndexPath:))
                },
            ]
        },
    ]];
    [self.currents sendNext:self.currentsValue];
    
    @weakify(self);
    [[[[WatchManager sharedInstance] currentValue] connect].isConnected subscribeNext:^(NSNumber * _Nullable x) {
        BOOL isConnected = [x boolValue];
        if (isConnected == false){
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Connection down",nil)];
            //            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //            // 获取主Storyboard的初始ViewController
            //            UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ConnectionModeSelectionViewController"];
            //            viewController.title = NSLocalizedString(@"Connection mode selection", nil);
            //            [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
            
        }
    }];
    [self listenBattery];
    [self getBattery];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiWatchOpenOrCloseCamera:) name:NOTI_watchOpenOrCloseCamera object:nil];
    
}
-(void)notiWatchOpenOrCloseCamera:(NSNotification *)noti{
    if ([[[self.navigationController viewControllers] lastObject] isKindOfClass:[CameraControlViewController class]] == YES){
        return;
    }
    NSDictionary *userInfo = noti.userInfo;
    if (userInfo!= nil){
        BOOL isOpen = [userInfo[@"isOpen"] boolValue];
        if (isOpen == YES){
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            // 获取主Storyboard的初始ViewController
            UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"CameraControlViewController"];
            [self.navigationController pushViewController:viewController animated:true];
        }
        WatchresultBlock resultBlock = noti.userInfo[@"result"];
        if (resultBlock) {
            resultBlock(YES);
        }
    }
    
}
-(void)listenBattery{
    @weakify(self);
    [[[[[WatchManager sharedInstance] currentValue] infoModel] battery] subscribeNext:^(WMDeviceBatteryModel * _Nullable x) {
        @strongify(self);
        self.tableViewHeaderView.label.text = [NSString stringWithFormat:@"battery: %d%%  %@",x.battery,x.isCharging == YES ? @"charging":@"not charging"];
    } error:^(NSError * _Nullable error) {
        
    }];
}
-(void)getBattery{
    
    @weakify(self);
    
    [[[[[WatchManager sharedInstance] currentValue] infoModel] wm_getBattery] subscribeNext:^(WMDeviceBatteryModel * _Nullable x) {
        @strongify(self);
        self.tableViewHeaderView.label.text = [NSString stringWithFormat:@"battery: %d%%  %@",x.battery,x.isCharging == YES ? @"charging":@"not charging"];
    } error:^(NSError * _Nullable error) {
        
    }];
}
- (void)getBatteryNow {
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[[[[WatchManager sharedInstance] currentValue] infoModel] wm_getBattery] subscribeNext:^(WMDeviceBatteryModel * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        self.tableViewHeaderView.label.text = [NSString stringWithFormat:@"battery: %d%%  %@",x.battery,x.isCharging == YES ? @"charging":@"not charging"];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Get battery info fail"];
    }];
}

-(void)dateAndTimeSynchronizedViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DateAndTimeSynchronizedViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)soundAndTouchFeedbackViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SoundAndTouchFeedbackViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)appViewViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"AppViewViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)dialManagerViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DialManagerViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)cameraControlViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"CameraControlViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)sleepSettingViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SleepSettingViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)aboutDeviceViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"AboutDeviceViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)alarmsViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIViewController *viewController = [AlarmsViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)languageChangeViewController:(UITableViewCell *)cell didSeletIndexPath:(NSIndexPath *)indexPath{
    UIViewController *viewController = [LanguageChangeViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)unbindDevice {
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[[[[WatchManager sharedInstance] currentValue] connect] restoreFactory] subscribeNext:^(NSNumber * _Nullable x) {
        [SVProgressHUD dismiss];
        @strongify(self);
        BOOL isUnbindSuccess = [x boolValue];
        if (isUnbindSuccess == YES){
            XLOG_INFO(@"解绑成功"); // 获取应用程序的主Storyboard
            [WatchManager sharedInstance].lastConnectedMac = nil;
            [self goConnectView];
        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Connection mode selection", nil)];
            XLOG_INFO(@"解绑失败");
        }
        
    }];
    
}
- (void)disconnectedDevice {
    [[[[WatchManager sharedInstance] currentValue] connect] disconnect];
    [self goConnectView];
}
- (void)goConnectView{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // 获取主Storyboard的初始ViewController
    UIViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ConnectionModeSelectionViewController"];
    viewController.title = NSLocalizedString(@"Connection mode selection", nil);
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
    
}

@end



