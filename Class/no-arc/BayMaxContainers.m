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
//错误信息统一处理
/*
 NSArray *callStackSymbolsArr = [NSThread callStackSymbols];\
 BMPErrorCallStackSymbols:callStackSymbolsArr
 */
#define BMP_Container_ErrorHandler(errorType,errorInfo)\
NSArray *callStackSymbolsArr = [NSThread callStackSymbols];\
BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeContainers infos:@{\
errorType:errorInfo,\
BMPErrorCallStackSymbols:callStackSymbolsArr\
}];\
if (_containerErrorHandler) {\
_containerErrorHandler(bmpError);\
}

//#define BMP_Container_ErrorHandler(errorType,errorInfo)\
//BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeContainers infos:@{\
//errorType:errorInfo\
//}];\
//if (_containerErrorHandler) {\
//_containerErrorHandler(bmpError);\
//}

//不可变数组越界
#define BMP_Array_BeyondBounds_ErrorHandler(ArrayType,ArrayMethod,Index)\
NSString *errorInfo = [NSString stringWithFormat:@"*** -[%@ %@]: index %ld beyond bounds [0 .. %ld]",ArrayType,ArrayMethod,Index,(unsigned long)self.count];\
BMP_Container_ErrorHandler(BMPErrorArray_Beyond,errorInfo)

//可变数组越界
#define BMP_ArrayM_BeyondBounds_ErrorHandler(ErrorInfo)\
BMP_Container_ErrorHandler(BMPErrorArray_Beyond,ErrorInfo)

//可变数组插入Nil元素
#define BMP_ArrayM_NilObject_ErrorHandler(ErrorInfo)\
BMP_Container_ErrorHandler(BMPErrorArray_NilObject,ErrorInfo)

//不可变字典key或者value为Nil
#define BMP_Dictionary_ErrorHandler(ErrorInfo)\
BMP_Container_ErrorHandler(BMPErrorDictionary_NilKey,ErrorInfo)

//可变字典key或者value为Nil
#define BMP_DictionaryM_ErrorHandler(ErrorInfo)\
BMP_Container_ErrorHandler(BMPErrorDictionary_NilKey,ErrorInfo)

//#define BMP_String_ErrorHandler(ErrorInfo)\


@interface NSArray (BMPProtector)

@end

@implementation NSArray (BMPProtector)
// NSArray/__NSArrayI/__NSSingleObjectArrayI/__NSArray0
//objectsAtIndexes:
+ (instancetype)BMP_ArrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt{
    NSUInteger index = 0;
    id _Nonnull objectsNew[cnt];
    for (int i = 0; i<cnt; i++) {
        if (objects[i]) {
            objectsNew[index] = objects[i];
            index++;
        }else{
            //记录错误
            NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[%d]",i];
            BMP_Container_ErrorHandler(BMPErrorArray_NilObject, errorInfo);
        }
    }
    return [self BMP_ArrayWithObjects:objectsNew count:index];
}

//objectAtIndexedSubscript
- (id)BMP_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx >= self.count) {
        //记录错误
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayI objectAtIndexedSubscript:]: index %ld beyond bounds [0 .. %ld]'",(unsigned long)idx,(unsigned long)self.count];
        BMP_Container_ErrorHandler(BMPErrorArray_Beyond, errorInfo);
        return nil;
    }
    return [self BMP_objectAtIndexedSubscript:idx];
}

//objectAtIndex:
- (id)BMP__NSArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSArrayI",NSStringFromSelector(_cmd),(unsigned long)index);
        return nil;
    }
    return [self BMP__NSArrayIObjectAtIndex:index];
}

- (id)BMP__NSSingleObjectArrayIObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSSingleObject",NSStringFromSelector(_cmd),(unsigned long)index);
        return nil;
    }
    return [self BMP__NSSingleObjectArrayIObjectAtIndex:index];
}

- (id)BMP__NSArray0ObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSArray0",NSStringFromSelector(_cmd),(unsigned long)index);
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
        BMP_Array_BeyondBounds_ErrorHandler(@"__NSArrayM",NSStringFromSelector(_cmd),(unsigned long)index);
        return nil;
    }
    return [self BMP_MArrayObjectAtIndex:index];
}

//objectAtIndexedSubscript
- (id)BMP_MArrayobjectAtIndexedSubscript:(NSUInteger)idx{
    if (idx >= self.count) {
        //记录错误
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM objectAtIndexedSubscript:]: index %ld beyond bounds [0 .. %ld]'",(unsigned long)idx,(unsigned long)self.count];
        BMP_Container_ErrorHandler(BMPErrorArray_Beyond, errorInfo);
        return nil;
    }
    return [self BMP_MArrayobjectAtIndexedSubscript:idx];
}

