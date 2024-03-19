//
//  WeatherViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/25.
//

#import "WeatherViewController.h"
#import "WeatherCreateHelper.h"

@interface WeatherViewController ()
@property (nonatomic,strong) WMWeatherModel *currentWeatherModel;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIButton *generateNewBtn;
@property (nonatomic,strong) UIButton *sendNowBtn;

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Weather";
    self.view.backgroundColor = [UIColor whiteColor];
    self.textView.frame = CGRectMake(20, 100, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(self.view.frame) - 300);
    self.generateNewBtn.frame = CGRectMake(20, CGRectGetMaxY(self.textView.frame) + 60, CGRectGetWidth(self.view.frame) - 40, 44);
    self.sendNowBtn.frame = CGRectMake(20, CGRectGetMaxY(self.generateNewBtn.frame) + 20, CGRectGetWidth(self.view.frame) - 40, 44);
    [self generateNew];


}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
        _textView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_textView];
    }
    return _textView;
}

-(UIButton *)sendNowBtn{
    if (_sendNowBtn == nil){
        _sendNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendNowBtn setTitle:NSLocalizedString(@"Send Now", nil) forState:UIControlStateNormal];
        [_sendNowBtn addTarget:self action:@selector(sendNow) forControlEvents:UIControlEventTouchUpInside];
        _sendNowBtn.layer.masksToBounds = YES;
        _sendNowBtn.layer.cornerRadius = 5;
        [_sendNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendNowBtn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_sendNowBtn];
    }
    return _sendNowBtn;
}

-(UIButton *)generateNewBtn{
    if (_generateNewBtn == nil){
        _generateNewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_generateNewBtn setTitle:NSLocalizedString(@"Generate new", nil) forState:UIControlStateNormal];
        [_generateNewBtn addTarget:self action:@selector(generateNew) forControlEvents:UIControlEventTouchUpInside];
        _generateNewBtn.layer.masksToBounds = YES;
        _generateNewBtn.layer.cornerRadius = 5;
        [_generateNewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_generateNewBtn setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_generateNewBtn];
    }
    return _generateNewBtn;
}

-(void)generateNew{
    _currentWeatherModel = [WeatherCreateHelper generateNew];

    _textView.text = [self showInfo];
}

-(NSString *)showInfo{
    return  [[self weatherModeltoDictionary:self.currentWeatherModel] jsonDescription];
}

-(void)sendNow{
    [SVProgressHUD showWithStatus:nil];
    RACSignal *day7Signal = [[[WatchManager sharedInstance].currentValue.apps.weatherForecastApp pushWeatherDay7:self.currentWeatherModel] catch:^RACSignal * _Nonnull(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"7 days:Set Fail\n%@", error.description]];
        return [RACSignal empty];
    }];
//    [[[WatchManager sharedInstance].currentValue.apps.weatherForecastApp pushWeatherDay7:self.currentWeatherModel] subscribeNext:^(NSNumber * _Nullable x) {
//        
//    }];
//    [[[WatchManager sharedInstance].currentValue.apps.weatherForecastApp pushWeatherHour24:self.currentWeatherModel] subscribeNext:^(NSNumber * _Nullable x) {
//        
//    }];
    // Create a second signal
    RACSignal *hour24Signal = [[[WatchManager sharedInstance].currentValue.apps.weatherForecastApp pushWeatherHour24:self.currentWeatherModel] catch:^RACSignal * _Nonnull(NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"24 Hours:Set Fail\n%@", error.description]];
        return [RACSignal empty];
    }];

    // Combine two signals
    [[RACSignal combineLatest:@[day7Signal, hour24Signal]] subscribeNext:^(RACTuple * _Nullable x) {
        [SVProgressHUD dismiss];
        NSNumber *day7Result = x.first;
        NSNumber *hour24Result = x.second;
        NSString *status = [NSString stringWithFormat:@"Push Success\nDay7: %@\n24 Hours: %@", day7Result, hour24Result];
        [SVProgressHUD showSuccessWithStatus:status];
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
-(NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // Set the date format to UTC 24 hours
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    // Convert an NSDate object to a UTC 24-hour date string using a date formatter
    NSString *formattedDate = [dateFormatter stringFromDate:date];

    return formattedDate;
}
- (NSDictionary *)weatherModeltoDictionary:(WMWeatherModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // Create a date formatter



    [dict setValue:[self dateToString:model.pubDate] forKey:@"pubDate"];

    if (model.location) {
        [dict setValue:[self locationToDictionary:self.currentWeatherModel.location] forKey:@"location"];
    }

    if (model.weatherForecast) {
        NSMutableArray *weatherForecastArray = [NSMutableArray array];
        for (WMWeatherForecastModel *forecastModel in model.weatherForecast) {
            [weatherForecastArray addObject:[self weatherForecastToDictionary:forecastModel]];
        }
        [dict setValue:weatherForecastArray forKey:@"weatherForecast"];
    }

    if (model.todayWeather) {
        NSMutableArray *todayWeatherArray = [NSMutableArray array];
        for (WMTodayWeatherModel *todayWeatherModel in self.currentWeatherModel.todayWeather) {
            [todayWeatherArray addObject:[self todayWeatherToDictionary:todayWeatherModel]];
        }
        [dict setValue:todayWeatherArray forKey:@"todayWeather"];
    }

    return [dict copy];
}

- (NSDictionary *)locationToDictionary:(WMLocationModel *)model{

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (model.city) {
        [dict setValue:model.city forKey:@"city"];
    }
    if (model.country) {
        [dict setValue:model.country forKey:@"country"];
    }


    return [dict copy];
}
- (NSDictionary *)weatherForecastToDictionary:(WMWeatherForecastModel *)model {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setValue:@(model.lowTemp) forKey:@"lowTemp"];
    [dict setValue:@(model.highTemp) forKey:@"highTemp"];
    [dict setValue:@(model.curTemp) forKey:@"curTemp"];
    [dict setValue:@(model.humidity) forKey:@"humidity"];
    [dict setValue:@(model.uvIndex) forKey:@"uvIndex"];
    [dict setValue:@(model.dayCode) forKey:@"dayCode"];
    [dict setValue:@(model.nightCode) forKey:@"nightCode"];
    if (model.dayDesc) {
        [dict setValue:model.dayDesc forKey:@"dayDesc"];
    }
    if (model.nightDesc) {
        [dict setValue:model.nightDesc forKey:@"nightDesc"];
    }
    [dict setValue:[self dateToString:model.date] forKey:@"date"];

    return [dict copy];
}

- (NSDictionary *)todayWeatherToDictionary:(WMTodayWeatherModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:@(model.curTemp) forKey:@"curTemp"];
    [dict setValue:@(model.humidity) forKey:@"humidity"];
    [dict setValue:@(model.uvIndex) forKey:@"uvIndex"];
    [dict setValue:@(model.weatheCode) forKey:@"weatheCode"];
    if (model.weatherDesc) {
        [dict setValue:model.weatherDesc forKey:@"weatherDesc"];
    }
    [dict setValue:[self dateToString:model.date] forKey:@"date"];

    return [dict copy];
}

@end
