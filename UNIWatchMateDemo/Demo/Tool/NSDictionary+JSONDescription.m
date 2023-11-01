//
//  NSDictionary+JSONDescription.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/31.
//

#import "NSDictionary+JSONDescription.h"

@implementation NSDictionary (JSONDescription)
- (NSString *)jsonDescription {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];

    if (!jsonData) {
        NSLog(@"Failed to convert dictionary to JSON: %@", error);
        return nil;
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}
@end
