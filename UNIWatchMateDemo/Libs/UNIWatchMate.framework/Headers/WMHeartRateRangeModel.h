//
//  WMHeartRateRangeModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateRangeModel : NSObject

///热身区间
@property (nonatomic, assign) NSInteger warmUp;
///减脂区间
@property (nonatomic, assign) NSInteger fatBurn;
///耐力区间
@property (nonatomic, assign) NSInteger endurance;
///无氧区间
@property (nonatomic, assign) NSInteger anaerobic;
///极限区间
@property (nonatomic, assign) NSInteger peak;

@end

NS_ASSUME_NONNULL_END
