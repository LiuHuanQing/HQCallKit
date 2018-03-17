//
//  HQCallManager.h
//  HQCallKitDemo
//
//  Created by 刘欢庆 on 2018/3/13.
//  Copyright © 2018年 刘欢庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HQCallKitManagerCompletion)(NSError * _Nullable error);
typedef void(^HQCallKitManagerHandler)(void);
typedef void(^HQCallKitManagerSwitchHandler)(BOOL on);
typedef void(^HQCallKitManagerStringHandler)(NSString *string);

@interface HQCallManager : NSObject

//配置info
+ (void)setupWithAppName:(NSString *)appName;
+ (void)setupWithConfig:(CXProviderConfiguration *)config;

//呼入
+ (void)incomingCall:(NSString *)number displayName:(NSString *)displayName completion:(HQCallKitManagerCompletion)completion;

//呼出
+ (void)outgoingCall:(NSString *)number completion:(HQCallKitManagerCompletion)completion;

//静音
+ (void)mute:(BOOL)mute completion:(HQCallKitManagerCompletion)completion;

//挂起
+ (void)hold:(BOOL)hold completion:(HQCallKitManagerCompletion)completion;

//扩音
+ (void)speaker:(BOOL)speaker completion:(HQCallKitManagerCompletion)completion;

//dtmf
+ (void)DTMF:(NSString *)dtmf completion:(HQCallKitManagerCompletion)completion;

//挂断
+ (void)endCall:(HQCallKitManagerCompletion)completion;

//呼出:连接中
+ (void)outgoingConnecting:(HQCallKitManagerCompletion)completion;

//已连接
+ (void)connected:(HQCallKitManagerCompletion)completion;

//响应事件:挂断
+ (void)onEndCall:(HQCallKitManagerHandler)handler;

//响应事件:呼出
+ (void)onStartOutgoingCall:(HQCallKitManagerHandler)handler;

//响应事件:接听
+ (void)onAnswer:(HQCallKitManagerHandler)handler;

//响应事件:静音
+ (void)onMute:(HQCallKitManagerSwitchHandler)handler;

//响应事件:挂起
+ (void)onHold:(HQCallKitManagerSwitchHandler)handler;

//响应事件:DTMF
+ (void)onDTMF:(HQCallKitManagerStringHandler)handler;
@end
NS_ASSUME_NONNULL_END
