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

@interface SportsmanagerViewController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *dataArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *supportedTypes;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *fixedTypes;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *variableTypes;
@property (nonatomic, strong) NSString *currentLanguageCode;

@end

@implementation SportsmanagerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Sports manger",nil);

    // Gets the code that applies the current language
    self.currentLanguageCode = [[NSLocale preferredLanguages] firstObject];
    NSLog(@"Current Language Code: %@", self.currentLanguageCode);


    
    _supportedTypes= [NSMutableArray array];
    _fixedTypes= [NSMutableArray array];
    _variableTypes= [NSMutableArray array];
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
    [[RACSignal zip:@[[WatchManager sharedInstance].currentValue.apps.configMotionApp.getSupportedActivityTypes, [WatchManager sharedInstance].currentValue.apps.configMotionApp.getFixedActivityTypes
                      ,[WatchManager sharedInstance].currentValue.apps.configMotionApp.getVariableActivityTypes]] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        RACTupleUnpack(NSArray<NSNumber *> *supportedTypes, NSArray<NSNumber *> *fixedTypes ,NSArray<NSNumber *> *variableTypes) = x;
        [self->_supportedTypes removeAllObjects];
        [self->_supportedTypes addObjectsFromArray:supportedTypes];
        [self->_fixedTypes removeAllObjects];
        [self->_fixedTypes addObjectsFromArray:fixedTypes];
        [self->_variableTypes removeAllObjects];
        [self->_variableTypes addObjectsFromArray:variableTypes];
        [self showModel: self->_supportedTypes fixed:self->_fixedTypes variable:self->_variableTypes];
        
    } error:^(NSError * _Nullable error) {
        
    }];
}

-(void)showModel:(NSMutableArray *) supporteds fixed:(NSMutableArray *) fixeds variable:(NSMutableArray *) variables{
    
        NSMutableArray<SJSport *> *supportSJSports = [NSMutableArray array];
        NSMutableArray<SJSport *> *fixedSJSports = [NSMutableArray array];
        NSMutableArray<SJSport *> *variableSJSports = [NSMutableArray array];

    NSArray *deviceSportInfos = [self loadSportsFromJSONFile];
//
//    // Creates a variable array to hold the results
//    NSMutableArray<SJSport *> *result = [NSMutableArray array];
//
    // Traverse the x array

    for (NSNumber *number in fixeds) {
        // Search the deviceSportInfos array for SJSport objects with matching sportId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sportId == %@", number];
        NSArray<SJSport *> *filtered = [deviceSportInfos filteredArrayUsingPredicate:predicate];
        // If a match is found, it is added to the result array
        if (filtered.count > 0) {
            [fixedSJSports addObject:filtered.firstObject];
        }
    }
    for (NSNumber *number in variables) {
        // Search the deviceSportInfos array for SJSport objects with matching sportId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sportId == %@", number];
        NSArray<SJSport *> *filtered = [deviceSportInfos filteredArrayUsingPredicate:predicate];
        // If a match is found, it is added to the result array
        if (filtered.count > 0) {
            [variableSJSports addObject:filtered.firstObject];
        }
    }
    for (NSNumber *number in supporteds) {
        // Search the deviceSportInfos array for SJSport objects with matching sportId
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sportId == %@", number];
        NSArray<SJSport *> *filtered = [deviceSportInfos filteredArrayUsingPredicate:predicate];
        NSArray<SJSport *> *fixedFiltered = [fixedSJSports filteredArrayUsingPredicate:predicate];
        NSArray<SJSport *> *variableFiltered = [variableSJSports filteredArrayUsingPredicate:predicate];
        // If a match is found, it is added to the result array
        if (filtered.count > 0 && fixedFiltered.count == 0 && variableFiltered.count == 0) {
            [supportSJSports addObject:filtered.firstObject];
        }
    }
  
    _dataArray = [NSMutableArray arrayWithArray:@[
        [NSMutableArray arrayWithArray:fixedSJSports],
        [NSMutableArray arrayWithArray:variableSJSports],
        [NSMutableArray arrayWithArray:supportSJSports]
    ]];
    [self.tableView reloadData];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.layoutMargins = UIEdgeInsetsZero;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _tableView.editing = YES; // Start edit mode
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
        return NSLocalizedString(@"From device.Can not delete sports.Can order by move.", nil);
    }else if (section == 1){
        return NSLocalizedString(@"From device.Can delete.", nil);
    }else{
        return NSLocalizedString(@"Can add.", nil);
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
    
    NSRange range = [self.currentLanguageCode rangeOfString:@"zh"];
    
    if (range.location != NSNotFound) {
        cell.textLabel.text = sport.names.zh_cn;
    }else{
        cell.textLabel.text = sport.names.en;
    }
        
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (indexPath.section != 0){
        // Create delete button
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (indexPath.section == 1){
            [deleteButton setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }else if (indexPath.section == 2){
            [deleteButton setTitle:NSLocalizedString(@"add", nil) forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteButton.layer.masksToBounds = YES;
        deleteButton.layer.cornerRadius = 5;
        [deleteButton setBackgroundColor:[UIColor redColor]];
        deleteButton.tag = indexPath.row + 100;
        
        // Layout switch and delete button
        CGFloat buttonWidth = 60; // Button width
        CGFloat cellWidth = CGRectGetWidth(self.view.frame);
        
        // Calculate the location of the delete button
        CGRect deleteButtonFrame = CGRectMake(cellWidth -  buttonWidth - 50, 10, buttonWidth, 30);
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        return;
    }
    
    NSNumber *itemToMove = self.fixedTypes[sourceIndexPath.row];
    [self.fixedTypes removeObjectAtIndex:sourceIndexPath.row];
    [self.fixedTypes insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self didMove];
}

- (void)deleteButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // Handle delete button click events
    [self.variableTypes removeObjectAtIndex:indexRow];
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);

        [[[WatchManager sharedInstance].currentValue.apps.configMotionApp syncVariableActivityType:self.variableTypes] subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self showModel: self->_supportedTypes fixed:self->_fixedTypes variable:self->_variableTypes];
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
    
        [[[WatchManager sharedInstance].currentValue.apps.configMotionApp syncFixedActivityType: self.fixedTypes] subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self showModel: self->_supportedTypes fixed:self->_fixedTypes variable:self->_variableTypes];
        } error:^(NSError * _Nullable error) {
            @strongify(self);
            [self getInfo];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Move Fail\n%@",error.description]];
        }];
}

- (void)addButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    
    if ([self.dataArray[1] count] >= 12){
        [SVProgressHUD showErrorWithStatus:@"You must delete some data first"];
        return;
    }
    
    SJSport *sport = self.dataArray[2][indexRow];
    [self.variableTypes addObject: [NSNumber numberWithInt: sport.sportId]];
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    
        [[[WatchManager sharedInstance].currentValue.apps.configMotionApp syncVariableActivityType:self.variableTypes] subscribeNext:^(NSNumber * _Nullable x) {
            @strongify(self);
            [SVProgressHUD dismiss];
            [self showModel: self->_supportedTypes fixed:self->_fixedTypes variable:self->_variableTypes];
        } error:^(NSError * _Nullable error) {
            @strongify(self);
            [self getInfo];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Add Fail\n%@",error.description]];
        }];
}
@end