//removeObjectAtIndex:
- (void)BMP_MArrayRemoveObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM removeObjectsInRange:]: range {%ld, 1} extends beyond bounds [0 .. %ld]",(unsigned long)index,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectAtIndex:index];
}


- (void)BMP_MArrayRemoveObjectsInRange:(NSRange)range{
    if (range.location+range.length>self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM removeObjectsInRange:]: range {%ld, %ld} extends beyond bounds [0 .. %ld]",(unsigned long)range.location,(unsigned long)range.length,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayRemoveObjectsInRange:range];
}

//insertObject:atIndex:
- (void)BMP_MArrayInsertObject:(id)anObject atIndex:(NSUInteger)index{
    if (anObject == nil) {
        BMP_ArrayM_NilObject_ErrorHandler(@"***  -[__NSArrayM insertObject:atIndex:]: object cannot be nil");
        return;
    }
    if (index > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM insertObject:atIndex:]: index %ld beyond bounds [0 .. %ld]",(unsigned long)index,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayInsertObject:anObject atIndex:index];
}

- (void)BMP_MArrayInsertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes{
    if (indexes.firstIndex > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSMutableArray insertObjects:atIndexes:]: index %ld in index set beyond bounds [0 .. %ld]",(unsigned long)indexes.firstIndex,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }else if (objects.count != (indexes.count)){
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSMutableArray insertObjects:atIndexes:]: count of array (%ld) differs from count of index set (%ld)",(unsigned long)objects.count,(unsigned long)indexes.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_MArrayInsertObjects:objects atIndexes:indexes];
}

//replaceObjectAtIndex
- (void)BMP_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if (anObject == nil) {
        BMP_ArrayM_NilObject_ErrorHandler(@"***  -[__NSArrayM replaceObjectAtIndex:withObject:]: object cannot be nil");
        return;
    }
    if (index >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM replaceObjectAtIndex:withObject:]: index %ld beyond bounds [0 .. %ld]",(unsigned long)index,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
        return;
    }
    [self BMP_replaceObjectAtIndex:index withObject:anObject];
}

- (void)BMP_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects{
    if (indexes.lastIndex >= self.count||indexes.firstIndex >= self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSArrayM replaceObjectsInRange:withObjects:count:]: range {%ld, %ld} extends beyond bounds [0 .. %ld]",(unsigned long)indexes.firstIndex,(unsigned long)indexes.count,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
    }else{
        [self BMP_replaceObjectsAtIndexes:indexes withObjects:objects];
    }
}

-(void)BMP_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray{
    if (range.location+range.length > self.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSMutableArray replaceObjectsInRange:withObjectsFromArray:]: range {%ld, %ld} extends beyond bounds [0 .. %ld]",(unsigned long)range.location,(unsigned long)range.length,(unsigned long)self.count];
        BMP_ArrayM_BeyondBounds_ErrorHandler(errorInfo);
    }else{
        [self BMP_replaceObjectsInRange:range withObjectsFromArray:otherArray];
    }
}

@end

@interface NSDictionary (BMPProtector)

@end

@implementation NSDictionary  (BMPProtector)

+ (instancetype)BMP_dictionaryWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    return [self BMP_dictionaryWithObjects:objects forKeys:keys count:cnt];
}

+ (instancetype)BMP_dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys{
    if (objects.count != keys.count) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[NSDictionary initWithObjects:forKeys:]: count of objects (%ld) differs from count of keys (%ld)",(unsigned long)objects.count,(unsigned long)keys.count];
        BMP_Dictionary_ErrorHandler(errorInfo);
        return nil;//huicha
    }
    NSUInteger index = 0;
    id _Nonnull objectsNew[objects.count];
    id <NSCopying> _Nonnull keysNew[keys.count];
    for (int i = 0; i<keys.count; i++) {
        if (objects[i] && keys[i]) {
            objectsNew[index] = objects[i];
            keysNew[index] = keys[i];
            index ++;
        }else{
            NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[%d]",i];
            BMP_Dictionary_ErrorHandler(errorInfo);
        }
    }
    return [self BMP_dictionaryWithObjects:[NSArray arrayWithObjects:objectsNew count:index] forKeys: [NSArray arrayWithObjects:keysNew count:index]];
}

- (instancetype)BMP_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    NSUInteger index = 0;
    id _Nonnull objectsNew[cnt];
    id <NSCopying> _Nonnull keysNew[cnt];
    //'*** -[NSDictionary initWithObjects:forKeys:]: count of objects (1) differs from count of keys (0)'
    for (int i = 0; i<cnt; i++) {
        if (objects[i] && keys[i]) {//可能存在nil的情况
            objectsNew[index] = objects[i];
            keysNew[index] = keys[i];
            index ++;
        }else{
            NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[%d]",i];
            BMP_Dictionary_ErrorHandler(errorInfo);
        }
    }
    return [self BMP_initWithObjects:objectsNew forKeys:keysNew count:index];
}

