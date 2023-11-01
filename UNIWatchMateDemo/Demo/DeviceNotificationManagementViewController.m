//
//  DeviceNotificationManagementViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/23.
//

#import "DeviceNotificationManagementViewController.h"

@interface MyMessageModel : NSObject
@property (nonatomic, assign) BOOL messagesEnabled;
@property (nonatomic, assign) BOOL facebookEnabled;
@property (nonatomic, assign) BOOL gmailEnabled;
@property (nonatomic, assign) BOOL instagramEnabled;
@property (nonatomic, assign) BOOL iOSMailEnabled;
@property (nonatomic, assign) BOOL LINEEnabled;
@property (nonatomic, assign) BOOL linkedInEnabled;
@property (nonatomic, assign) BOOL messengerEnabled;
@property (nonatomic, assign) BOOL outlookEnabled;
@property (nonatomic, assign) BOOL QQEnabled;
@property (nonatomic, assign) BOOL skypeEnabled;
@property (nonatomic, assign) BOOL snapchatEnabled;
@property (nonatomic, assign) BOOL telegramEnabled;
@property (nonatomic, assign) BOOL twitterEnabled;
@property (nonatomic, assign) BOOL weChatEnabled;
@property (nonatomic, assign) BOOL whatsAppEnabled;
@property (nonatomic, assign) BOOL whatsAppBusinessEnabled;

// 解析整数值并设置开关状态
- (void)setSwitchesFromInteger:(uint32_t)integerValue;

@end

@implementation MyMessageModel

- (void)setSwitchesFromInteger:(uint32_t)integerValue {
    self.messagesEnabled = (integerValue & WMMessageTypeMessages) != 0;
    self.facebookEnabled = (integerValue & WMMessageTypeFacebook) != 0;
    self.gmailEnabled = (integerValue & WMMessageTypeGmail) != 0;
    self.instagramEnabled = (integerValue & WMMessageTypeInstagram) != 0;
    self.iOSMailEnabled = (integerValue & WMMessageTypeiOSMail) != 0;
    self.LINEEnabled = (integerValue & WMMessageTypeLINE) != 0;
    self.linkedInEnabled = (integerValue & WMMessageTypeLinkedIn) != 0;
    self.messengerEnabled = (integerValue & WMMessageTypeMessenger) != 0;
    self.outlookEnabled = (integerValue & WMMessageTypeOutlook) != 0;
    self.QQEnabled = (integerValue & WMMessageTypeQQ) != 0;
    self.skypeEnabled = (integerValue & WMMessageTypeSkype) != 0;
    self.snapchatEnabled = (integerValue & WMMessageTypeSnapchat) != 0;
    self.telegramEnabled = (integerValue & WMMessageTypeTelegram) != 0;
    self.twitterEnabled = (integerValue & WMMessageTypeTwitter) != 0;
    self.weChatEnabled = (integerValue & WMMessageTypeWeChat) != 0;
    self.whatsAppEnabled = (integerValue & WMMessageTypeWhatsApp) != 0;
    self.whatsAppBusinessEnabled = (integerValue & WMMessageTypeWhatsAppBusiness) != 0;
}
- (uint32_t)convertToUint32 {
    uint32_t result = 0;

    if (self.messagesEnabled) {
        result |= WMMessageTypeMessages;
    }
    if (self.facebookEnabled) {
        result |= WMMessageTypeFacebook;
    }
    if (self.gmailEnabled) {
        result |= WMMessageTypeGmail;
    }
    if (self.instagramEnabled) {
        result |= WMMessageTypeInstagram;
    }
    if (self.iOSMailEnabled) {
        result |= WMMessageTypeiOSMail;
    }
    if (self.LINEEnabled) {
        result |= WMMessageTypeLINE;
    }
    if (self.linkedInEnabled) {
        result |= WMMessageTypeLinkedIn;
    }
    if (self.messengerEnabled) {
        result |= WMMessageTypeMessenger;
    }
    if (self.outlookEnabled) {
        result |= WMMessageTypeOutlook;
    }
    if (self.QQEnabled) {
        result |= WMMessageTypeQQ;
    }
    if (self.skypeEnabled) {
        result |= WMMessageTypeSkype;
    }
    if (self.snapchatEnabled) {
        result |= WMMessageTypeSnapchat;
    }
    if (self.telegramEnabled) {
        result |= WMMessageTypeTelegram;
    }
    if (self.twitterEnabled) {
        result |= WMMessageTypeTwitter;
    }
    if (self.weChatEnabled) {
        result |= WMMessageTypeWeChat;
    }
    if (self.whatsAppEnabled) {
        result |= WMMessageTypeWhatsApp;
    }
    if (self.whatsAppBusinessEnabled) {
        result |= WMMessageTypeWhatsAppBusiness;
    }

    return result;
}

@end

@interface DeviceNotificationManagementViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *notis; // 存储闹钟数据的数组
@property (nonatomic, strong) MyMessageModel *model;
@end

@implementation DeviceNotificationManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Device notification manager";
    [self getInfo];
}

