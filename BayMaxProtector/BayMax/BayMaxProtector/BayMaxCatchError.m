//
//  BayMaxCatchError.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/18.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxCatchError.h"

NSString *const BMPErrorCallStackSymbols = @"ErrorCallStackSymbols";

NSString *const BMPErrorUnrecognizedSel_Receiver = @"ErrorObject";
NSString *const BMPErrorUnrecognizedSel_Func = @"ErrorSelector";
NSString *const BMPErrorUnrecognizedSel_VC = @"ErrorViewController";
NSString *const BMPErrorUnrecognizedSel_Reason = @"ErrorReason";

NSString *const BMPErrorKVO_Observer = @"ErrorObserver";
NSString *const BMPErrorKVO_Keypath = @"ErrorKeypath";
NSString *const BMPErrorKVO_Target = @"ErrorTarget";
NSString *const BMPErrorKVO_Reason = @"ErrorReason";

NSString *const BMPErrorTimer_Target = @"ErrorTarget";
NSString *const BMPErrorTimer_Reason = @"ErrorReason";

@implementation BayMaxCatchError
+ (instancetype)BMPErrorWithType:(BayMaxErrorType)errorType infos:(NSDictionary *)errorInfos{
    return [[self alloc]initWithType:errorType infos:errorInfos];
}

- (instancetype)initWithType:(BayMaxErrorType)errorType infos:(NSDictionary *)errorInfos{
    if (self = [super init]) {
        self.errorType = errorType;
        self.errorInfos = errorInfos;
    }
    return self;
}

@end
