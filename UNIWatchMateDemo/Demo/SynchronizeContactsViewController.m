//
//  SynchronizeContactsViewController.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/24.
//

#import "SynchronizeContactsViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface SynchronizeContactsTableViewFooter : UIView

@property (nonatomic, strong) UIButton *selectContacts;

@property (nonatomic, strong) UIButton *syncBtn;


- (instancetype)initWithFrame:(CGRect)frame;

@end
@implementation SynchronizeContactsTableViewFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 创建按钮1
        _selectContacts = [UIButton buttonWithType:UIButtonTypeSystem];
        self.selectContacts.translatesAutoresizingMaskIntoConstraints = NO;
        [self.selectContacts setBackgroundColor:[UIColor blueColor]];
        [self.selectContacts setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.selectContacts setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.selectContacts.layer.cornerRadius = 5;
        self.selectContacts.layer.masksToBounds = YES;
        [self addSubview:self.selectContacts];

        // 创建按钮2
        _syncBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.syncBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.syncBtn setBackgroundColor:[UIColor blueColor]];
        [self.syncBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.syncBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.syncBtn.layer.cornerRadius = 5;
        self.syncBtn.layer.masksToBounds = YES;
        [self addSubview:self.syncBtn];

        // 使用Auto Layout布局按钮1和按钮2
        [self.selectContacts.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16].active = YES;
        [self.selectContacts.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
        [self.selectContacts.topAnchor constraintEqualToAnchor:self.topAnchor constant:16].active = YES;
        [self.selectContacts.heightAnchor constraintEqualToConstant:44].active = YES;

        [self.syncBtn.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16].active = YES;
        [self.syncBtn.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16].active = YES;
        [self.syncBtn.topAnchor constraintEqualToAnchor:self.selectContacts.bottomAnchor constant:60].active = YES;
        [self.syncBtn.heightAnchor constraintEqualToConstant:44].active = YES;


    }
    return self;
}

@end


@interface SynchronizeContactsViewController ()<UITableViewDataSource, UITableViewDelegate,CNContactPickerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<CNContact *> *contacts; // 存储联系人的数组
@property (nonatomic, strong) UIView *tableViewFooter;
@property (nonatomic, strong) SynchronizeContactsTableViewFooter *tableViewFooterView;
@property (nonatomic, strong) NSMutableArray *currentsValue; // 用于保存最新的值

@end

@implementation SynchronizeContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Synchronize contacts";
    self.view.backgroundColor = [UIColor whiteColor];


    self.tableView.tableFooterView = self.tableViewFooter;

    _currentsValue = [NSMutableArray new];

    [self syncContacts];


}
-(void)getContactsFromDevice{
    @weakify(self)
    [[WatchManager sharedInstance].currentValue.apps.contactsApp.wm_getContactList subscribeNext:^(NSArray<WMContactModel *> * _Nullable x) {
        @strongify(self)
        [self showDeviceContacts:x];
    } error:^(NSError * _Nullable error) {

    }];
}

-(void)showDeviceContacts:(NSArray *)contacts{

    _currentsValue = [NSMutableArray arrayWithArray:contacts];
    [self.tableView reloadData];

}
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
    }
    return  _tableView;
}

-(UIView *)tableViewFooter{
    if(_tableViewFooter == nil){
        _tableViewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        [_tableViewFooter addSubview:self.tableViewFooterView];
    }
    return _tableViewFooter;
}


- (SynchronizeContactsTableViewFooter *)tableViewFooterView
{
    if (_tableViewFooterView == nil) {
        _tableViewFooterView = [[SynchronizeContactsTableViewFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        [_tableViewFooterView.selectContacts addTarget:self action:@selector(showContactPicker:) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewFooterView.selectContacts setTitle:@"Select contacts" forState:UIControlStateNormal];
        [_tableViewFooterView.syncBtn addTarget:self action:@selector(syncContacts) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewFooterView.syncBtn setTitle:@"sync contacts from watch" forState:UIControlStateNormal];
    }
    return  _tableViewFooterView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currentsValue count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    }
    WMContactModel *contact = self.currentsValue[indexPath.row];
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.number;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    // 创建删除按钮
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:@"delete" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.layer.masksToBounds = YES;
    deleteButton.layer.cornerRadius = 5;
    [deleteButton setBackgroundColor:[UIColor redColor]];
    deleteButton.tag = indexPath.row + 100;
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];


    // 创建删除按钮
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.layer.masksToBounds = YES;
    editButton.layer.cornerRadius = 5;
    [editButton setBackgroundColor:[UIColor redColor]];
    editButton.tag = indexPath.row + 1000;
    [editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];


    // 布局开关和删除按钮
    CGFloat buttonWidth = 60; // 按钮宽度
    CGFloat cellWidth = CGRectGetWidth(self.view.frame);

    // 计算删除按钮的位置
    CGRect deleteButtonFrame = CGRectMake(cellWidth - buttonWidth - 10, 25, buttonWidth, 30);
    deleteButton.frame = deleteButtonFrame;

    // 计算开关的位置
    CGRect editFrame = CGRectMake(cellWidth - 2 * buttonWidth - 10 - 10, 25, buttonWidth, 30);
    editButton.frame = editFrame;

    // 将开关和删除按钮添加到单元格
    [cell.contentView addSubview:editButton];
    [cell.contentView addSubview:deleteButton];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    WMContactModel *contact = self.currentsValue[indexPath.row];

}

