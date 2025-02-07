//
//  SmallWidghtViewController.m
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/2/27.
//

#import "SmallWidgetViewController.h"


@interface SmallWidgetViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *supportedTypes;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *variableTypes;
@property (nonatomic, strong) WMWidgetModel *wMWidgetModel;
@end

@implementation SmallWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Widget",nil);
    _supportedTypes= @[
        @(WMWidgetTypeWidgetMusic),
        @(WMWidgetTypeWidgetActivityRecord),
        @(WMWidgetTypeWidgetHeartRate),
        @(WMWidgetTypeWidgetBloodOxygen),
        @(WMWidgetTypeWidgetBreathTrain),
        @(WMWidgetTypeWidgetSport),
        @(WMWidgetTypeWidgetNotifyMsg),
        @(WMWidgetTypeWidgetAlarm),
        @(WMWidgetTypeWidgetPhone),
        @(WMWidgetTypeWidgetSleep),
        @(WMWidgetTypeWidgetWeather),
        @(WMWidgetTypeWidgetFindPhone),
        @(WMWidgetTypeWidgetCalculator),
        @(WMWidgetTypeWidgetRemoteCamera),
        @(WMWidgetTypeWidgetStopWatch),
        @(WMWidgetTypeWidgetTimer),
        @(WMWidgetTypeWidgetFlashLight),
        @(WMWidgetTypeWidgetSetting)
    ];
    _variableTypes= [NSMutableArray array];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray arrayWithArray:@[
        [NSMutableArray arrayWithArray:@[]],
        [NSMutableArray arrayWithArray:@[]]
    ]];
  
    self.tableView.frame = self.view.frame;
    [self.view addSubview:self.tableView];
    [self getInfo];
}

