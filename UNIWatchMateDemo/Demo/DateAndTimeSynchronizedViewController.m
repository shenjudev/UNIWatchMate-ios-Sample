//
//  DateAndTimeSynchronizedViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/11.
//

#import "DateAndTimeSynchronizedViewController.h"

@interface DateAndTimeSynchronizedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UIButton *timeNow24;
@property (weak, nonatomic) IBOutlet UIButton *timeNow12;

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *time12Tip;
@property (weak, nonatomic) IBOutlet UILabel *time24Tip;
@property (weak, nonatomic) IBOutlet UILabel *timeNow;
@property (weak, nonatomic) IBOutlet UILabel *timeAfter15s;


@end

@implementation DateAndTimeSynchronizedViewController
NSString* NSStringFromTimeFormat(TimeFormat timeFormat) {
    switch (timeFormat) {
        case TimeFormatTWELVE_HOUR:
            return NSLocalizedString(@"12 hour system" , nil);
        case TimeFormatTWENTY_FOUR_HOUR:
            return NSLocalizedString(@"24 hour system" , nil);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.info.text =  NSLocalizedString(@"The result will be displayed here when you select the sync time", nil);
    self.timeNow12.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
    self.timeNow24.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
    self.time12Tip.text = NSLocalizedString(@"The result will be displayed here when you select the sync time", nil);
    self.time24Tip.text = NSLocalizedString(@"The result will be displayed here when you select the sync time", nil);
    // Do any additional setup after loading the view.
    self.timeNow.text =  NSLocalizedString(@"time now", nil);
    self.timeAfter15s.text =  NSLocalizedString(@"after 15s", nil);
    self.title = NSLocalizedString(@"The date and time are synchronized", nil);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimerTick) userInfo:nil repeats:YES];
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    @weakify(self);
    [[[[wMPeripheral settings] dateTime] getConfigModel] subscribeNext:^(WMDateTimeModel * _Nullable x) {
        @strongify(self);
        self.info.text = [NSString stringWithFormat:@"%@\n%@",x.currentDate.description,NSStringFromTimeFormat(x.timeFormat)];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set time fail"];
    }];
}
- (void)handleTimerTick {
    NSDate *currentDate = [NSDate date];
    NSDate *dateAfter15Seconds = [currentDate dateByAddingTimeInterval:120];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]]; // Set this parameter to the local time zone

    NSString *localizedDateString = [formatter stringFromDate:currentDate];
    NSString *localizedDateString15 = [formatter stringFromDate:dateAfter15Seconds];
    self.timeNow.text = localizedDateString;
    self.timeAfter15s.text = localizedDateString15;
    
}
- (void)dealloc {
    // Make sure the timer is also stopped when the object is destroyed
    [self.timer invalidate];
    self.timer = nil;
}
- (IBAction)setCurrentTime24HourSystem:(id)sender {
    [self setTime];
}


- (IBAction)setafter15Time12Hour:(id)sender {
    [self setAfter15sTime];
}

-(void)setTime{
   
    
    @weakify(self);
    WMDateTimeModel *model = [[WMDateTimeModel alloc] init];
    model.currentDate = [NSDate date];
    
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    self.info.text = @"";
    [[[[wMPeripheral settings] dateTime] setConfigModel:model] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterLongStyle];
            [formatter setTimeStyle:NSDateFormatterLongStyle];
            [formatter setTimeZone:[NSTimeZone localTimeZone]]; // 设置为本地时区
            self.info.text = [NSString stringWithFormat:@"%@\n%@",[formatter stringFromDate:model.currentDate],NSStringFromTimeFormat(model.timeFormat)];
        self.timeNow12.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
        self.timeNow24.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Set time fail"];
    }];
}

-(void)setAfter15sTime{
    self.timeNow12.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
    self.timeNow24.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
    
    @weakify(self);
    WMDateTimeModel *model = [[WMDateTimeModel alloc] init];
    NSDate *currentDate = [NSDate date];
    NSDate *dateAfter15Seconds = [currentDate dateByAddingTimeInterval:120];
    model.currentDate = dateAfter15Seconds;
    
    WMPeripheral *wMPeripheral = [[WatchManager sharedInstance] currentValue];
    self.info.text = @"";
    [[[[wMPeripheral settings] dateTime] setConfigModel:model] subscribeNext:^(NSNumber * _Nullable x) {
        @strongify(self);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeStyle:NSDateFormatterLongStyle];
        [formatter setTimeZone:[NSTimeZone localTimeZone]]; // 设置为本地时区
        self.info.text = [NSString stringWithFormat:@"%@\n%@",model.currentDate,NSStringFromTimeFormat(model.timeFormat)];
        self.timeNow12.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
        self.timeNow24.titleLabel.text =  NSLocalizedString(@"Synchronization time", nil);
      
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