@end

@interface NSMutableDictionary (BMPProtector)

@end

@implementation NSMutableDictionary  (BMPProtector)

//setObject:forKey:
- (void)BMP_dictionaryMSetObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject == nil || aKey == nil) {
        NSString * errorInfo = @"*** setObjectForKey: object or key cannot be nil";
        BMP_DictionaryM_ErrorHandler(errorInfo);
    }else{
        [self BMP_dictionaryMSetObject:anObject forKey:aKey];
    }
}

//removeObjectForKey:
- (void)BMP_dictionaryMRemoveObjectForKey:(id)aKey{
    if (aKey == nil) {
        NSString *errorInfo = @"*** -[__NSDictionaryM removeObjectForKey:]: key cannot be nil";
        BMP_DictionaryM_ErrorHandler(errorInfo);

    }else{
        [self BMP_dictionaryMRemoveObjectForKey:aKey];
    }
}

@end

@interface NSString (BMPProtector)

@end

@implementation NSString  (BMPProtector)
- (unichar)BMP_characterAtIndex:(NSUInteger)index{
    if (index>=self.length) {
        unichar characteristic = 0;
        NSString *errorInfo = @"*** -[__NSCFConstantString characterAtIndex:]: Range or index out of bounds";
        BMP_Container_ErrorHandler(BMPErrorString_Beyond, errorInfo);
        return characteristic;
    }
    return [self BMP_characterAtIndex:index];
}

- (NSString *)BMP_substringFromIndex:(NSUInteger)from{
    id instance = nil;
    @try {
        instance = [self BMP_substringFromIndex:from];
    }
    @catch (NSException *exception) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSCFConstantString substringFromIndex:]: Index %ld out of bounds; string length %ld",(unsigned long)from,(unsigned long)self.length];
        BMP_Container_ErrorHandler(BMPErrorString_Beyond, errorInfo);
    }
    @finally {
        return instance;
    }
}

- (NSString *)BMP_substringToIndex:(NSUInteger)to{
    id instance = nil;
    @try {
        instance = [self BMP_substringToIndex:to];
    }
    @catch (NSException *exception) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSCFConstantString substringToIndex:]: Index %ld out of bounds; string length %ld",(unsigned long)to,(unsigned long)self.length];
        BMP_Container_ErrorHandler(BMPErrorString_Beyond, errorInfo);
    }
    @finally {
        return instance;
    }
}

- (NSString *)BMP_substringWithRange:(NSRange)range{
    id instance = nil;
    @try {
        instance = [self BMP_substringWithRange:range];
    }
    @catch (NSException *exception) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSCFConstantString BMP_substringWithRange:]: Range {%ld, %ld} out of bounds; string length %ld",(unsigned long)range.location,(unsigned long)range.length,(unsigned long)self.length];
        BMP_Container_ErrorHandler(BMPErrorString_Beyond, errorInfo);
    }
    @finally {
        return instance;
    }
}
@end

@interface NSMutableString (BMPProtector)

@end

@implementation NSMutableString  (BMPProtector)
- (void)BMP_insertString:(NSString *)aString atIndex:(NSUInteger)loc{
    if (loc > self.length) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSCFString insertString:atIndex:]: Range or index out of bounds"];
        BMP_Container_ErrorHandler(BMPErrorString_Beyond, errorInfo);
    }else{
        [self BMP_insertString:aString atIndex:loc];
    }
}

- (void)BMP_deleteCharactersInRange:(NSRange)range{
    if (range.location+range.length > self.length) {
        NSString *errorInfo = [NSString stringWithFormat:@"*** -[__NSCFString deleteCharactersInRange:]: Range or index out of bounds"];
        BMP_Container_ErrorHandler(BMPErrorString_Beyond, errorInfo);
        if (range.location < self.length) {
            [self BMP_deleteCharactersInRange:NSMakeRange(range.location, self.length-range.location)];
        }
    }else{
        [self BMP_deleteCharactersInRange:range];
    }
}

@end

@implementation BayMaxContainers

