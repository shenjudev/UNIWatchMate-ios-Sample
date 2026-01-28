//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <UNIWatchMate/UNIWatchMate.h>
#import "WatchManager.h"
//#import <UNIWatchMateDemo-swift.h>
//#import "RACSignal+FlatMapLatest.h"
#import <SJWatchLib/SJWatchLib.h>
// OTA SDK 专用 BtUtils
// 注意：必须先导入 UNIOTACLFSR.h，因为 UNIOTABtUtils.mm 依赖它
#import "OtaSdk/Lib/UNIOTACLFSR.h"
#import "OtaSdk/Lib/UNIOTABtUtils.h"