- (void)syncContacts
{
    _contacts = [NSArray new];
    [self.tableView reloadData];
    @weakify(self)
    [[WatchManager sharedInstance].currentValue.apps.contactsApp.wm_getContactList subscribeNext:^(NSArray<WMContactModel *> * _Nullable x) {
        @strongify(self)
        [self showDeviceContacts:x];
    } error:^(NSError * _Nullable error) {

    }];
}

- (void)syncContactsToDevice:(NSArray *)contacts
{

    NSMutableArray *newContacts = [NSMutableArray new];
    for (CNContact *c in contacts) {
        WMContactModel *model = [WMContactModel new];
        model.name = [NSString stringWithFormat:@"%@ %@",c.givenName,c.familyName];
        model.number = [self firstPhoneNumber:c];
        [newContacts addObject:model];
    }
    [SVProgressHUD showWithStatus:nil];
    @weakify(self)
    _currentsValue = @[];
    [self.tableView reloadData];
    [[[WatchManager sharedInstance].currentValue.apps.contactsApp syncContactList:newContacts]  subscribeNext:^(NSArray<WMContactModel *> * _Nullable x) {
        @strongify(self)
        [SVProgressHUD dismiss];
        [self showDeviceContacts:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Set failed."];
    }];
}

- (void)deleteButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 100;
    // 处理删除按钮点击事件
    [self.currentsValue removeObjectAtIndex:indexRow];
    [SVProgressHUD showWithStatus:nil];
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.apps.contactsApp syncContactList:self.currentsValue] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDeviceContacts:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Deleta Fail\n%@",error.description]];
    }];
}
- (void)editButtonTapped:(UIButton *)sender {
    NSInteger indexRow = sender.tag - 1000;
    WMContactModel *model = self.currentsValue[indexRow];

    // 创建 UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit contact" message:nil preferredStyle:UIAlertControllerStyleAlert];

    // 添加文本框1（用于编辑名字）
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"name";
        textField.text = model.name;
    }];

    // 添加文本框2（用于编辑电话号码）
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"phone number";
        textField.keyboardType = UIKeyboardTypePhonePad; // 设置键盘类型为电话号码键盘
        textField.text = model.number;
    }];

    @weakify(self);
    // 添加保存按钮
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 在这里处理用户点击保存按钮后的逻辑
        @strongify(self);
        UITextField *nameTextField = alertController.textFields[0];
        UITextField *phoneNumberTextField = alertController.textFields[1];

        NSString *editName = nameTextField.text;
        NSString *phoneNumber = phoneNumberTextField.text;
        [self editContact:indexRow name:editName number:phoneNumber];
    }];

    // 添加取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    // 将按钮添加到 UIAlertController
    [alertController addAction:saveAction];
    [alertController addAction:cancelAction];

    // 弹出 UIAlertController
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)editContact:(NSInteger )index name:(NSString *)name number:(NSString *)number{
    [SVProgressHUD showWithStatus:nil];
    WMContactModel *model = self.currentsValue[index];
    model.name = name;
    model.number = number;
    [self.currentsValue replaceObjectAtIndex:index withObject:model];
    @weakify(self);
    [[[WatchManager sharedInstance].currentValue.apps.contactsApp syncContactList:self.currentsValue] subscribeNext:^(NSArray<WMAlarmModel *> * _Nullable x) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [self showDeviceContacts:x];
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Edit Fail\n%@",error.description]];
    }];
}


- (void)showContactPicker:(id)sender {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    contactPicker.predicateForSelectionOfContact = [NSPredicate predicateWithValue:YES];
    contactPicker.predicateForSelectionOfProperty = [NSPredicate predicateWithValue:YES];
    contactPicker.displayedPropertyKeys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey];

    [self presentViewController:contactPicker animated:YES completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {

    NSInteger maxCount = MIN([contacts count], 100);
    NSArray *selected10Contacts = [contacts subarrayWithRange:NSMakeRange(0, maxCount)];

    if ([contacts count] > 100){
        [SVProgressHUD showErrorWithStatus:@"Max 100 contacts"];
    }
    if ([selected10Contacts count] > 0){
        [self syncContactsToDevice:selected10Contacts];
    }

}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    // 用户取消了联系人选择
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)firstPhoneNumber:(CNContact*)contact{
    NSArray<CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
    for (CNLabeledValue<CNPhoneNumber *> *phoneNumber in phoneNumbers) {
        // 获取电话号码标签（例如：工作、家庭等）
        NSString *label = [CNLabeledValue localizedStringForLabel:phoneNumber.label];

        // 获取电话号码字符串
        CNPhoneNumber *number = phoneNumber.value;
        NSString *phoneNumberString = [number stringValue];

        return  phoneNumberString;
    }
    return @"";
}



@end
