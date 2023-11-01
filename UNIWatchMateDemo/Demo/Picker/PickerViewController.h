//
//  PickerViewController.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, USWatchPickerDataType) {
    USWatchPickerDataTypeSteps,
    USWatchPickerDataTypeCalories,
    USWatchPickerDataTypeDistance,
    USWatchPickerDataTypeHeight,
    USWatchPickerDataTypeWeight,
    USWatchPickerDataTypeBirthday,
    USWatchPickerDataTypeMenstrualLength,
    USWatchPickerDataTypeMenstrualCycleLength,
    USWatchPickerDataTypeMenstrualStartReminder,
    USWatchPickerDataTypeMenstrualReminderTime,
    USWatchPickerDataTypeLanguage,
    USWatchPickerDataTypeCustomer,
    USWatchPickerDataTypeActivityDuration
    
};

@interface PickerViewController : UIViewController
- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height type:(USWatchPickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock;
- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height data:(NSArray *)data type:(USWatchPickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock;
- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height data:(NSArray *)data type:(USWatchPickerDataType)type tip:(NSString *)tip unit:(NSString *)unit doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock;
@end

NS_ASSUME_NONNULL_END
