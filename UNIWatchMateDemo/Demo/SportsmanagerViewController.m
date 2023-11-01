//
//  SportsmanagerViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/24.
//

#import "SportsmanagerViewController.h"

@interface SportName : NSObject
@property (nonatomic, copy) NSString *zh_cn;
@property (nonatomic, copy) NSString *en;
@property (nonatomic, copy) NSString *de;
@property (nonatomic, copy) NSString *ar;
@property (nonatomic, copy) NSString *it;
@property (nonatomic, copy) NSString *es;
@property (nonatomic, copy) NSString *fr;
@property (nonatomic, copy) NSString *pt;
@property (nonatomic, copy) NSString *fa;
@property (nonatomic, copy) NSString *ru;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
@implementation SportName

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _zh_cn = dictionary[@"zh-cn"];
        _en = dictionary[@"en"];
        _de = dictionary[@"de"];
        _ar = dictionary[@"ar"];
        _it = dictionary[@"it"];
        _es = dictionary[@"es"];
        _fr = dictionary[@"fr"];
        _pt = dictionary[@"pt"];
        _fa = dictionary[@"fa"];
        _ru = dictionary[@"ru"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Chinese: %@, English: %@, German: %@, Arabic: %@, Italian: %@, Spanish: %@, French: %@, Portuguese: %@, Persian: %@, Russian: %@", self.zh_cn, self.en, self.de, self.ar, self.it, self.es, self.fr, self.pt, self.fa, self.ru];
}

@end


@interface SJSport : NSObject
@property (nonatomic, assign) NSInteger sportId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) SportName *names;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

@implementation SJSport

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _sportId = [dictionary[@"id"] integerValue];
        _type = [dictionary[@"type"] integerValue];
        _names = [[SportName alloc] initWithDictionary:dictionary[@"names"]];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Sport ID: %ld, Type: %ld, Names: %@", (long)self.sportId, (long)self.type, self.names];
}
@end

@interface SportsmanagerViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;

@end

@implementation SportsmanagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray arrayWithArray:@[
        [NSMutableArray arrayWithArray:@[]],
        [NSMutableArray arrayWithArray:@[]],
        [NSMutableArray arrayWithArray:@[]]
    ]];
    self.tableView.frame = self.view.frame;
    [self.view addSubview:self.tableView];
    [self getInfo];
}

-(void)getInfo{
    @weakify(self);
    [[WatchManager sharedInstance].currentValue.apps.configMotionApp.wm_getActivityTypes subscribeNext:^(NSArray<NSNumber *> * _Nullable x) {
        @strongify(self);
        [self showModel:x];
    } error:^(NSError * _Nullable error) {

    }];
}

-(void)showModel:(NSArray<NSNumber *> *) x{
    if ([x count] == 0){
        _dataArray = [NSMutableArray arrayWithArray:@[
            [NSMutableArray arrayWithArray:@[]],
            [NSMutableArray arrayWithArray:@[]],
            [NSMutableArray arrayWithArray:@[]]
        ]];
        [self.tableView reloadData];
        return;
    }
    NSArray *deviceSportInfos = [self loadSportsFromJSONFile];

    // 创建一个用于存放结果的可变数组
    NSMutableArray<SJSport *> *result = [NSMutableArray array];

    // 遍历x数组
    for (NSNumber *number in x) {
        // 在deviceSportInfos数组中搜索具有匹配sportId的SJSport对象
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sportId == %ld", number.integerValue];
        NSArray<SJSport *> *filtered = [deviceSportInfos filteredArrayUsingPredicate:predicate];

        // 如果找到匹配的对象，将其添加到结果数组中
        if (filtered.count > 0) {
            [result addObject:filtered.firstObject];
        }
    }


    // 创建一个包含result2所有sportId的集合
    NSMutableSet<NSNumber *> *result2SportIDs = [NSMutableSet set];
    for (SJSport *sport in result) {
        [result2SportIDs addObject:@(sport.sportId)];
    }

    // 找出所有在result1中但不在result2中的元素
    NSMutableArray<SJSport *> *difference = [NSMutableArray array];
    for (SJSport *sport in deviceSportInfos) {
        if (![result2SportIDs containsObject:@(sport.sportId)]) {
            [difference addObject:sport];
        }
    }
    if ([result count] <= 8){
        _dataArray = [NSMutableArray arrayWithArray:@[
            [NSMutableArray arrayWithArray:result],
            [NSMutableArray arrayWithArray:@[]],
            [NSMutableArray arrayWithArray:difference]
        ]];
        [self.tableView reloadData];
        return;
    }
    NSRange range = NSMakeRange(0, 8);
    NSArray *firstEight = [result subarrayWithRange:range];  // 获取前8个元素
    [result removeObjectsInRange:range];
    _dataArray = [NSMutableArray arrayWithArray:@[
        [NSMutableArray arrayWithArray:firstEight],
        [NSMutableArray arrayWithArray:result],
        [NSMutableArray arrayWithArray:difference]
    ]];
    [self.tableView reloadData];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _tableView.editing = YES; // 启动编辑模式
    }
    return _tableView;
}

