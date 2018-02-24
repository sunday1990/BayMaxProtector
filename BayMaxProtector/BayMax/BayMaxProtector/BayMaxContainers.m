//
//  BayMaxContainers.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/14.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxContainers.h"
#import "BayMaxCFunctions.h"
#import "BayMaxCatchError.h"
#import "BayMaxDebugView.h"

BMPErrorHandler _Nullable _containerErrorHandler;

#define BMP_Array_ObjectAtIndex_ErrorHandler(ArrayType,ArrayMethod,Index)\
    NSString *errorInfo = [NSString stringWithFormat:@"'*** -[%@ %@]: index %ld beyond bounds [0 .. %ld]",ArrayType,ArrayMethod,Index,self.count];\
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];\
    BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeContainers infos:@{                                                                                             BMPErrorArray_Beyond:errorInfo,                                                                                             BMPErrorCallStackSymbols:callStackSymbolsArr                                                                                             }];\
    if (_containerErrorHandler) {\
        _containerErrorHandler(bmpError);\
    }\

@interface NSArray (BMPProtector)

@end

@implementation NSArray (BMPProtector)
// NSArray/__NSArrayI/__NSSingleObjectArrayI/__NSArray0
//objectsAtIndexes:
- (NSArray *)BMP_objectsAtIndexes:(NSIndexSet *)indexes{
    if (indexes.lastIndex >= self.count||indexes.firstIndex >= self.count) {
        if (indexes.firstIndex >= self.count) {
            BMP_Array_ObjectAtIndex_ErrorHandler(@"NSArray",NSStringFromSelector(_cmd),indexes.lastIndex);
            return nil;
        }else{
            NSIndexSet *indexesNew = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexes.firstIndex, self.count-indexes.firstIndex)];
            BMP_Array_ObjectAtIndex_ErrorHandler(@"NSArray",NSStringFromSelector(_cmd),indexes.lastIndex);
            return [self BMP_objectsAtIndexes:indexesNew];
        }
    }
    return [self BMP_objectsAtIndexes:indexes];
}

//objectAtIndex:
- (id)BMP__NSArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_ObjectAtIndex_ErrorHandler(@"__NSArrayI",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSArrayIObjectAtIndex:index];
}

- (id)BMP__NSSingleObjectArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_ObjectAtIndex_ErrorHandler(@"__NSSingleObject",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSSingleObjectArrayIObjectAtIndex:index];
}

- (id)BMP__NSArray0ObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_ObjectAtIndex_ErrorHandler(@"__NSArray0",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSArray0ObjectAtIndex:index];
}
@end

@interface NSMutableArray (BMPProtector)

@end

@implementation NSMutableArray (BMPProtector)
//objectAtIndex:
- (id)BMP_MArrayObjectAtIndex:(NSUInteger)index{
    return [self BMP_MArrayObjectAtIndex:index];
}

//setObject:atIndexedSubscript:
- (void)BMP_MArraySetObject:(id)obj atIndexedSubscript:(NSUInteger)idx{
    return [self BMP_MArraySetObject:obj atIndexedSubscript:idx];
}

//removeObjectAtIndex:
- (void)BMP_MArrayRemoveObjectAtIndex:(NSUInteger)index{
    return [self BMP_MArrayRemoveObjectAtIndex:index];
}

//insertObject:atIndex:
- (void)BMP_MArrayInsertObject:(id)anObject atIndex:(NSUInteger)index{
    [self BMP_MArrayInsertObject:anObject atIndex:index];
}

//getObjects:range:
- (void)BMP_MArrayGetObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range{
    return [self BMP_MArrayGetObjects:objects range:range];
}


@end

@interface NSDictionary (BMPProtector)

@end

@implementation NSDictionary  (BMPProtector)

@end

@interface NSMutableDictionary (BMPProtector)

@end

@implementation NSMutableDictionary  (BMPProtector)

@end

@interface NSString (BMPProtector)

@end

@implementation NSString  (BMPProtector)

@end

@interface NSMutableString (BMPProtector)

@end

@implementation NSMutableString  (BMPProtector)

@end

@implementation BayMaxContainers

+ (void)BMPExchangeContainersMethodsWithCatchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler{
    _containerErrorHandler = errorHandler;
    //NSArray
    [self exchangeMethodsInNSArray];
    //NSMutableArray
    [self exchangeMethodsInNSMutableArray];
    //NSString
    [self exchangeMethodsInNSString];
    //NSMutableString
    [self exchangeMethodsInNSMutableString];
}

+ (void)exchangeMethodsInNSArray{
    Class __NSArray = NSClassFromString(@"NSArray");
    Class __NSArrayI = NSClassFromString(@"__NSArrayI");
    Class __NSSingleObjectArrayI = NSClassFromString(@"__NSSingleObjectArrayI");
    Class __NSArray0 = NSClassFromString(@"__NSArray0");
    //objectsAtIndexes:
    BMP_EXChangeInstanceMethod(__NSArray, @selector(objectsAtIndexes:), __NSArray, @selector(BMP_objectsAtIndexes:));
    //objectAtIndex:
    BMP_EXChangeInstanceMethod(__NSArrayI, @selector(objectAtIndex:), __NSArrayI, @selector(BMP__NSArrayIObjectAtIndex:));
    BMP_EXChangeInstanceMethod(__NSSingleObjectArrayI, @selector(objectAtIndex:), __NSSingleObjectArrayI, @selector(BMP__NSSingleObjectArrayIObjectAtIndex:));
    BMP_EXChangeInstanceMethod(__NSArray0, @selector(objectAtIndex:), __NSArray0, @selector(BMP__NSArray0ObjectAtIndex:));
}

+ (void)exchangeMethodsInNSMutableArray{

}

+ (void)exchangeMethodsInNSString{
    
}

+ (void)exchangeMethodsInNSMutableString{
    
}

@end


