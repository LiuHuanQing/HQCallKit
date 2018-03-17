//
//  HQCallManager.m
//  HQCallKitDemo
//
//  Created by 刘欢庆 on 2018/3/13.
//  Copyright © 2018年 刘欢庆. All rights reserved.
//

#import "HQCallManager.h"
#import <AVFoundation/AVFAudio.h>
#define Instance [HQCallManager sharedInstance]

NSString * const HQCallManagerOnStartOutgoingCall = @"HQCallManagerOnStartOutgoingCall";
NSString * const HQCallManagerOnEndCall = @"HQCallManagerOnEndCall";
NSString * const HQCallManagerOnAnswer = @"HQCallManagerOnAnswer";
NSString * const HQCallManagerOnMute = @"HQCallManagerOnMute";
NSString * const HQCallManagerOnHold = @"HQCallManagerOnHold";
NSString * const HQCallManagerOnDTMF = @"HQCallManagerOnDTMF";


@interface HQCallManager()<CXProviderDelegate>

//目前只支持一个通话
@property (nonatomic, strong) NSUUID *callUUID;
@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) NSMutableDictionary *handlers;
@property (nonatomic, strong) CXAnswerCallAction *answerCallAction;
@end

@implementation HQCallManager
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _handlers = [NSMutableDictionary dictionary];
    }
    return self;
}
+ (instancetype)sharedInstance
{
    static HQCallManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super allocWithZone:nil] init];
    });
    return instance;
}

+ (void)setupWithAppName:(NSString *)appName
{
    CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    configuration.maximumCallGroups = 1;
    configuration.maximumCallsPerCallGroup = 1;
    configuration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
    configuration.supportsVideo = NO;
    
    [self setupWithConfig:configuration];
}

+ (void)setupWithConfig:(CXProviderConfiguration *)config
{
    CXProvider *provider = [[CXProvider alloc] initWithConfiguration:config];
    [provider setDelegate:Instance queue:dispatch_get_main_queue()];
    Instance.provider = provider;
    Instance.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
}

//in: performAnswerCallAction -> didActivateAudioSession
+ (void)incomingCall:(NSString *)number displayName:(NSString *)displayName completion:(HQCallKitManagerCompletion)completion
{
    NSUUID *callUUID = [NSUUID UUID];
    
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:number];
    callUpdate.remoteHandle = handle;
    callUpdate.localizedCallerName = displayName;
    Instance.callUUID = callUUID;
    [Instance.provider reportNewIncomingCallWithUUID:callUUID update:callUpdate completion:completion];
}

//out: performStartCallAction -> didActivateAudioSession
+ (void)outgoingCall:(NSString *)number completion:(HQCallKitManagerCompletion)completion
{
    NSUUID *callUUID = [NSUUID UUID];
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:number];
    
    CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:callUUID handle:handle];
    action.contactIdentifier = [callUUID UUIDString];
    
    Instance.callUUID = callUUID;
    [Instance.callController requestTransaction:[[CXTransaction alloc] initWithAction:action] completion:completion];
}

//静音
+ (void)mute:(BOOL)mute completion:(HQCallKitManagerCompletion)completion
{
    CXSetMutedCallAction *action = [[CXSetMutedCallAction alloc] initWithCallUUID:Instance.callUUID muted:mute];
    [Instance.callController requestTransaction:[[CXTransaction alloc] initWithAction:action] completion:completion];
}

//挂起
+ (void)hold:(BOOL)hold completion:(HQCallKitManagerCompletion)completion
{
    CXSetHeldCallAction *action = [[CXSetHeldCallAction alloc] initWithCallUUID:Instance.callUUID onHold:hold];
    [Instance.callController requestTransaction:[[CXTransaction alloc] initWithAction:action] completion:completion];
}

//扩音
+ (void)speaker:(BOOL)speaker completion:(HQCallKitManagerCompletion)completion
{
//    AVAudioSession.sharedInstance.currentRoute.outputs;
}

