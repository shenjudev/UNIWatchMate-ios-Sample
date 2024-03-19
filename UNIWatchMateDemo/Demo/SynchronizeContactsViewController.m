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
        // Create button 1
        _selectContacts = [UIButton buttonWithType:UIButtonTypeSystem];
        self.selectContacts.translatesAutoresizingMaskIntoConstraints = NO;
        [self.selectContacts setBackgroundColor:[UIColor blueColor]];
        [self.selectContacts setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.selectContacts setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.selectContacts.layer.cornerRadius = 5;
        self.selectContacts.layer.masksToBounds = YES;
        [self addSubview:self.selectContacts];

        // Create button 2
        _syncBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.syncBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.syncBtn setBackgroundColor:[UIColor blueColor]];
        [self.syncBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.syncBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.syncBtn.layer.cornerRadius = 5;
        self.syncBtn.layer.masksToBounds = YES;
        [self addSubview:self.syncBtn];

        // Use Auto Layout to lay out buttons 1 and 2
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
@property (nonatomic, strong) NSArray<CNContact *> *contacts; // Store an array of contacts
@property (nonatomic, strong) UIView *tableViewFooter;
@property (nonatomic, strong) SynchronizeContactsTableViewFooter *tableViewFooterView;
@property (nonatomic, strong) NSMutableArray *currentsValue; // Used to save the latest values

@end

@implementation SynchronizeContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"Synchronize contacts", nil);
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
        [_tableViewFooterView.selectContacts setTitle:NSLocalizedString(@"Select contacts", nil) forState:UIControlStateNormal];
        [_tableViewFooterView.syncBtn addTarget:self action:@selector(syncContacts) forControlEvents:UIControlEventTouchUpInside];
        [_tableViewFooterView.syncBtn setTitle:NSLocalizedString(@"sync contacts from watch", nil) forState:UIControlStateNormal];
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

    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.layer.masksToBounds = YES;
    deleteButton.layer.cornerRadius = 5;
    [deleteButton setBackgroundColor:[UIColor redColor]];
    deleteButton.tag = indexPath.row + 100;
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];


    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.layer.masksToBounds = YES;
    editButton.layer.cornerRadius = 5;
    [editButton setBackgroundColor:[UIColor redColor]];
    editButton.tag = indexPath.row + 1000;
    [editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];


    
    CGFloat buttonWidth = 60;
    CGFloat cellWidth = CGRectGetWidth(self.view.frame);

    
    CGRect deleteButtonFrame = CGRectMake(cellWidth - buttonWidth - 10, 25, buttonWidth, 30);
    deleteButton.frame = deleteButtonFrame;

    
    CGRect editFrame = CGRectMake(cellWidth - 2 * buttonWidth - 10 - 10, 25, buttonWidth, 30);
    editButton.frame = editFrame;

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

    // Create a UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Edit contact", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];

    // Add text box 1 (for editing names)
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"name";
        textField.text = model.name;
    }];

    // Add text box 2 (for editing phone numbers)
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"phone number";
        textField.keyboardType = UIKeyboardTypePhonePad; // Set the keyboard type to phone number keyboard
        textField.text = model.number;
    }];

    @weakify(self);
    // Add save button
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // The logic after the user clicks the Save button is processed here
        @strongify(self);
        UITextField *nameTextField = alertController.textFields[0];
        UITextField *phoneNumberTextField = alertController.textFields[1];

        NSString *editName = nameTextField.text;
        NSString *phoneNumber = phoneNumberTextField.text;
        [self editContact:indexRow name:editName number:phoneNumber];
    }];

    // Add cancel button
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];

    // Add the button to UIAlertController
    [alertController addAction:saveAction];
    [alertController addAction:cancelAction];

    // Pop up UIAlertController
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
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Max 100 contacts", nil)];
    }
    if ([selected10Contacts count] > 0){
        [self syncContactsToDevice:selected10Contacts];
    }

}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    // The user deselected the contact
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)firstPhoneNumber:(CNContact*)contact{
    NSArray<CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
    for (CNLabeledValue<CNPhoneNumber *> *phoneNumber in phoneNumbers) {
        // Get phone number labels (e.g., work, home, etc.)
        NSString *label = [CNLabeledValue localizedStringForLabel:phoneNumber.label];

        // Gets a phone number string
        CNPhoneNumber *number = phoneNumber.value;
        NSString *phoneNumberString = [number stringValue];

        return  phoneNumberString;
    }
    return @"";
}



@end
