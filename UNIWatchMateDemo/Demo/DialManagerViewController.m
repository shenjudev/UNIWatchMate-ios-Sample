//
//  DialManagerViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/12.
//

#import "DialManagerViewController.h"
#import "DialModel.h"

@interface DialManagerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RACReplaySubject<NSMutableArray<DialModel *> *> *currents;
@property (nonatomic, strong) NSMutableArray *currentsValue; // 用于保存最新的值
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation DialManagerViewController
- (void)dealloc
{
    if (self.alertController != nil){
        [self.alertController dismissViewControllerAnimated:false completion:nil];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _currents = [RACReplaySubject replaySubjectWithCapacity:1];
    _currentsValue = [NSMutableArray new];
    // 初始化tableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 订阅 currents 来更新 currentsValue
    [self.currents subscribeNext:^(NSMutableArray<NSMutableArray<DialModel *>*> *peripherals) {
        self.currentsValue = peripherals;
        [self.tableView reloadData]; // 刷新表格数据
    }];
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.dialApp.dialList subscribeNext:^(NSArray<WMDialModel *> * _Nullable x) {
        @strongify(self);
        NSArray *array = [self changeToDialModel:x];
        [self.currents sendNext:array];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Get Fail"];
    }];
    [self getDials];
}
-(NSArray *)changeToDialModel:(NSArray<WMDialModel *> * _Nullable )x{
    
    NSMutableArray *fromDeviceArray = [[NSMutableArray alloc] init];
    for (WMDialModel *dialModel in x){
        DialModel *model = [DialModel new];
        model.model = dialModel;
        model.canInstall = NO;
        [fromDeviceArray addObject:model];
    }
    
    NSMutableArray *customerArray = [[NSMutableArray alloc] init];
    
    DialModel *model1 = [DialModel new];
    model1.image = @"aab168c15c7b40eab361ca98fdd213ee";
    model1.path = @"aab168c15c7b40eab361ca98fdd213ee.dial";
    WMDialModel *dialModel1 = [WMDialModel new];
    dialModel1.identifier = @"aab168c15c7b40eab361ca98fdd213ee";
    dialModel1.isBuiltIn = NO;
    model1.canInstall = YES;
    model1.model = dialModel1;
    [customerArray addObject:model1];
    
    DialModel *model2 = [DialModel new];
    model2.image = @"8c637a6c26d476db361051786e773df7";
    model2.path = @"8c637a6c26d476db361051786e773df7.dial";
    WMDialModel *dialModel2 = [WMDialModel new];
    dialModel2.identifier = @"8c637a6c26d476db361051786e773df7";
    dialModel2.isBuiltIn = NO;
    model2.canInstall = YES;
    model2.model = dialModel2;
    [customerArray addObject:model2];
    
    DialModel *model3 = [DialModel new];
    model3.image = @"59c4aad46ed434ca58786f3232aba673";
    model3.path = @"59c4aad46ed434ca58786f3232aba673.dial";
    WMDialModel *dialModel3 = [WMDialModel new];
    dialModel3.identifier = @"59c4aad46ed434ca58786f3232aba673";
    dialModel3.isBuiltIn = NO;
    model3.canInstall = YES;
    model3.model = dialModel3;
    [customerArray addObject:model3];
    
    DialModel *model4 = [DialModel new];
    model4.image = @"4974f889d52c4a519eac9ea409b3295c";
    model4.path = @"4974f889d52c4a519eac9ea409b3295c.dial";
    WMDialModel *dialModel4 = [WMDialModel new];
    dialModel4.identifier = @"4974f889d52c4a519eac9ea409b3295c";
    dialModel4.isBuiltIn = NO;
    model4.canInstall = YES;
    model4.model = dialModel4;
    [customerArray addObject:model4];
    
    DialModel *model5 = [DialModel new];
    model5.image = @"1245156a62de4d6d8d60d8f8ff751302";
    model5.path = @"1245156a62de4d6d8d60d8f8ff751302.dial";
    WMDialModel *dialModel5 = [WMDialModel new];
    dialModel5.identifier = @"1245156a62de4d6d8d60d8f8ff751302";
    dialModel5.isBuiltIn = NO;
    model5.canInstall = YES;
    model5.model = dialModel5;
    [customerArray addObject:model5];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:fromDeviceArray];
    [array addObject:customerArray];

    return  array;
}
-(void)getDials{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.dialApp.syncDialList subscribeNext:^(NSArray<WMDialModel *> * _Nullable x) {
        @strongify(self);
        NSArray *array = [self changeToDialModel:x];
        [self.currents sendNext:array];

    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"Get Fail"];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.currentsValue.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currentsValue[section] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DialModel *dialModel = self.currentsValue[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    }
    // 设置左侧标签
    cell.textLabel.text = dialModel.model.identifier;
    if (dialModel.model.isBuiltIn == YES){
        // 设置右侧详情文本
        cell.detailTextLabel.text =  @"BuiltIn";
        // 设置尖头样式
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = nil;

    }else{
        // 设置右侧详情文本
        cell.detailTextLabel.text = @"";
        // 设置尖头样式
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:dialModel.image];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DialModel *dialModel = self.currentsValue[indexPath.section][indexPath.row];

    if (dialModel.model.isBuiltIn ==  YES){
        [SVProgressHUD showErrorWithStatus:@"Built in,Cannot delete."];
        return;
    }
    if (dialModel.model.isBuiltIn ==  NO && dialModel.canInstall == NO){
        [self deleteDialFromDevice:dialModel.model.identifier];
        return;
    }
    if (dialModel.path != nil){
        [self sendDial:dialModel.path];
    }

}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return  @"The dial from the device";
    }else{
        return  @"Demo dial.You can send to device";
    }
}
- (void)sendDial:(NSString *)path{
    NSString * desPath = [self copyFileFromAssetsWithName:path toDirectory:NSTemporaryDirectory()  insideSubDirectory:@"Dial"];
    if (desPath == nil){
        return;
    }
    @weakify(self)
    [[[WatchManager sharedInstance].currentValue.apps.fileApp startTransferFile:[NSURL fileURLWithPath:desPath] fileType:WMActivityTypeDIAL] subscribeNext:^(WMProgressModel * _Nullable x) {
        [SVProgressHUD showProgress:x.progress / 100.0 status:[NSString stringWithFormat:@"data:%.2f%%",x.progress]];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self resendDial:path error:error.description];
    } completed:^{
        [SVProgressHUD showSuccessWithStatus:@"Dial install successed."];
        [self getDials];
    }];
}

