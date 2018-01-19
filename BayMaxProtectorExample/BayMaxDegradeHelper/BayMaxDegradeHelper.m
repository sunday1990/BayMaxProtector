//
//  BayMaxDegradeHelper.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxDegradeHelper.h"

NSString *const BMPHelperKey_VC = @"BMP_ViewController";

NSString *const BMPHelperKey_Params = @"BMP_Params";

NSString *const BMPHelperKey_Url = @"BMP_Url";

@implementation BayMaxDegradeHelper
static  BayMaxDegradeHelper*_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)sharedBayMaxDegradeHelper{
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
            NSArray *params = [self.degradeDelegate paramsBetweenH5andIosAtIndex:i];
            NSDictionary *item = @{
                                   BMPHelperKey_VC:vcName == nil?@"":vcName,
                                   BMPHelperKey_Url:vcUrl == nil?@"":vcUrl,
                                   BMPHelperKey_Params:params == nil?@"":params
                                   };
            [self.relations addObject:item];
        }
        NSLog(@"降级配置成功");
    }
}

- (NSDictionary *)relationForViewController:(Class)cls{
    __block NSDictionary *relation;
    NSString *clsName = NSStringFromClass(cls);
    [self.relations enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:BMPHelperKey_VC] isEqualToString:clsName]) {
            relation = obj;
            *stop = YES;
        }
    }];
    return relation;
}


@end
