//
//  AlarmsViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/19.
//

#import "AlarmsViewController.h"
#import "AlarmEditViewController.h"


@interface AlarmsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *alarms; // 存储闹钟数据的数组

@end

@implementation AlarmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Alarms manager";
    
    // 创建UITableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self addAddBtn];
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.alarmApp.alarmList subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        self.alarms = x;
        if (self.alarms == nil){
            self.alarms = [NSMutableArray new];
        }
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Get Fail"];
    }];
    
    [[WatchManager sharedInstance].currentValue.apps.alarmApp.syncAlarmList subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        self.alarms = x;
        if (self.alarms == nil){
            self.alarms = [NSMutableArray new];
        }
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Get Fail"];
    }];
}

-(void)addAddBtn{
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:@"Add Alarm" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 5;
    [addBtn setBackgroundColor:[UIColor blueColor]];
    [addBtn addTarget:self action:@selector(addAlarm) forControlEvents:UIControlEventTouchUpInside];
    addBtn.frame = CGRectMake(16, 30,CGRectGetWidth(self.view.frame) - 32, 44);
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100)];
    [footerView addSubview:addBtn];
    self.tableView.tableFooterView = footerView;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.alarms.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AlarmCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    WMAlarmModel *model = self.alarms[indexPath.row];
    // 配置每行的Cell
    NSString *alarmText = model.alarmName;
    
    cell.textLabel.text = alarmText;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%02ld:%02ld \n%@",(long)model.alarmHour,(long)model.alarmMinute,[self convertAlarmRepeatToWeekdayString:model.repeatOptions]];
    cell.detailTextLabel.numberOfLines = 0;
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    // 创建开关
    UISwitch *switchView = [[UISwitch alloc] init];
    [switchView setOn:model.isOn];
    switchView.tag = indexPath.row + 1000;
    [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 创建删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:@"delete" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.layer.masksToBounds = YES;
    deleteButton.layer.cornerRadius = 5;
    [deleteButton setBackgroundColor:[UIColor redColor]];
    deleteButton.tag = indexPath.row + 100;
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 布局开关和删除按钮
    CGFloat buttonWidth = 60; // 按钮宽度
    CGFloat cellWidth = CGRectGetWidth(self.view.frame);
    
    // 计算删除按钮的位置
    CGRect deleteButtonFrame = CGRectMake(cellWidth - buttonWidth - 10, 10, buttonWidth, 30);
    deleteButton.frame = deleteButtonFrame;
    
    // 计算开关的位置
    CGRect switchFrame = CGRectMake(cellWidth - 2 * buttonWidth - 10, 10, buttonWidth, 30);
    switchView.frame = switchFrame;
    
    // 将开关和删除按钮添加到单元格
    [cell.contentView addSubview:switchView];
    [cell.contentView addSubview:deleteButton];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMAlarmModel *model = self.alarms[indexPath.row];
    [self editAlarm:model];
}

- (void)addAlarm {
    AlarmEditViewController *vc = [AlarmEditViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)editAlarm:(WMAlarmModel *)model {
    AlarmEditViewController *vc = [AlarmEditViewController new];
    vc.alarmModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchValueChanged:(UISwitch *)sender {
    // 处理开关按钮状态改变事件
    NSInteger indexRow = sender.tag - 1000;
    // 处理删除按钮点击事件
    WMAlarmModel *model = self.alarms[indexRow];
    model.isOn = sender.isOn;
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.apps.alarmApp updateAlarm:model] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        self.alarms = x;
        if (self.alarms == nil){
            self.alarms = [NSMutableArray new];
        }
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];
    
}

- (void)deleteButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // 处理删除按钮点击事件
    WMAlarmModel *model = self.alarms[indexRow];
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[[WatchManager sharedInstance].currentValue.apps.alarmApp deleteAlarm:model.identifier] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        self.alarms = x;
        if (self.alarms == nil){
            self.alarms = [NSMutableArray new];
        }
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Deleta Fail\n%@",error.description]];
    }];
}

- (NSString *)convertAlarmRepeatToWeekdayString:(WMAlarmRepeat)repeatOptions {
    NSMutableString *weekdayString = [NSMutableString string];
    
    if (repeatOptions & WMAlarmRepeatSunday) {
        [weekdayString appendString:@"Sunday, "];
    }
    if (repeatOptions & WMAlarmRepeatMonday) {
        [weekdayString appendString:@"Monday, "];
    }
    if (repeatOptions & WMAlarmRepeatTuesday) {
        [weekdayString appendString:@"Tuesday, "];
    }
    if (repeatOptions & WMAlarmRepeatWednesday) {
        [weekdayString appendString:@"Wednesday, "];
    }
    if (repeatOptions & WMAlarmRepeatThursday) {
        [weekdayString appendString:@"Thursday, "];
    }
    if (repeatOptions & WMAlarmRepeatFriday) {
        [weekdayString appendString:@"Friday, "];
    }
    if (repeatOptions & WMAlarmRepeatSaturday) {
        [weekdayString appendString:@"Saturday, "];
    }
    
    // 去除最后一个逗号和空格
    if ([weekdayString length] > 2) {
        [weekdayString deleteCharactersInRange:NSMakeRange([weekdayString length] - 2, 2)];
    }
    
    return weekdayString;
}
@end
