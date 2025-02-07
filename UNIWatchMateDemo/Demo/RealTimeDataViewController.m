//
//  RealTimeDataViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/25.
//
#import "MJExtension.h"
#import "RealTimeDataViewController.h"
NSString *NSStringFromWMSportDataType(WMSportDataType sportDataType) {
    switch (sportDataType) {
        case WMSportDataTypeStartTimestamp:
            return @"WMSportDataTypeStartTimestamp";
        case WMSportDataTypeEndTimestamp:
            return @"WMSportDataTypeEndTimestamp";
        case WMSportDataTypeTotalDuration:
            return @"WMSportDataTypeTotalDuration";
        case WMSportDataTypeTotalMileage:
            return @"WMSportDataTypeTotalMileage";
        case WMSportDataTypeCalories:
            return @"WMSportDataTypeCalories";
        case WMSportDataTypeFastestPace:
            return @"WMSportDataTypeFastestPace";
        case WMSportDataTypeSlowestPace:
            return @"WMSportDataTypeSlowestPace";
        case WMSportDataTypeFastestSpeed:
            return @"WMSportDataTypeFastestSpeed";
        case WMSportDataTypeTotalSteps:
            return @"WMSportDataTypeTotalSteps";
        case WMSportDataTypeMaxStepFrequency:
            return @"WMSportDataTypeMaxStepFrequency";
        case WMSportDataTypeAverageHeartRate:
            return @"WMSportDataTypeAverageHeartRate";
        case WMSportDataTypeMaxHeartRate:
            return @"WMSportDataTypeMaxHeartRate";
        case WMSportDataTypeMinHeartRate:
            return @"WMSportDataTypeMinHeartRate";
        case WMSportDataTypeLimitHeartRateDuration:
            return @"WMSportDataTypeLimitHeartRateDuration";
        case WMSportDataTypeAnaerobicEnduranceDuration:
            return @"WMSportDataTypeAnaerobicEnduranceDuration";
        case WMSportDataTypeAerobicEnduranceDuration:
            return @"WMSportDataTypeAerobicEnduranceDuration";
        case WMSportDataTypeFatBurningDuration:
            return @"WMSportDataTypeFatBurningDuration";
        case WMSportDataTypeWarmUpDuration:
            return @"WMSportDataTypeWarmUpDuration";
        default:
            return @"Unknown";
    }
}

@interface RealTimeDataViewController ()
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic, strong) UIButton *getNowBtn;
@property (nonatomic, strong) DatePickerViewController *datePicker;
@property (nonatomic, strong) LSTPopView *popView;

@end

@implementation RealTimeDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.textView.frame = CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(self.view.frame) - 300);
    self.getNowBtn.frame = CGRectMake(20, CGRectGetMaxY(self.textView.frame) + 60, CGRectGetWidth(self.view.frame) - 40, 44);
}
-(UIButton *)getNowBtn{
    if (_getNowBtn == nil){
        _getNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getNowBtn setTitle:NSLocalizedString(@"Get Now", nil) forState:UIControlStateNormal];
        [_getNowBtn addTarget:self action:@selector(actionSelecteDate) forControlEvents:UIControlEventTouchUpInside];
        _getNowBtn.layer.masksToBounds = YES;
        _getNowBtn.layer.cornerRadius = 5;
        [_getNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getNowBtn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_getNowBtn];
    }
    return _getNowBtn;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;  // 不允许编辑
        _textView.scrollEnabled = YES;  // 允许滚动
        _textView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_textView];
    }
    return _textView;
}

