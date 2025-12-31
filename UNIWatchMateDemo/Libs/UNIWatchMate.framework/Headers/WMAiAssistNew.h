//
//  WMSettingsWakeupWord.h
//  UNIWatchMate
//
//  Created by abel on 2025/6/19.
//


#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMAiAssistNew : NSObject<WMSupportProtocol>
///设备打开关闭 语音唤醒（Voice wake-up for device on and off）
///open :0：关闭；1：打开
///result:    0 : 成功1：失败2：设备正忙
- (RACSignal<NSNumber *> *)setVoiceWakeupOpen:(NSInteger)open;

- (RACSignal<NSNumber *> *)getVoiceWakeupOpen;

- (RACSignal<NSNumber *> *)letDeviceTakePhotoInChat;

- (RACSignal<NSNumber *> *)appStopRecord;
- (RACSignal<NSNumber *> *)appStopAiChat;

- (RACSignal<NSNumber *> *)appBeginPlayTts;

- (RACSignal<NSNumber *> *)appStopPlayTts;

- (RACSignal<NSNumber *> *)appSendAiIntent2Device:(Byte)intent;

- (RACSignal<NSNumber *> *)letDeviceSendAudioWhenFHP;

@end

NS_ASSUME_NONNULL_END
