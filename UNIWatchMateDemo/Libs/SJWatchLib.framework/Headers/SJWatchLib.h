//
//  SJWatchLib.h
//  SJWatchLib
//
//  Created by t_t on 2023/9/19.
//

#import <Foundation/Foundation.h>

//! Project version number for SJWatchLib.
FOUNDATION_EXPORT double SJWatchLibVersionNumber;

//! Project version string for SJWatchLib.
FOUNDATION_EXPORT const unsigned char SJWatchLibVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SJWatchLib/PublicHeader.h>


#import <UNIWatchMate/UNIWatchMate.h>
#import <SJWatchLib/BtUtils.h>
#import <SJWatchLib/MTWatchVideoH264.h>
#import <SJWatchLib/NavigationWatchVideoH264.h>
#import <SJWatchLib/DialThumbnailAdapter.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <SJWatchLib/LSFR.h>
// opus 框架导入 - 使用框架路径导入，确保能找到头文件
#import <opus-ios/opus.h>
#import <opus-ios/OpusDecoder.h>
