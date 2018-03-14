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
NSString *const BMPErrorKVO_Target = @"ErrorKeypathFrom";
NSString *const BMPErrorKVO_Reason = @"ErrorReason";

NSString *const BMPErrorTimer_Target = @"ErrorTarget";
NSString *const BMPErrorTimer_Reason = @"ErrorReason";


NSString *const BMPErrorArray_Beyond = @"ArrayBeyondBounds";
NSString *const BMPErrorArray_NilObject = @"ArrayInsertNil";

NSString *const BMPErrorDictionary_NilKey = @"DictionaryNilKey";
NSString *const BMPErrorDictionary_UndefinedKey = @"DictionaryUndefinedKey";

NSString *const BMPErrorString_Beyond = @"StringOutOfBounds";

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

- (NSString *)errorName{
    if (!_errorName) {
        _errorName = @"BayMaxProtector拦截到的错误";
    }
    return _errorName;
}

- (NSArray *)errorCallStackSymbols{
    if (!_errorCallStackSymbols) {
        if ([self.errorInfos.allKeys containsObject:BMPErrorCallStackSymbols]) {
            _errorCallStackSymbols = [self.errorInfos objectForKey:BMPErrorCallStackSymbols];
        }else{
            _errorCallStackSymbols = @[];
        }
    }
    return _errorCallStackSymbols;
}

@end