-(void)gettextView:(NSString *)date{
    NSString *dateFormat = @"yyyy MM dd"; // 输入日期字符串的格式，根据实际情况修改
    // 创建一个 NSDateFormatter 对象，并设置日期格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    // 使用日期格式化程序将字符串转换为 NSDate
    NSDate *selectedDate = [dateFormatter dateFromString:date];

    // 获取用户当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 获取指定日期的年、月、日信息
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:selectedDate];
    // 将小时、分钟和秒设置为0
    components.hour = 0;
    components.minute = 0;
    components.second = 0;

    // 根据上述设置，重新生成 NSDate 对象，该对象代表当天的零点
    NSDate *dateAtMidnight = [calendar dateFromComponents:components];
    NSTimeInterval interval = [dateAtMidnight timeIntervalSince1970];

    self.textView.text = @"";
    @weakify(self);
    if ([self.title isEqualToString:NSLocalizedString(@"Sync step", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncStep syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMStepDataModel *> * _Nullable x) {
            @strongify(self);

            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel *m in x) {
                for(WMStepDataModel *step in m.datas){
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"steps:%ld\n",(long)step.steps];
                    [info appendString:[self getDateStringWithTimeStr:step.timestamp]];
    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(NSLocalizedString(@"Get Now (%@)", nil), nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync calorie", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncCalorie syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMCalorieDataModel *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel *m in x) {
                for(WMCalorieDataModel *ca in m.datas){
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"calorie:%ld\n",ca.calorie];
                    [info appendString:[self getDateStringWithTimeStr:ca.timestamp]];
                    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync activity time", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncActivityTime syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMActivityTimeDataModel *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel *m in x) {
                for(WMActivityTimeDataModel *activity in m.datas){
                    
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"activityTime:%ld\n",activity.activityTime];
                    [info appendString:[self getDateStringWithTimeStr:activity.timestamp]];
                    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync distance", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncDistance syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMDistanceDataModel *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel *m in x) {
                for(WMDistanceDataModel *distance in m.datas){
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"distance:%ld\n",distance.distance];
                    [info appendString:[self getDateStringWithTimeStr:distance.timestamp]];
                    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync 5min heart rate", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncHeartRate syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMBaseByDayDataModel<WMHeartRateDataModel *> *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
            //
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel<WMHeartRateDataModel *> *m in x) {
                for(WMHeartRateDataModel *heartRate in m.datas){
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"heartRate:%ld\n",heartRate.heartRate];
                    [info appendString:[self getDateStringWithTimeStr:heartRate.timestamp]];
    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
              
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync heart rate statistics", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncHeartRateStatistics syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMBaseByDayDataModel<WMHeartRateStatisticsDataModel *> *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel<WMHeartRateStatisticsDataModel *> *m in x) {
                for (WMHeartRateStatisticsDataModel *heartStatistics in m.datas) {
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"highestHeartRate:%ld\n",(long)heartStatistics.highestHeartRate];
                    [info appendFormat:@"lowestHeartRate:%ld\n",(long)heartStatistics.lowestHeartRate];
                    [info appendFormat:@"averageHeartRate:%f\n",heartStatistics.averageHeartRate];
                    [info appendString:[self getDateStringWithTimeStr:heartStatistics.timestamp]];
                    
                    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync blood oxygen", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncBloodOxygen syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMBaseByDayDataModel<WMBloodOxygenDataModel *> *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel<WMBloodOxygenDataModel *> *m in x) {
                for (WMBloodOxygenDataModel *bloodOxygen in m.datas) {
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@"bloodOxygen:%ld\n",(long)bloodOxygen.value];
                    [info appendString:[self getDateStringWithTimeStr:bloodOxygen.timestamp]];
                    //                [info appendFormat:@"duration:%f\n",m.duration];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync activity data", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncActivity syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMActivityDataModel  *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
//            for (WMBaseByDayDataModel<WMActivityDataModel *> *m in x) {
                for (WMActivityDataModel *activityData in x) {
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@" sportDataType:%ld\n",activityData.sport_type];
                    [info appendString:[self getDateStringWithTimeStr:activityData.ts_start]];
                    NSDictionary *personDict = [activityData mj_keyValues];
                    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:personDict options:0 error:nil] encoding:NSUTF8StringEncoding];
                    [info appendFormat:@"\ndata:%@\n",jsonString];
                    [info appendFormat:@"},\n\n"];
                }
//            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync activity type data", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncActivityTypeTime syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMBaseByDayDataModel<WMActivityTypeTimeDataModel *> *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMBaseByDayDataModel<WMActivityTypeTimeDataModel *> *m in x) {
                for (WMActivityTypeTimeDataModel *activityTypeTime in m.datas) {
                    [info appendFormat:@"{\n"];
                    [info appendFormat:@" activityType:%ld\n",activityTypeTime.activityType];
                    [info appendFormat:@" activityTime:%ld\n",activityTypeTime.activityTime];
                    [info appendString:[self getDateStringWithTimeStr:activityTypeTime.timestamp]];
                    [info appendFormat:@" },\n"];
                    [info appendFormat:@"},\n\n"];
                }
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }else if ([self.title isEqualToString:NSLocalizedString(@"Sync sleep data", nil)]){
        [SVProgressHUD showWithStatus:nil];
        [[[WatchManager sharedInstance].currentValue.datasSync.syncSleep syncDataWithStartTime:interval] subscribeNext:^(NSArray<WMSleepDataModel *> * _Nullable x) {
            @strongify(self);
            NSMutableString *info = [NSMutableString new];
//            [info appendFormat:@"latestSyncTime: %f\n",[WatchManager sharedInstance].currentValue.datasSync.syncStep.latestSyncTime];
            for (WMSleepDataModel *m in x) {
                [info appendFormat:@" bed_time:%@\n",[self getDateStringWithTimeStr:m.bed_time]];
                [info appendFormat:@" get_up_time:%@\n",[self getDateStringWithTimeStr:m.get_up_time]];
                NSDictionary *personDict = [m mj_keyValues];
                NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:personDict options:0 error:nil] encoding:NSUTF8StringEncoding];
                [info appendFormat:@" data:%@\n",jsonString];
                [info appendFormat:@" \n"];
                [info appendFormat:@"\n\n"];
            }
            self.textView.text = info;
            [self.getNowBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Get Now (%@)", nil),date.description] forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        } error:^(NSError * _Nullable error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Get Fail\n%@",error.description]];
        }];
    }

}

// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
- (NSString *)getDateStringWithTimeStr:(NSTimeInterval )time{
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}


/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)actionSelecteDate{

    @weakify(self);
    _datePicker = [[DatePickerViewController alloc] initWithValue:@"" title:@"time" height:300.0 type:DatePickerDataTypeCustom doneBlock:^(NSString * _Nonnull date) {
        @strongify(self);
        [self gettextView:date];
        self.datePicker = nil;
        [self.popView dismiss];
    } cancelBlock:^{
        @strongify(self);
        self.datePicker = nil;
        [self.popView dismiss];
    }];

    //创建弹窗PopViiew 指定父容器self.view, 不指定默认是app window
    _popView = [LSTPopView initWithCustomView:self.datePicker.view
                                       parentView:self.view
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
    //弹窗位置: 居中 贴顶 贴左 贴底 贴右
    self.popView.hemStyle = LSTHemStyleBottom;
    //点击背景触发
    self.popView.bgClickBlock = ^{
        @strongify(self);
        self.datePicker = nil;
        [ self.popView dismiss];
    };
    //弹窗显示
    [self.popView pop];
}
@end
