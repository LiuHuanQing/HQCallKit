//
//  ViewController.m
//  HQCallKitDemo
//
//  Created by 刘欢庆 on 2018/3/13.
//  Copyright © 2018年 刘欢庆. All rights reserved.
//

#import "ViewController.h"
#import "HQCallManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)setupAction:(id)sender
{
    [HQCallManager setupWithAppName:@"HQCall"];
}

- (IBAction)incall:(id)sender
{
    [HQCallManager incomingCall:@"123" displayName:@"哈哈" completion:^(NSError * _Nullable error) {
        NSLog(@"incomingCall %@",error);
    }];
}

- (IBAction)outcall:(id)sender
{
    [HQCallManager outgoingCall:@"13026118084" completion:^(NSError * _Nullable error) {
        NSLog(@"outgoingCall %@",error);
    }];
}
- (IBAction)connected:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HQCallManager connected:^(NSError * _Nullable error) {
            
        }];
    });
}
- (IBAction)dtmf1:(id)sender
{
    [HQCallManager DTMF:@"1" completion:^(NSError * _Nullable error) {
        
    }];
}

- (IBAction)dtmf2:(id)sender
{
    [HQCallManager DTMF:@"2" completion:^(NSError * _Nullable error) {
        
    }];
}

- (IBAction)dtmf3:(id)sender
{
    [HQCallManager DTMF:@"3" completion:^(NSError * _Nullable error) {
        
    }];
}
- (IBAction)mute:(id)sender
{
    [HQCallManager mute:YES completion:^(NSError * _Nullable error) {
        
    }];
}

@end
