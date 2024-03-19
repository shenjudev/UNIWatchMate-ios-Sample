//
//  AlarmsViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/19.
//

#import "FeaturesViewController.h"
#import <UNIWatchMate/UNIWatchMate.h>
#import <UNIWatchMate/WMDeviceInfoModel.h>

@interface FeaturesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WMFeatureSetModel *wMFeatureSetModel; // 存储闹钟数据的数组

@end

@implementation FeaturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"Features", nil);
    
    // 创建UITableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
       
    [self getFeatures];
}

-(void)getFeatures{
    @weakify(self);
    
    [[WatchManager sharedInstance].currentValue.infoModel.wm_getFeatureSet subscribeNext:^(WMFeatureSetModel * _Nullable x) {
        @strongify(self);
        self.wMFeatureSetModel = x;
       
        [self.tableView reloadData];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Get Fail", nil)];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger index = WMFeatureRestartDevice;
    return index+3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FeaturesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    int index = indexPath.row;
    if(indexPath.row == WMFeatureRestartDevice+2){
        index = 65;
    }else if(indexPath.row == WMFeatureRestartDevice+1){
        index = 64;
    }
    BOOL feature =  [self.wMFeatureSetModel.feature_mask isFeatureEnabled:(index)];
    NSString *result = [NSString stringWithFormat:@"%@", wMFeatureDescriptionForIndex(index)];

    cell.textLabel.text =  result;
    cell.detailTextLabel.text = feature ? @"YES" : @"NO";
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


 NSString * wMFeatureDescriptionForIndex(NSUInteger index) {
    switch (index) {
        case WMFeatureWeatherSync:
            return NSLocalizedString(@"Weather sync switch", nil);
        case WMFeatureFitnessRecord:
            return NSLocalizedString(@"Fitness record", nil);
        case WMFeatureHeartRate:
            return NSLocalizedString(@"Heart rate", nil);
        case WMFeatureCameraRemoteV1:
            return NSLocalizedString(@"Camera Remote Control (V1)", nil);
        case WMFeatureNotificationManagement:
            return NSLocalizedString(@"Notification management", nil);
        case WMFeatureAlarmSetting:
            return NSLocalizedString(@"Alarm setting", nil);
        case WMFeatureLocalMusicSync:
            return NSLocalizedString(@"Local music synchronization", nil);
        case WMFeatureContactSync:
            return NSLocalizedString(@"Contact synchronization", nil);
        case WMFeatureFindWatch:
            return NSLocalizedString(@"Find a watch", nil);
        case WMFeatureFindPhone:
            return NSLocalizedString(@"Find your phone", nil);
        case WMFeatureAppViewSetting:
            return NSLocalizedString(@"[Settings] Application view", nil);
        case WMFeatureIncomingCallRing:
            return NSLocalizedString(@"【 Setting 】 The incoming call rings", nil);
        case WMFeatureNotificationFeedback:
            return NSLocalizedString(@"[Settings] Notification touch", nil);
        case WMFeatureCrownFeedback:
            return NSLocalizedString(@"[Settings] Crown touch feedback", nil);
        case WMFeatureSystemFeedback:
            return NSLocalizedString(@"[Settings] System touch feedback", nil);
        case WMFeatureWristWakeScreen:
            return NSLocalizedString(@"[Settings] Raise the wrist and light the screen", nil);
        case WMFeatureBloodOxygen:
            return NSLocalizedString(@"Blood oxygen", nil);
        case WMFeatureBloodPressure:
            return NSLocalizedString(@"Blood pressure", nil);
        case WMFeatureBloodSugar:
            return NSLocalizedString(@"Blood Sugar", nil);
        case WMFeatureSleepTracking:
            return NSLocalizedString(@"Sleep (Settings + Data)", nil);
        case WMFeatureEbookSync:
            return NSLocalizedString(@"E-book synchronization", nil);
        case WMFeatureSlowMode:
            return NSLocalizedString(@"Is it Slow mode (w20a)?", nil);
        case WMFeatureCameraRemotePreview:
            return NSLocalizedString(@"Camera remote supports preview", nil);
        case WMFeatureVideoFileSync:
            return NSLocalizedString(@"Video File Synchronization (avi)", nil);
        case WMFeaturePaymentCode:
            return NSLocalizedString(@"Collection code", nil);
        case WMFeatureWatchFaceMarket:
            return NSLocalizedString(@"Dial market", nil);
        case WMFeatureNotificationExpansion:
            return NSLocalizedString(@"Whether the notification list is fully expanded", nil);
        case WMFeatureCallBluetooth:
            return NSLocalizedString(@"Talking bluetooth", nil);
        case WMFeatureShowCallBluetoothOff:
            return NSLocalizedString(@"Displays Bluetooth off call", nil);
        case WMFeatureEmergencyContacts:
            return NSLocalizedString(@"Emergency contact", nil);
        case WMFeatureSyncFavContacts:
            return NSLocalizedString(@"Synchronize favorites contacts", nil);
        case WMFeatureQuickReply:
            return NSLocalizedString(@"Quick reply", nil);
        case WMFeatureStepGoal:
            return NSLocalizedString(@"Step goal", nil);
        case WMFeatureCalorieGoal:
            return NSLocalizedString(@"Calorie target", nil);
        case WMFeatureExerciseDurationGoal:
            return NSLocalizedString(@"Activity duration objective", nil);
        case WMFeatureSedentaryReminder:
            return NSLocalizedString(@"Sedentary reminder", nil);
        case WMFeatureDrinkWaterReminder:
            return NSLocalizedString(@"Drink water reminder", nil);
        case WMFeatureHandWashingReminder:
            return NSLocalizedString(@"Hand-washing reminder", nil);
        case WMFeatureAutoHeartRateMonitoring:
            return NSLocalizedString(@"Automatic heart rate detection", nil);
        case WMFeatureREMSleepTracking:
            return NSLocalizedString(@"REM rapid eye movement", nil);
        case WMFeatureMultipleSportModes:
            return NSLocalizedString(@"Whether to support multiple sports", nil);
        case WMFeatureFixedSportTypes:
            return NSLocalizedString(@"Displays fixed motion types", nil);
        case WMFeatureAutoSportRecognitionStart:
            return NSLocalizedString(@"Motion begins with self-recognition", nil);
        case WMFeatureAutoSportRecognitionEnd:
            return NSLocalizedString(@"The motion self-recognition ends", nil);
        case WMFeatureAlarmLabel:
            return NSLocalizedString(@"Alarm label", nil);
        case WMFeatureAlarmNote:
            return NSLocalizedString(@"Alarm clock note", nil);
        case WMFeatureWorldClock:
            return NSLocalizedString(@"World clock", nil);
        case WMFeatureAppSwitchDeviceLanguage:
            return NSLocalizedString(@"app switches device language", nil);
        case WMFeatureWidgets:
            return NSLocalizedString(@"widget", nil);
        case WMFeatureAppAdjustsDeviceVolume:
            return NSLocalizedString(@"The App adjusts the volume of the device", nil);
        case WMFeatureQuietHeartRateAlert:
            return NSLocalizedString(@"Quiet heart rate alert", nil);
        case WMFeatureExerciseHeartRateAlert:
            return NSLocalizedString(@"Exercise heart rate is too high alert", nil);
        case WMFeatureDailyHeartRateAlert:
            return NSLocalizedString(@"Daily heart rate alerts", nil);
        case WMFeatureContinuousBloodOxygen:
            return NSLocalizedString(@"Continuous oxygen", nil);
        case WMFeatureBluetoothDisconnectionAlert:
            return NSLocalizedString(@"Bluetooth disconnection reminder setting", nil);
        case WMFeatureCallBluetoothBLENameMatching:
            return NSLocalizedString(@"Whether call Bluetooth has the same name as BLE", nil);
        case WMFeatureEventReminder:
            return NSLocalizedString(@"Event reminder", nil);
        case WMFeatureScreenOnReminder:
            return NSLocalizedString(@"Light up reminder", nil);
        case WMFeatureRestartDevice:
            return NSLocalizedString(@"Restart the device", nil);
        case WMFeatureNavigation:
            return NSLocalizedString(@"Navigation", nil);
        case WMFeatureCompass:
            return NSLocalizedString(@"Compass", nil);
        default:
            return @"Unknown feature";
    }
}

@end