-(UITableView *)tableView
{
    if (_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
-(void)getInfo{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.settings.message.getConfigModel subscribeNext:^(WMMessageModel * _Nullable x) {
        @strongify(self);
        [self showModel:x];
    } error:^(NSError * _Nullable error) {

    }];
}

-(void)showModel:(WMMessageModel *) x{
    MyMessageModel *myModel = [MyMessageModel new];
    [myModel setSwitchesFromInteger:x.type];
    _model = myModel;

    _notis =  @[
        @{@"title": @"短信 (Messages)", @"subtitle": @"com.apple.MobileSMS", @"enable": [NSNumber numberWithBool:self.model.messagesEnabled]},
        @{@"title": @"Facebook", @"subtitle": @"com.facebook.Facebook", @"enable": [NSNumber numberWithBool:self.model.facebookEnabled]},
        @{@"title": @"Gmail", @"subtitle": @"com.google.Gmail", @"enable": [NSNumber numberWithBool:self.model.gmailEnabled]},
        @{@"title": @"Instagram", @"subtitle": @"com.burbn.instagram", @"enable": [NSNumber numberWithBool:self.model.instagramEnabled]},
        @{@"title": @"iOS Mail", @"subtitle": @"com.apple.mobilemail", @"enable": [NSNumber numberWithBool:self.model.iOSMailEnabled]},
        @{@"title": @"LINE", @"subtitle": @"jp.naver.line", @"enable": [NSNumber numberWithBool:self.model.LINEEnabled]},
        @{@"title": @"LinkedIn", @"subtitle": @"com.linkedin.LinkedIn", @"enable": [NSNumber numberWithBool:self.model.linkedInEnabled]},
        @{@"title": @"Messenger (Facebook Messenger)", @"subtitle": @"com.facebook.Messenger", @"enable": [NSNumber numberWithBool:self.model.messengerEnabled]},
        @{@"title": @"Outlook", @"subtitle": @"com.microsoft.Office.Outlook", @"enable": [NSNumber numberWithBool:self.model.outlookEnabled]},
        @{@"title": @"QQ", @"subtitle": @"com.tencent.mqq", @"enable": [NSNumber numberWithBool:self.model.QQEnabled]},
        @{@"title": @"Skype", @"subtitle": @"com.skype.skype", @"enable": [NSNumber numberWithBool:self.model.skypeEnabled]},
        @{@"title": @"Snapchat", @"subtitle": @"com.toyopagroup.picaboo", @"enable": [NSNumber numberWithBool:self.model.snapchatEnabled]},
        @{@"title": @"Telegram", @"subtitle": @"ph.telegra.Telegraph", @"enable": [NSNumber numberWithBool:self.model.telegramEnabled]},
        @{@"title": @"Twitter", @"subtitle": @"com.atebits.Tweetie2", @"enable": [NSNumber numberWithBool:self.model.twitterEnabled]},
        @{@"title": @"WeChat", @"subtitle": @"com.tencent.xin", @"enable": [NSNumber numberWithBool:self.model.weChatEnabled]},
        @{@"title": @"WhatsApp", @"subtitle": @"net.whatsapp.WhatsApp", @"enable": [NSNumber numberWithBool:self.model.whatsAppEnabled]},
        @{@"title": @"Whatsapp Business", @"subtitle": @"net.whatsapp.WhatsApp4Business", @"enable": [NSNumber numberWithBool:self.model.whatsAppBusinessEnabled]}
    ];
    [self.tableView reloadData];

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
    return self.notis.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotisCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    NSDictionary *dic = self.notis[indexPath.row];

    cell.textLabel.text = dic[@"title"];

    cell.detailTextLabel.text = dic[@"subtitle"];

    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    // 创建开关
    UISwitch *switchView = [[UISwitch alloc] init];
    [switchView setOn:[dic[@"enable"] boolValue]];

    switchView.tag = indexPath.row + 1000;
    [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

    // 布局开关和删除按钮
    CGFloat buttonWidth = 60; // 按钮宽度
    CGFloat cellWidth = CGRectGetWidth(self.view.frame);

    // 计算开关的位置
    CGRect switchFrame = CGRectMake(cellWidth - buttonWidth - 10, 10, buttonWidth, 30);
    switchView.frame = switchFrame;

    // 将开关和删除按钮添加到单元格
    [cell.contentView addSubview:switchView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
- (void)switchValueChanged:(UISwitch *)sender {
    // 处理开关按钮状态改变事件
    NSInteger indexRow = sender.tag - 1000;
    BOOL enable = sender.isOn;
    switch (indexRow) {
        case 0:
            self.model.messagesEnabled = enable;
            break;
        case 1:
            self.model.facebookEnabled = enable;
            break;
        case 2:
            self.model.gmailEnabled = enable;
            break;
        case 3:
            self.model.instagramEnabled = enable;
            break;
        case 4:
            self.model.iOSMailEnabled = enable;
            break;
        case 5:
            self.model.LINEEnabled = enable;
            break;
        case 6:
            self.model.linkedInEnabled = enable;
            break;
        case 7:
            self.model.messengerEnabled = enable;
            break;
        case 8:
            self.model.outlookEnabled = enable;
            break;
        case 9:
            self.model.QQEnabled = enable;
            break;
        case 10:
            self.model.skypeEnabled = enable;
            break;
        case 11:
            self.model.snapchatEnabled = enable;
            break;
        case 12:
            self.model.telegramEnabled = enable;
            break;
        case 13:
            self.model.twitterEnabled = enable;
            break;
        case 14:
            self.model.weChatEnabled = enable;
            break;
        case 15:
            self.model.whatsAppEnabled = enable;
            break;
        case 16:
            self.model.whatsAppBusinessEnabled = enable;
            break;
        default:
            break;
    }
    

    WMMessageModel *model = [[WMMessageModel alloc] init];
    model.type = [self.model convertToUint32];
    [SVProgressHUD showWithStatus:nil];

    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.settings.message setConfigModel:model] subscribeNext:^(WMMessageModel * _Nullable x) {
        [SVProgressHUD dismiss];
        [self showModel:x];

    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Set Fail\n%@",error.description]];
    }];

}
@end
