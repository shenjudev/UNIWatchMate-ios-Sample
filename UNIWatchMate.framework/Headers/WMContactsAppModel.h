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

/// 联系人列表
@property (nonatomic, strong) RACSignal<NSArray<WMContactModel*> *> *contactList;
@property (nonatomic, strong, readonly) NSArray<WMContactModel*> *contactListValue;
/// 紧急联系人
@property (nonatomic, strong) RACSignal<WMContactModel *> *emergencyContact;
@property (nonatomic, strong, readonly) WMContactModel *emergencyContactValue;
/// 是否启动紧急联系人（BOOL）
@property (nonatomic, strong) RACSignal<NSNumber *> *emergencyContactEnable;
@property (nonatomic, assign, readonly) BOOL emergencyContactEnableValue;

/// 主动获取联系人列表
- (RACSignal<NSArray<WMContactModel*> *> *)wm_getContactList;

/// 同步联系人列表到设备
/// - Parameter contact: 联系人列表
- (RACSignal<NSArray<WMContactModel*> *> *)syncContactList:(NSArray<WMContactModel*> *)list;

/// 修改紧急联系人，nil为删除紧急联系人
/// - Parameter contact: contact
- (RACSignal<WMContactModel *> *)updateEmergencyContact:(WMContactModel *)contact;

/// 设置是否启用紧急联系人
/// - Parameter enable: YES 启用
- (RACSignal<NSNumber *> *)updateEmergencyContactEnable:(BOOL)enable;

/// 主动获取是否启用紧急联系人
- (RACSignal<NSNumber *> *)wm_getEmergencyContactEnable;

@end

NS_ASSUME_NONNULL_END