-(void)getInfo {
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.widget getConfigModel] subscribeNext:^(WMWidgetModel * _Nullable x) {
        self->_wMWidgetModel = x;
        
        [self->_variableTypes removeAllObjects];
        [self->_variableTypes addObjectsFromArray: x.widgets];

        [self showModel];
    } error:^(NSError * _Nullable error) {
      
    }];
}
-(void)showModel {
    
    // 使用 NSPredicate 创建一个谓词，过滤掉 fixedWidgetTypes 中的值
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSNumber *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![_variableTypes containsObject:evaluatedObject];
    }];

    // 使用谓词过滤 allWidgetTypes
    NSArray<NSNumber *> *filteredWidgetTypes = [self.supportedTypes filteredArrayUsingPredicate:predicate];
    self.dataArray = [NSMutableArray arrayWithArray:@[
        [NSMutableArray arrayWithArray:self.variableTypes],
        [NSMutableArray arrayWithArray:filteredWidgetTypes]
    ]];
    [self->_tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return NSLocalizedString(@"From device.Can delete.", nil);
    }else{
        return NSLocalizedString(@"Can add.", nil);
    }
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return _tableView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
     return self.dataArray.count;;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSInteger *wMWidgetTypeInt = [self.dataArray[indexPath.section][indexPath.row] intValue];
    // 然后将这个NSInteger转换为WMWidgetType枚举
    WMWidgetType widgetType = (WMWidgetType)wMWidgetTypeInt;
    cell.textLabel.text =stringFromWMWidgetType(widgetType);
    cell.textLabel.frame = CGRectInset(cell.textLabel.frame, 0, 0);

    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
        // 创建删除按钮
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (indexPath.section == 0){
            [deleteButton setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }else if (indexPath.section == 1){
            [deleteButton setTitle:NSLocalizedString(@"add", nil) forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteButton.layer.masksToBounds = YES;
        deleteButton.layer.cornerRadius = 5;
        [deleteButton setBackgroundColor:[UIColor redColor]];
        deleteButton.tag = indexPath.row + 100;
        
        // 布局开关和删除按钮
        CGFloat buttonWidth = 60; // 按钮宽度
        CGFloat cellWidth = CGRectGetWidth(self.view.frame);
        
        // 计算删除按钮的位置
        CGRect deleteButtonFrame = CGRectMake(cellWidth - buttonWidth - 25, 10, buttonWidth, 30);
        deleteButton.frame = deleteButtonFrame;
        
        [cell.contentView addSubview:deleteButton];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.dataArray[section].count;
}
// 禁止删除行
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
NSString *stringFromWMWidgetType(WMWidgetType type) {
    switch (type) {
        case WMWidgetTypeWidgetMusic:
            return NSLocalizedString(@"Music", nil);
        case WMWidgetTypeWidgetActivityRecord:
            return NSLocalizedString(@"Activity Record (Daily Activity)", nil);
        case WMWidgetTypeWidgetHeartRate:
            return NSLocalizedString(@"Heart Rate", nil);
        case WMWidgetTypeWidgetBloodOxygen:
            return NSLocalizedString(@"Blood Oxygen", nil);
        case WMWidgetTypeWidgetBreathTrain:
            return NSLocalizedString(@"Breath Training", nil);
        case WMWidgetTypeWidgetSport:
            return NSLocalizedString(@"Sport", nil);
        case WMWidgetTypeWidgetNotifyMsg:
            return NSLocalizedString(@"Message", nil);
        case WMWidgetTypeWidgetAlarm:
            return NSLocalizedString(@"Alarm", nil);
        case WMWidgetTypeWidgetPhone:
            return NSLocalizedString(@"Phone", nil);
        case WMWidgetTypeWidgetSleep:
            return NSLocalizedString(@"Sleep", nil);
        case WMWidgetTypeWidgetWeather:
            return NSLocalizedString(@"Weather", nil);
        case WMWidgetTypeWidgetFindPhone:
            return NSLocalizedString(@"Find Phone", nil);
        case WMWidgetTypeWidgetCalculator:
            return NSLocalizedString(@"Calculator", nil);
        case WMWidgetTypeWidgetRemoteCamera:
            return NSLocalizedString(@"Remote Camera", nil);
        case WMWidgetTypeWidgetStopWatch:
            return NSLocalizedString(@"Stopwatch", nil);
        case WMWidgetTypeWidgetTimer:
            return NSLocalizedString(@"Timer (Countdown)", nil);
        case WMWidgetTypeWidgetFlashLight:
            return NSLocalizedString(@"Flashlight", nil);
        case WMWidgetTypeWidgetSetting:
            return NSLocalizedString(@"Settings", nil);
        default:
            return NSLocalizedString(@"Unknown", nil);
    }
}

- (void)deleteButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // 处理删除按钮点击事件
    if(self.variableTypes.count < 2){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"At least one", nil)];
        return;
    }
   
    [self.variableTypes removeObjectAtIndex:indexRow];
    [SVProgressHUD showWithStatus:nil];
    if(self.wMWidgetModel == nil){
        return;
    }
    self.wMWidgetModel.widgets = self.variableTypes;

    @weakify(self);

        [[[WatchManager sharedInstance].currentValue.settings.widget setConfigModel:self.wMWidgetModel] subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self showModel];
        } error:^(NSError * _Nullable error) {
            @strongify(self);
            [self getInfo];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Deleta Fail\n%@",error.description]];
        }];
}


- (void)addButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // 处理删除按钮点击事件
    NSNumber * firstType = [self.dataArray[0] objectAtIndex:0];
    if(firstType.intValue == WMWidgetTypeWidgetMusic && self.variableTypes.count >= 4){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"You must delete some data first", nil)];
        return;
    }

    if (self.variableTypes.count >= 9){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"You must delete some data first", nil)];
        return;
    }
  
    NSNumber * addType = [self.dataArray[1] objectAtIndex:indexRow];
    [self.variableTypes addObject:addType];
    if(self.wMWidgetModel == nil){
        return;
    }
    self.wMWidgetModel.widgets = self.variableTypes;
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.widget setConfigModel:self.wMWidgetModel] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showModel];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self getInfo];
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Deleta Fail\n%@",error.description]];
    }];
}



@end
