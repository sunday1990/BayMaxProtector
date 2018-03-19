//
//  TestContainerVC.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/1.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestContainerVC.h"

@interface TestContainerVC ()

@end

@implementation TestContainerVC
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testArray];
    [self testMutableArray];
    [self testDictionary];
    [self testMutableDictionary];
    [self testString];
    [self testMutableString];
}

- (void)testArray{
   /*
    NSArray->Methods On Protection:
    1、@[nil]
    2、arrayWithObjects:count:
    3、objectsAtIndexes:
    4、objectAtIndex:
    */
    NSString *value = nil;
    NSString *key = nil;
    //1、@[nil]
    NSArray *array0 = @[value];
    NSLog(@"array0:%@",array0);
    //2、arrayWithObjects:count:
    NSArray *array1 = [NSArray arrayWithObjects:@"abc",value,value, nil];
    NSLog(@"array1:%@",array1);
    //3、objectsAtIndexes:
    NSArray *array2 = @[@"1",@"2",@"3"];
    NSArray *objectsAtIndexes = [array2 objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]];
    NSLog(@"objectsAtIndexes:%@",objectsAtIndexes);
    //4、objectAtIndex
    id objectAtIndex = [array2 objectAtIndex:4];
    array2[4];
}
- (void)testMutableArray{
    /*
     0、arrayWithObjects:nil
     1、objectAtIndex:
     2、removeObjectAtIndex:
     3、removeObjectsInRange:
     4、removeObjectsAtIndexes:
     5、insertObject:atIndex:
     6、insertObjects:atIndexes:
     7、addObject:nil
     8、replaceObjectAtIndex:withObject:
     9、replaceObjectsAtIndexes:withObjects:
     10、replaceObjectsInRange:withObjectsFromArray:
     */
    NSString *value = nil;
    NSString *key = nil;
    //0、arrayWithObjects:nil
    NSMutableArray *array0 = [NSMutableArray arrayWithObjects:@"aklkd",value,value, nil];
    NSLog(@"array0:%@",array0);
    //1、objectAtIndex:
    NSMutableArray *array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    NSString *objectAtIndex = [array1 objectAtIndex:5];
    objectAtIndex = array1[4];
    //2、removeObjectAtIndex:
    [array1 removeObjectAtIndex:5];
    //3、removeObjectsInRange:
    [array1 removeObjectsInRange:NSMakeRange(2, 3)];
    NSLog(@"removeObjectsInRangeArray1:%@",array1);
    //4、removeObjectsAtIndexes:
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)]];
    NSLog(@"removeObjectsAtIndexesArray:%@",array1);
    //5、insertObject:atIndex:
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 insertObject:@"5" atIndex:5];
    NSLog(@"insertObjectArray:%@",array1);
    //6、insertObjects:atIndexes:
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 insertObjects:@[@"6",@"7",@"8"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 3)]];
    [array1 insertObjects:@[@"6",@"7",@"8"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 3)]];
    [array1 insertObjects:@[@"6",@"7",@"8"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 2)]];
    NSLog(@"insertObjectsAtIndexes%@",array1);
    //7、addObject:nil
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 addObject:value];
    //8、
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 replaceObjectAtIndex:5 withObject:@"5"];
    
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 replaceObjectsInRange:NSMakeRange(1, 4) withObjectsFromArray:@[@"5",@"6",@"7",@"8"]];

    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)] withObjects:@[@"5",@"6",@"7",@"8"]];
    
    array1 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4", nil];
    [array1 replaceObjectAtIndex:2 withObject:nil];
    
    
}

- (void)testDictionary{
    /*
     1 @{nil:nil}
     2、dictionaryWithObject:forKey：
     3、dictionaryWithObjects:forKeys:
     4、dictionaryWithObjects:forKeys:count:
     */
    //1 @{nil:nil}
    NSString *value = nil;
    NSString *key = nil;
    NSDictionary *dic = @{@"key":value};
    dic = @{key:@"value"};
//    2、dictionaryWithObject:forKey：
    [NSDictionary dictionaryWithObject:@"value" forKey:key];
    [NSDictionary dictionaryWithObject:value forKey:@"key"];
    //    3、dictionaryWithObjects:forKeys:
//    [NSDictionary dictionaryWithObjects:@[@"1",@"2",@"3"] forKeys:@[@"1",@"2",key]];
//    4、dictionaryWithObjects:forKeys:count:
}

- (void)testMutableDictionary{
    /*
     1、setObject:forKey:
     2、removeObjectForKey:
     */

    NSString *value = nil;
    NSString *key = nil;
//    1、setObject:forKey:
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@"value" forKey:key];
    [dicM setObject:value forKey:@"key"];
    [dicM setObject:@"value" forKey:@"key"];
    NSLog(@"dicM:%@",dicM);
//    2、removeObjectForKey:
    [dicM removeObjectForKey:key];
    NSLog(@"dicM:%@",dicM);
}

- (void)testString{
    /*
     NSString->Methods On Protection:
     2、substringFromIndex:
     3、substringToIndex:
     4、substringWithRange:
     5、stringByReplacingCharactersInRange:withString:
     */
    NSString *string = @"abcdefg";
    //    1、characterAtIndex：
    NSLog(@"characterAtIndex:%c",[string characterAtIndex:20]);
    //    2、substringFromIndex:
    NSLog(@"substringFromIndex:%@",[string substringFromIndex:20]);
    //    3、substringToIndex:
    NSLog(@"substringToIndex:%@",[string substringToIndex:20]);
    //    4、substringWithRange:
    NSLog(@"substringWithRange:%@",[string substringWithRange:NSMakeRange(2, 20)]);
    NSLog(@"substringWithRange:%@",[string substringWithRange:NSMakeRange(20, 10)]);
    //    5、stringByReplacingCharactersInRange:withString:
    NSLog(@"stringByReplacingCharactersInRange:%@",[string stringByReplacingCharactersInRange:NSMakeRange(2, 20) withString:@"****"]);
    NSLog(@"stringByReplacingCharactersInRange:%@",[string stringByReplacingCharactersInRange:NSMakeRange(20, 20) withString:@"****"]);
}

- (void)testMutableString{
    /*
     NSMutableString->Methods On Protection:
     1、replaceCharactersInRange:withString:
     2、insertString:atIndex:
     3、deleteCharactersInRange:
     */
    NSMutableString *stringM = [NSMutableString stringWithFormat:@"abcdefg"];
//    1、replaceCharactersInRange:withString:
    [stringM replaceCharactersInRange:NSMakeRange(2, 20) withString:@"*****"];
    NSLog(@"replaceCharactersInRange:%@",stringM);
    
//    2、insertString:atIndex:
    stringM = [NSMutableString stringWithFormat:@"abcdefg"];
    [stringM insertString:@"****" atIndex:20];
    NSLog(@"insertString:%@",stringM);
    
//    3、deleteCharactersInRange:
    stringM = [NSMutableString stringWithFormat:@"abcdefg"];
    [stringM deleteCharactersInRange:NSMakeRange(2, 20)];
    NSLog(@"deleteCharactersInRange:%@",stringM);
    
    stringM = [NSMutableString stringWithFormat:@"abcdefg"];
    [stringM deleteCharactersInRange:NSMakeRange(10, 10)];
    NSLog(@"deleteCharactersInRange:%@",stringM);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========

#pragma mark ======== Private Methods ========

#pragma mark ======== Setters && Getters ========

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


