//
//  BayMaxWeakProxy.h
//  zgzf
//
//  Created by zhugefang on 2018/8/11.
//  Copyright © 2018年 zgzf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BayMaxWeakProxy : NSObject
@property (nullable, nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