- (nullable NSString *)copyFileFromAssetsWithName:(NSString *)name
                                      toDirectory:(NSString *)directory
                               insideSubDirectory:(NSString *)subDirectory
{
    NSString *type = @".dial";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[name stringByReplacingOccurrencesOfString:type withString:@""] ofType:type];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"无法 获取数据");
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *subDirectoryPath = [directory stringByAppendingPathComponent:subDirectory];

    // 创建子目录（如果不存在）
    if (![fileManager fileExistsAtPath:subDirectoryPath]) {
        NSError *dirError;
        [fileManager createDirectoryAtPath:subDirectoryPath withIntermediateDirectories:YES attributes:nil error:&dirError];
        
        if (dirError) {
            NSLog(@"创建子目录失败: %@", [dirError localizedDescription]);
            return nil;
        }
    }

    NSString *destinationPath = [subDirectoryPath stringByAppendingPathComponent:name];

    // 如果目标文件已存在，删除它
    if ([fileManager fileExistsAtPath:destinationPath]) {
        NSError *deleteError;
        [fileManager removeItemAtPath:destinationPath error:&deleteError];
        if (deleteError) {
            NSLog(@"删除已存在的文件失败: %@", [deleteError localizedDescription]);
            return nil;
        }
    }

    // 将数据写入文件
    NSError *writeError;
    if ([data writeToFile:destinationPath options:NSDataWritingAtomic error:&writeError]) {
        return destinationPath;
    } else {
        NSLog(@"写入文件失败: %@", [writeError localizedDescription]);
        return nil;
    }
}
- (nullable NSString *)copyPngFromAssetsWithName:(NSString *)name
                                     toDirectory:(NSString *)directory
                              insideSubDirectory:(NSString *)subDirectory
{
    
    UIImage *image = [UIImage imageNamed:name];
    NSData *data = UIImageJPEGRepresentation(image, 0.5); // 1.0表示最高质量
    if (!data) {
        NSLog(@"无法 获取数据");
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *subDirectoryPath = [directory stringByAppendingPathComponent:subDirectory];

    // 创建子目录（如果不存在）
    if (![fileManager fileExistsAtPath:subDirectoryPath]) {
        NSError *dirError;
        [fileManager createDirectoryAtPath:subDirectoryPath withIntermediateDirectories:YES attributes:nil error:&dirError];
        
        if (dirError) {
            NSLog(@"创建子目录失败: %@", [dirError localizedDescription]);
            return nil;
        }
    }

    NSString *destinationPath = [subDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];

    // 如果目标文件已存在，删除它
    if ([fileManager fileExistsAtPath:destinationPath]) {
        NSError *deleteError;
        [fileManager removeItemAtPath:destinationPath error:&deleteError];
        if (deleteError) {
            NSLog(@"删除已存在的文件失败: %@", [deleteError localizedDescription]);
            return nil;
        }
    }

    // 将数据写入文件
    NSError *writeError;
    if ([data writeToFile:destinationPath options:NSDataWritingAtomic error:&writeError]) {
        return destinationPath;
    } else {
        NSLog(@"写入文件失败: %@", [writeError localizedDescription]);
        return nil;
    }
}
-(void)deleteDialFromDevice:(NSString *)identifier{
    _alertController = [UIAlertController alertControllerWithTitle:nil message:@"This is a watch face mounted on the watch, can be removed, do you want to delete?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 用户点击取消按钮后的处理代码
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 用户点击确定按钮后的处理代码
        [self deleteDial:identifier];
    }];

    [self.alertController addAction:cancelAction];
    [self.alertController addAction:okAction];
    [self presentViewController:self.alertController animated:YES completion:nil];
}
-(void)deleteDial:(NSString *)identifier{
    WMDialModel *model = [WMDialModel new];
    model.identifier = identifier;
    model.isBuiltIn = false;
    @weakify(self)
    [SVProgressHUD showWithStatus:nil];
    [[[WatchManager sharedInstance].currentValue.apps.dialApp deleteDial:model] subscribeNext:^(NSArray<WMDialModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"Delete Success."];
        NSArray *array = [self changeToDialModel:x];
        [self.currents sendNext:array];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Delete fail."];
    }];
}
-(void)resendDial:(NSString *)path error:(NSString *)error{
    _alertController = [UIAlertController alertControllerWithTitle:nil message:error preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 用户点击取消按钮后的处理代码
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 用户点击确定按钮后的处理代码
        [self sendDial:path];
    }];

    [self.alertController addAction:cancelAction];
    [self.alertController addAction:okAction];
    [self presentViewController:self.alertController animated:YES completion:nil];
}
@end

