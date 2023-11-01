//
//  WMContactsAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMContactModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMContactsAppModel : NSObject<WMSupportProtocol>

/// 设备端更新联系人列表
@property (nonatomic, strong) RACSignal<NSArray<WMContactModel*> *> *contactList;
/// 当前联系人列表（设备端、APP修改配置成功时更新数据）
@property (nonatomic, strong, readonly) NSArray<WMContactModel*> *contactListValue;
/// 设备端更新紧急联系人 （RAC 无法设置nil 类型，所以这里用数组。数组为空时表示没有紧急联系人）
@property (nonatomic, strong) RACSignal<NSArray<WMEmergencyContactModel *> *> *emergencyContact;
/// 当前紧急联系人（设备端、APP修改配置成功时更新数据）
@property (nonatomic, strong, readonly) WMEmergencyContactModel * _Nullable emergencyContactValue;

/// 获取联系人列表
- (RACSignal<NSArray<WMContactModel*> *> *)wm_getContactList;
/// 获取急联系人列表（RAC 无法设置nil 类型，所以这里用数组。数组为空时表示没有紧急联系人）
- (RACSignal<NSArray<WMEmergencyContactModel*> *> *)wm_emergencyContact;

/// 同步联系人列表到设备
/// - Parameter contact: 联系人列表
- (RACSignal<NSArray<WMContactModel*> *> *)syncContactList:(NSArray<WMContactModel*> *)list;

/// 同步紧急联系人，nil为删除紧急联系人 （RAC 无法设置nil 类型，所以这里用数组。数组为空时表示没有紧急联系人）
/// - Parameter contact: contact
- (RACSignal<NSArray<WMEmergencyContactModel *> *> *)syncEmergencyContact:(WMEmergencyContactModel * _Nullable)contact;

@end

NS_ASSUME_NONNULL_END
