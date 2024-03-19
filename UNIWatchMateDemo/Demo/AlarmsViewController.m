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
    self.title = NSLocalizedString(@"Alarms", nil);
    
    // 创建UITableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self addAddBtn];
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.alarmApp.alarmList subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        self.alarms = [NSMutableArray new];
        if (self.alarms != nil){
            [self.alarms addObjectsFromArray:x];
        }
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Get Fail", nil)];
    }];
    [self getAlarmList];

}
-(void)getAlarmList{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.alarmApp.wm_getAlarmList subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        
        self.alarms = [NSMutableArray new];
        if (self.alarms != nil){
            [self.alarms addObjectsFromArray:x];
        }
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Get Fail", nil)];
    }];
}

-(void)addAddBtn{
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:NSLocalizedString(@"Add Alarm", nil) forState:UIControlStateNormal];
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
    
    NSString *alarmText = model.alarmName;
    
    cell.textLabel.text = alarmText;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%02ld:%02ld \n%@",(long)model.alarmHour,(long)model.alarmMinute,[self convertAlarmRepeatToWeekdayString:model.repeatOptions]];
    cell.detailTextLabel.numberOfLines = 0;
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
   
    UISwitch *switchView = [[UISwitch alloc] init];
    [switchView setOn:model.isOn];
    switchView.tag = indexPath.row + 1000;
    [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.layer.masksToBounds = YES;
    deleteButton.layer.cornerRadius = 5;
    [deleteButton setBackgroundColor:[UIColor redColor]];
    deleteButton.tag = indexPath.row + 100;
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat buttonWidth = 60;
    CGFloat cellWidth = CGRectGetWidth(self.view.frame);
    
    CGRect deleteButtonFrame = CGRectMake(cellWidth - buttonWidth - 10, 10, buttonWidth, 30);
    deleteButton.frame = deleteButtonFrame;
    
    CGRect switchFrame = CGRectMake(cellWidth - 2 * buttonWidth - 10, 10, buttonWidth, 30);
    switchView.frame = switchFrame;
    
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
    vc.completionHandler = ^(NSString *data) {
      
        [self getAlarmList];
    };
    vc.alarmModels = self.alarms;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)editAlarm:(WMAlarmModel *)model {
    AlarmEditViewController *vc = [AlarmEditViewController new];
    vc.completionHandler = ^(NSString *data) {
        
        [self getAlarmList];
    };
    vc.alarmModel = model;
    vc.alarmModels = self.alarms;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchValueChanged:(UISwitch *)sender {
    
    NSInteger indexRow = sender.tag - 1000;
    
    WMAlarmModel *model = self.alarms[indexRow];
    model.isOn = sender.isOn;
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.apps.alarmApp syncAlarmList:_alarms] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
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
    
    [self.alarms removeObjectAtIndex:indexRow];
    @weakify(self);
    [SVProgressHUD showWithStatus:nil];
    [[[WatchManager sharedInstance].currentValue.apps.alarmApp syncAlarmList:_alarms] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
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
        [weekdayString appendString:NSLocalizedString(@"Sunday", nil)];
        [weekdayString appendString:@", "];
    }
    if (repeatOptions & WMAlarmRepeatMonday) {
        [weekdayString appendString:NSLocalizedString(@"Monday", nil)];
        [weekdayString appendString:@", "];
    }
    if (repeatOptions & WMAlarmRepeatTuesday) {
        [weekdayString appendString:NSLocalizedString(@"Tuesday", nil)];
        [weekdayString appendString:@", "];
    }
    if (repeatOptions & WMAlarmRepeatWednesday) {
        [weekdayString appendString:NSLocalizedString(@"Wednesday", nil)];
        [weekdayString appendString:@", "];
    }
    if (repeatOptions & WMAlarmRepeatThursday) {
        [weekdayString appendString:NSLocalizedString(@"Thursday", nil)];
        [weekdayString appendString:@", "];
    }
    if (repeatOptions & WMAlarmRepeatFriday) {
        [weekdayString appendString:NSLocalizedString(@"Friday", nil)];
        [weekdayString appendString:@", "];
    }
    if (repeatOptions & WMAlarmRepeatSaturday) {
        [weekdayString appendString:NSLocalizedString(@"Saturday", nil)];
        [weekdayString appendString:@", "];
    }
    
    // Remove the last comma and space
    if ([weekdayString length] > 2) {
        [weekdayString deleteCharactersInRange:NSMakeRange([weekdayString length] - 2, 2)];
    }
    
    return weekdayString;
}
@end
