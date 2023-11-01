//
//  WMPersonalInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 性别
typedef NS_ENUM(NSInteger, Gender) {
    /// 男性
    GenderMale,
    /// 女性
    GenderFemale,
    /// 其他
    GenderOther
};

@interface WMPersonalInfoModel : NSObject

/// 身高（0，表示不设置）
@property (nonatomic, assign) NSInteger height;
/// 体重（0，表示不设置）
@property (nonatomic, assign) NSInteger weight;
/// 性别（none，表示不设置）
@property (nonatomic, assign) Gender gender;
/// 生日（nil，表示不设置）
@property (nonatomic, strong) NSDate * birthDate;

@end

NS_ASSUME_NONNULL_END
