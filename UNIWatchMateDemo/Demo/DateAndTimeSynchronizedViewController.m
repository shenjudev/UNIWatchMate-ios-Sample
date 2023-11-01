//
//  DateAndTimeSynchronizedViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/11.
//

#import "DateAndTimeSynchronizedViewController.h"

@interface DateAndTimeSynchronizedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UILabel *timeNow;
@property (weak, nonatomic) IBOutlet UILabel *timeAfter15s;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation DateAndTimeSynchronizedViewController
NSString* NSStringFromTimeFormat(TimeFormat timeFormat) {
    switch (timeFormat) {
        case TimeFormatTWELVE_HOUR:
            return @"TimeFormatTWELVE_HOUR";
        case TimeFormatTWENTY_FOUR_HOUR:
            return @"TimeFormatTWENTY_FOUR_HOUR";
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"The date and time are synchronized", nil);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimerTick) userInfo:nil repeats:YES];
    
}
- (void)handleTimerTick {
    NSDate *currentDate = [NSDate date];
    NSDate *dateAfter15Seconds = [currentDate dateByAddingTimeInterval:120];
    self.timeNow.text = currentDate.description;
    self.timeAfter15s.text = dateAfter15Seconds.description;
    
}
- (void)dealloc {
    // 在对象销毁时确保定时器也被停止
    [self.timer invalidate];
    self.timer = nil;
}
- (IBAction)setCurrentTime24HourSystem:(id)sender {
    [self setTime:TimeFormatTWENTY_FOUR_HOUR];
}
- (IBAction)setCurrentTime12HourSystem:(id)sender {
    [self setTime:TimeFormatTWELVE_HOUR];
}
- (IBAction)setAfter15SecondsTime24HourSystem:(id)sender {
    [self setAfter15sTime:TimeFormatTWENTY_FOUR_HOUR];
}
- (IBAction)setAfter15SecondsTime12HourSystem:(id)sender {
    [self setAfter15sTime:TimeFormatTWELVE_HOUR];
}

-(void)setTime:(TimeFormat)timeFormat{
    @weakify(self);
    WMDateTimeModel *model = [[WMDateTimeModel alloc] init];
    model.currentDate = [NSDate date];
    model.timeFormat = timeFormat;
    
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    self.info.text = @"";
    [[[[wMPeripheral settings] dateTime] setConfigModel:model] subscribeNext:^(WMDateTimeModel * _Nullable x) {
        @strongify(self);
        self.info.text = [NSString stringWithFormat:@"%@\n%@",x.currentDate.description,NSStringFromTimeFormat(x.timeFormat)];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set time fail"];
    }];
}
-(void)setAfter15sTime:(TimeFormat)timeFormat{
    @weakify(self);
    WMDateTimeModel *model = [[WMDateTimeModel alloc] init];
    NSDate *currentDate = [NSDate date];
    NSDate *dateAfter15Seconds = [currentDate dateByAddingTimeInterval:120];
    model.currentDate = dateAfter15Seconds;
    model.timeFormat = timeFormat;
    
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    self.info.text = @"";
    [[[[wMPeripheral settings] dateTime] setConfigModel:model] subscribeNext:^(WMDateTimeModel * _Nullable x) {
        @strongify(self);
        self.info.text = [NSString stringWithFormat:@"%@\n%@",x.currentDate.description,NSStringFromTimeFormat(x.timeFormat)];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set time fail"];
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