- (NSArray<SJSport *> *)loadSportsFromJSONFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sports_data" ofType:@"json"];
    if (!filePath) {
        NSLog(@"Failed to locate sports.json in app bundle.");
        return nil;
    }

    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"Failed to load data from sports.json.");
        return nil;
    }

    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Failed to parse sports.json: %@", error);
        return nil;
    }
    NSArray *jsonArray = jsonDictionary[@"sports"];
    NSMutableArray<SJSport *> *sports = [NSMutableArray array];
    for (NSDictionary *dictionary in jsonArray) {
        SJSport *sport = [[SJSport alloc] initWithDictionary:dictionary];
        [sports addObject:sport];
    }
    return [sports copy];
}
/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return @"From device.Can not delete sports.Can order by move.";
    }else if (section == 1){
        return @"From device.Can delete.";
    }else{
        return @"Can add.";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    SJSport *sport = self.dataArray[indexPath.section][indexPath.row];
    cell.textLabel.text = sport.names.en;

    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    if (indexPath.section != 0){
        // 创建删除按钮
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (indexPath.section == 1){
            [deleteButton setTitle:@"delete" forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }else if (indexPath.section == 2){
            [deleteButton setTitle:@"add" forState:UIControlStateNormal];
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
        CGRect deleteButtonFrame = CGRectMake(cellWidth - 2 * buttonWidth - 10, 10, buttonWidth, 30);
        deleteButton.frame = deleteButtonFrame;

        [cell.contentView addSubview:deleteButton];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}
// 禁止删除行
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        return;
    }

    NSString *itemToMove = self.dataArray[sourceIndexPath.section][sourceIndexPath.row];
    [self.dataArray[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [self.dataArray[destinationIndexPath.section] insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self didMove];
}

- (void)deleteButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // 处理删除按钮点击事件
    [self.dataArray[1] removeObjectAtIndex:indexRow];
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    NSMutableArray *result = [NSMutableArray array];
    [result addObjectsFromArray:self.dataArray[0]];
    [result addObjectsFromArray:self.dataArray[1]];

    NSMutableArray *typs = [NSMutableArray array];
    for (SJSport *s in result) {
        [typs addObject:[NSNumber numberWithLong:s.sportId]];
    }

    [[[WatchManager sharedInstance].currentValue.apps.configMotionApp syncActivityType:typs] subscribeNext:^(NSArray<NSNumber *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showModel:x];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self getInfo];
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Deleta Fail\n%@",error.description]];
    }];
}
- (void)didMove{
    
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    NSMutableArray *result = [NSMutableArray array];
    [result addObjectsFromArray:self.dataArray[0]];
    [result addObjectsFromArray:self.dataArray[1]];

    NSMutableArray *typs = [NSMutableArray array];
    for (SJSport *s in result) {
        [typs addObject:[NSNumber numberWithLong:s.sportId]];
    }

    [[[WatchManager sharedInstance].currentValue.apps.configMotionApp syncActivityType:typs] subscribeNext:^(NSArray<NSNumber *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showModel:x];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self getInfo];
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Move Fail\n%@",error.description]];
    }];
}

- (void)addButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // 处理删除按钮点击事件
    if ([self.dataArray[1] count] >= 12){
        [SVProgressHUD showErrorWithStatus:@"You must delete some data first"];
        return;
    }

    SJSport *sport = self.dataArray[2][indexRow];
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    NSMutableArray *result = [NSMutableArray array];
    [result addObjectsFromArray:self.dataArray[0]];
    [result addObjectsFromArray:self.dataArray[1]];
    [result addObject:sport];

    NSMutableArray *typs = [NSMutableArray array];
    for (SJSport *s in result) {
        [typs addObject:[NSNumber numberWithLong:s.sportId]];
    }

    [[[WatchManager sharedInstance].currentValue.apps.configMotionApp syncActivityType:typs] subscribeNext:^(NSArray<NSNumber *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showModel:x];
    } error:^(NSError * _Nullable error) {
        @strongify(self);
        [self getInfo];
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Add Fail\n%@",error.description]];
    }];
}
@end