+ (void)BMPExchangeContainersMethodsWithCatchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler{
    _containerErrorHandler = errorHandler;
    //NSArray
    [self exchangeMethodsInNSArray];
    //NSMutableArray
    [self exchangeMethodsInNSMutableArray];
    //NSDictionary
    [self exchangeMethodsInNSDictionary];
    //NSMutableDictionary
    [self exchangeMethodsInNSMutableDictionary];
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
    //insertNil
    BMP_EXChangeClassMethod(__NSArray, @selector(arrayWithObjects:count:), @selector(BMP_ArrayWithObjects:count:));
    //objectAtIndex:
    BMP_EXChangeInstanceMethod(__NSArrayI, @selector(objectAtIndex:), __NSArrayI, @selector(BMP__NSArrayIObjectAtIndex:));
    BMP_EXChangeInstanceMethod(__NSArrayI, @selector(objectAtIndexedSubscript:), __NSArrayI, @selector(BMP_objectAtIndexedSubscript:));
//#endif
    BMP_EXChangeInstanceMethod(__NSSingleObjectArrayI, @selector(objectAtIndex:), __NSSingleObjectArrayI, @selector(BMP__NSSingleObjectArrayIObjectAtIndex:));
    BMP_EXChangeInstanceMethod(__NSArray0, @selector(objectAtIndex:), __NSArray0, @selector(BMP__NSArray0ObjectAtIndex:));
}

+ (void)exchangeMethodsInNSMutableArray{
    Class arrayMClass = NSClassFromString(@"__NSArrayM");
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(objectAtIndex:), arrayMClass, @selector(BMP_MArrayObjectAtIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(objectAtIndexedSubscript:), arrayMClass, @selector(BMP_MArrayobjectAtIndexedSubscript:));
//#endif
    //remove
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectAtIndex:), arrayMClass, @selector(BMP_MArrayRemoveObjectAtIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(removeObjectsInRange:), arrayMClass, @selector(BMP_MArrayRemoveObjectsInRange:));
    
    //insert
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(insertObject:atIndex:), arrayMClass, @selector(BMP_MArrayInsertObject:atIndex:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(insertObjects:atIndexes:), arrayMClass, @selector(BMP_MArrayInsertObjects:atIndexes:));
    //replace
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(replaceObjectAtIndex:withObject:), arrayMClass, @selector(BMP_replaceObjectAtIndex:withObject:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(replaceObjectsAtIndexes:withObjects:), arrayMClass, @selector(BMP_replaceObjectsAtIndexes:withObjects:));
    BMP_EXChangeInstanceMethod(arrayMClass, @selector(replaceObjectsInRange:withObjectsFromArray:), arrayMClass, @selector(BMP_replaceObjectsInRange:withObjectsFromArray:));
}

+ (void)exchangeMethodsInNSDictionary{
    Class dictionaryClass = NSClassFromString(@"NSDictionary");
    Class __NSPlaceholderDictionaryClass = NSClassFromString(@"__NSPlaceholderDictionary");
    BMP_EXChangeClassMethod(dictionaryClass, @selector(dictionaryWithObjects:forKeys:count:), @selector(BMP_dictionaryWithObjects:forKeys:count:));
    BMP_EXChangeInstanceMethod(__NSPlaceholderDictionaryClass, @selector(initWithObjects:forKeys:count:), __NSPlaceholderDictionaryClass, @selector(BMP_initWithObjects:forKeys:count:));
}

+ (void)exchangeMethodsInNSMutableDictionary{
    Class dictionaryM = NSClassFromString(@"__NSDictionaryM");
    BMP_EXChangeInstanceMethod(dictionaryM, @selector(setObject:forKey:), dictionaryM, @selector(BMP_dictionaryMSetObject:forKey:));
    BMP_EXChangeInstanceMethod(dictionaryM, @selector(removeObjectForKey:), dictionaryM, @selector(BMP_dictionaryMRemoveObjectForKey:));
}

+ (void)exchangeMethodsInNSString{
    Class stringClass = NSClassFromString(@"__NSCFConstantString");
    BMP_EXChangeInstanceMethod(stringClass, @selector(characterAtIndex:), stringClass, @selector(BMP_characterAtIndex:));
    BMP_EXChangeInstanceMethod(stringClass, @selector(substringFromIndex:), stringClass, @selector(BMP_substringFromIndex:));
    BMP_EXChangeInstanceMethod(stringClass, @selector(substringToIndex:), stringClass, @selector(BMP_substringToIndex:));
    BMP_EXChangeInstanceMethod(stringClass, @selector(substringWithRange:), stringClass, @selector(BMP_substringWithRange:));
}

+ (void)exchangeMethodsInNSMutableString{
    Class stringClass = NSClassFromString(@"__NSCFString");
    BMP_EXChangeInstanceMethod(stringClass, @selector(insertString:atIndex:), stringClass, @selector(BMP_insertString:atIndex:));
    BMP_EXChangeInstanceMethod(stringClass, @selector(deleteCharactersInRange:), stringClass, @selector(BMP_deleteCharactersInRange:));
}

@end


