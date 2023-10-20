//
//  ViewController.h
//  UNIWatchMateDemo
//
//  Created by t_t on 2023/9/22.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define CHLog(fmt, ...) do { \
NSDate *date = [NSDate date]; \
NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; \
[formatter setDateFormat:@"HH:mm:ss.SSS"]; \
NSString *dateString = [formatter stringFromDate:date]; \
NSString *fullMessage = [NSString stringWithFormat:@"【%@】" fmt, dateString, ##__VA_ARGS__]; \
fprintf(stderr, "%s\n", [fullMessage UTF8String]); \
} while (0)

#else
#define CHLog(...)
#endif

@interface ViewController : UIViewController


@end

