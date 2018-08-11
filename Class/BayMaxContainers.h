//
//  BayMaxContainers.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/14.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

//针对NSArray/NSMutableArray/NSDictionary/NSMutableDictionary/NSString/NSMutableString进行崩溃保护
/*
 ===============================
 //insertNil
 NSArray->Methods On Protection:
 1、@[nil]
 2、arrayWithObjects:count:
 3、objectAtIndex:
 
 ===============================

 NSMutableArray->Methods On Protection:
 0、arrayWithObjects:nil
 1、objectAtIndex:
 2、removeObjectAtIndex:
 3、removeObjectsInRange:
 5、insertObject:atIndex:
 6、insertObjects:atIndexes:
 7、addObject:nil
 8、replaceObjectAtIndex:withObject:
 9、replaceObjectsAtIndexes:withObjects:
 10、replaceObjectsInRange:withObjectsFromArray:

 ===============================
NSDictionary->Methods On Protection:
 1 @{nil:nil}
 2、dictionaryWithObject:forKey：
 3、dictionaryWithObjects:forKeys:
 4、dictionaryWithObjects:forKeys:count:
 
 ===============================
NSMutableDictionary->Methods On Protection:
 1、setObject:forKey:
 2、removeObjectForKey:
  ===============================
NSString->Methods On Protection:
 1、characterAtIndex：
 2、substringFromIndex:
 3、substringToIndex:
 4、substringWithRange:
 
 ===============================
NSMutableString->Methods On Protection:
 2、insertString:atIndex:
 3、deleteCharactersInRange:
 */

#import <Foundation/Foundation.h>

@class BayMaxCatchError;
@interface BayMaxContainers : NSObject
/**
 swizzle容器类方法

 @param errorHandler 错误回调
 */
+ (void)BMPExchangeContainersMethodsWithCatchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler;

@end