//dtmf
+ (void)DTMF:(NSString *)dtmf completion:(HQCallKitManagerCompletion)completion
{
    CXPlayDTMFCallAction *action = [[CXPlayDTMFCallAction alloc]initWithCallUUID:Instance.callUUID digits:dtmf type:CXPlayDTMFCallActionTypeSingleTone];
    [Instance.callController requestTransaction:[[CXTransaction alloc] initWithAction:action] completion:completion];
}

//挂断
+ (void)endCall:(HQCallKitManagerCompletion)completion
{
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:Instance.callUUID];
    [Instance.callController requestTransaction:[[CXTransaction alloc] initWithAction:action] completion:completion];
}

//呼出:连接中
+ (void)outgoingConnecting:(HQCallKitManagerCompletion)completion
{
    [Instance.provider reportOutgoingCallWithUUID:Instance.callUUID startedConnectingAtDate:[NSDate date]];
}

//已连接
+ (void)connected:(HQCallKitManagerCompletion)completion
{
    if(Instance.answerCallAction)
    {
        [Instance.answerCallAction fulfill];
        if(completion)completion(nil);
    }
    else
    {
        [Instance.provider reportOutgoingCallWithUUID:Instance.callUUID connectedAtDate:[NSDate date]];
    }
}

//响应事件:呼叫
+ (void)onStartOutgoingCall:(HQCallKitManagerHandler)handler
{
    if(handler)
    {
        Instance.handlers[HQCallManagerOnStartOutgoingCall] = handler;
    }
}

//响应事件:挂断
+ (void)onEndCall:(HQCallKitManagerHandler)handler
{
    if(handler)
    {
        Instance.handlers[HQCallManagerOnEndCall] = handler;
    }
}

//响应事件:接听
+ (void)onAnswer:(HQCallKitManagerHandler)handler
{
    if(handler)
    {
        Instance.handlers[HQCallManagerOnAnswer] = handler;
    }
}

//响应事件:静音
+ (void)onMute:(HQCallKitManagerSwitchHandler)handler
{
    if(handler)
    {
        Instance.handlers[HQCallManagerOnMute] = handler;
    }
}

//响应事件:挂起
+ (void)onHold:(HQCallKitManagerSwitchHandler)handler
{
    if(handler)
    {
        Instance.handlers[HQCallManagerOnHold] = handler;
    }
}

//响应事件:DTMF
+ (void)onDTMF:(HQCallKitManagerStringHandler)handler
{
    if(handler)
    {
        Instance.handlers[HQCallManagerOnDTMF] = handler;
    }
}

+ (void)callback:(NSString *)key
{
    if(!key) { return; }
    
    if(!Instance.handlers[key]) { return; }
    
    ((HQCallKitManagerHandler)Instance.handlers[key])();
}

+ (void)callback:(NSString *)key withOn:(BOOL)on
{
    if(!key) { return; }
    
    if(!Instance.handlers[key]) { return; }
    
    ((HQCallKitManagerSwitchHandler)Instance.handlers[key])(on);
}

#pragma mark - CXProviderDelegate
- (void)providerDidReset:(CXProvider *)provider
{
    _answerCallAction = nil;
}

- (void)provider:(CXProvider *)provider performStartCallAction:(nonnull CXStartCallAction *)action
{
    [HQCallManager callback:HQCallManagerOnStartOutgoingCall];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    _answerCallAction = action;
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    _answerCallAction = nil;
    [HQCallManager callback:HQCallManagerOnEndCall];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession
{
    if(_answerCallAction)
    {
        [HQCallManager callback:HQCallManagerOnAnswer];
    }
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(nonnull CXSetMutedCallAction *)action
{
    [HQCallManager callback:HQCallManagerOnAnswer withOn:action.isMuted];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(nonnull CXSetHeldCallAction *)action
{
    [HQCallManager callback:HQCallManagerOnAnswer withOn:action.isOnHold];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action
{
    if(!Instance.handlers[HQCallManagerOnDTMF]) { return; }
    
    ((HQCallKitManagerStringHandler)Instance.handlers[HQCallManagerOnDTMF])(action.digits);
    
    [action fulfill];
}
@end
