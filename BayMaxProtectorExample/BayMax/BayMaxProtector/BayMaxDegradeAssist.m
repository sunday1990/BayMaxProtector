//
//  BayMaxDegradeAssist.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxDegradeAssist.h"

NSString *const BMPAssistKey_VC = @"BMP_ViewController";

NSString *const BMPAssistKey_Params = @"BMP_Params";

NSString *const BMPAssistKey_Url = @"BMP_Url";

@implementation BayMaxDegradeAssist
static  BayMaxDegradeAssist*_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)Assist{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _relations = [NSMutableArray array];
    }
    return self;
}

- (void)reloadRelations{
    [self.relations removeAllObjects];
    if (self.degradeDelegate) {
        NSInteger relations = [self.degradeDelegate numberOfRelations];
        for (int i = 0; i<relations; i++) {
            NSString *vcName = [self.degradeDelegate nameOfViewControllerAtIndex:i];
            NSString *vcUrl = [self.degradeDelegate urlOfViewControllerAtIndex:i];
            NSArray *params = [self.degradeDelegate correspondencesBetweenH5AndIOSParametersAtIndex:i];
            NSDictionary *item = @{
                                   BMPAssistKey_VC:vcName == nil?@"":vcName,
                                   BMPAssistKey_Url:vcUrl == nil?@"":vcUrl,
                                   BMPAssistKey_Params:params == nil?@"":params
                                   };
            [self.relations addObject:item];
        }
        NSLog(@"降级配置更新成功");
    }
}

- (NSDictionary *)relationForViewController:(Class)cls{
    __block NSDictionary *relation;
    NSString *clsName = NSStringFromClass(cls);
    [self.relations enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:BMPAssistKey_VC] isEqualToString:clsName]) {
            relation = obj;
            *stop = YES;
        }
    }];
    return relation;
}

- (NSString *)getCompleteUrlForViewController:(id)vc{
    NSMutableString *appendString = [NSMutableString string];
    NSDictionary *relation = [self relationForViewController:[vc class]];
    NSString *url = relation[BMPAssistKey_Url];
    NSArray <NSDictionary *>*params = relation[BMPAssistKey_Params];
    [appendString appendString:url];
    [appendString appendString:@"?"];
    [params enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *h5Param = obj.allKeys[0];
        NSString *iosParam = obj[h5Param];
        //keypath需要做判断
        NSString *h5Value = [vc valueForKeyPath:iosParam];
        if (h5Value) {
            [appendString appendString:h5Param];
            [appendString appendString:@"="];
            [appendString appendString:h5Value];
            if (idx<params.count-1) {
                [appendString appendString:@"&"];
            }
        }
    }];
    return appendString;        
}

@end
