//
//  DatePickerViewController.h
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/9/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, DatePickerDataType) {
    DatePickerDataTypeMostRecentMenstruation,
    DatePickerDataTypeBirthday,
    DatePickerDataTypeCustom
};

@interface DatePickerViewController : UIViewController
@property (nonatomic, strong) UIDatePicker *datePicker;
- (instancetype)initWithValue:(NSString *)value height:(CGFloat)height type:(DatePickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock;
- (instancetype)initWithValue:(NSString *)value title:(NSString *)title height:(CGFloat)height type:(DatePickerDataType)type doneBlock:(void (^)(NSString *))doneBlock cancelBlock:(void (^)(void))cancelBlock;
@end

NS_ASSUME_NONNULL_END
