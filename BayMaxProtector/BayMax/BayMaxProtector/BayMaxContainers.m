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

#define BMP_Array_ErrorHandler(ArrayType,ArrayMethod,Index)\
    NSString *errorInfo = [NSString stringWithFormat:@"'*** -[%@ %@]: index %ld beyond bounds [0 .. %ld]",ArrayType,ArrayMethod,Index,self.count];\
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];\
    BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeContainers infos:@{                                                                                             BMPErrorArray_Beyond:errorInfo,                                                                                             BMPErrorCallStackSymbols:callStackSymbolsArr                                                                                             }];\
    if (_containerErrorHandler) {\
        _containerErrorHandler(bmpError);\
    }\

#define BMP_ArrayM_ErrorHandler(ErrorInfo)\
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];\
    BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeContainers infos:@{                                                                                             BMPErrorArray_Beyond:errorInfo,                                                                                             BMPErrorCallStackSymbols:callStackSymbolsArr                                                                                             }];\
    if (_containerErrorHandler) {\
        _containerErrorHandler(bmpError);\
    }

@interface NSArray (BMPProtector)

@end

@implementation NSArray (BMPProtector)
// NSArray/__NSArrayI/__NSSingleObjectArrayI/__NSArray0
//objectsAtIndexes:
- (NSArray *)BMP_objectsAtIndexes:(NSIndexSet *)indexes{
    if (indexes.lastIndex >= self.count||indexes.firstIndex >= self.count) {
        if (indexes.firstIndex >= self.count) {
            BMP_Array_ErrorHandler(@"NSArray",NSStringFromSelector(_cmd),indexes.lastIndex);
            return nil;
        }else{
            NSIndexSet *indexesNew = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexes.firstIndex, self.count-indexes.firstIndex)];
            BMP_Array_ErrorHandler(@"NSArray",NSStringFromSelector(_cmd),indexes.lastIndex);
            return [self BMP_objectsAtIndexes:indexesNew];
        }
    }
    return [self BMP_objectsAtIndexes:indexes];
}

//objectAtIndex:
- (id)BMP__NSArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_ErrorHandler(@"__NSArrayI",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSArrayIObjectAtIndex:index];
}

- (id)BMP__NSSingleObjectArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_ErrorHandler(@"__NSSingleObject",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP__NSSingleObjectArrayIObjectAtIndex:index];
}

- (id)BMP__NSArray0ObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_ErrorHandler(@"__NSArray0",NSStringFromSelector(_cmd),index);
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
    if (index >= self.count) {
        BMP_Array_ErrorHandler(@"__NSArrayM",NSStringFromSelector(_cmd),index);
        return nil;
    }
    return [self BMP_MArrayObjectAtIndex:index];
}

//removeObjectAtIndex:
- (void)BMP_MArrayRemoveObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"-[__NSArrayM removeObjectsInRange:]: range {%ld, 1} extends beyond bounds [0 .. %ld]",index,self.count];
        BMP_ArrayM_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectAtIndex:index];
}

- (void)BMP_MArrayRemoveObjectsAtIndexes:(NSIndexSet *)indexes{
    if (indexes.lastIndex >= self.count||indexes.firstIndex >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"-[NSMutableArray removeObjectsAtIndexes:]: index %ld in index set beyond bounds [0 .. %ld]",indexes.lastIndex,self.count];
        BMP_ArrayM_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectsAtIndexes:indexes];
}

- (void)BMP_MArrayRemoveObjectsInRange:(NSRange)range{
    if (range.location >= self.count || range.location+range.length>self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"-[__NSArrayM removeObjectsInRange:]: range {%ld, %ld} extends beyond bounds [0 .. %ld]",range.location,range.length,self.count];
        BMP_ArrayM_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectsInRange:range];
}

//insertObject:atIndex:
- (void)BMP_MArrayInsertObject:(id)anObject atIndex:(NSUInteger)index{
    if (index > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"-[__NSArrayM insertObject:atIndex:]: index %ld beyond bounds [0 .. %ld]",index,self.count];
        BMP_ArrayM_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayInsertObject:anObject atIndex:index];
}

- (void)BMP_MArrayInsertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    if (indexes.firstIndex > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"-[NSMutableArray insertObjects:atIndexes:]: index %ld in index set beyond bounds [0 .. %ld]",indexes.firstIndex,self.count];
        BMP_ArrayM_ErrorHandler(errorInfo);
        return;
    }else if (objects.count != (indexes.count)){
        NSString *errorInfo = [NSString stringWithFormat:@"-[NSMutableArray insertObjects:atIndexes:]: count of array (%ld) differs from count of index set (%ld)",objects.count,indexes.count];
        BMP_ArrayM_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayInsertObjects:objects atIndexes:indexes];
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
    Class arrayMClass = NSClassFromString(@"__NSArrayM");
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(objectAtIndex:), arrayMClass, @selector(BMP_MArrayObjectAtIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectAtIndex:), arrayMClass, @selector(BMP_MArrayRemoveObjectAtIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectsInRange:), arrayMClass, @selector(BMP_MArrayRemoveObjectsInRange:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectsAtIndexes:), arrayMClass, @selector(BMP_MArrayRemoveObjectsAtIndexes:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(insertObject:atIndex:), arrayMClass, @selector(BMP_MArrayInsertObject:atIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(insertObjects:atIndexes:), arrayMClass, @selector(BMP_MArrayInsertObjects:atIndexes:));
}

+ (void)exchangeMethodsInNSString{
    
}

+ (void)exchangeMethodsInNSMutableString{
    
}

@end


