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
    NSString *key = nil;
    NSArray *array0 = @[@"1",@"2",key];
    NSLog(@"value:%@",array0[2]);
    NSLog(@"value1:%@",[array0 objectAtIndex:3]);
    NSArray * array1 = [NSArray arrayWithObjects:@"2",@"3",@"4", nil];
    NSLog(@"value2:%@",[array1 objectAtIndex:4]);
    NSLog(@"value3:%@",[array1 objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)]]);

    NSMutableArray *arrayM0 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",key, nil];
    NSLog(@"valueM:%@",arrayM0[3]);
    [arrayM0 removeObjectAtIndex:4];
    [arrayM0 removeObjectsInRange:NSMakeRange(1, 3)];
    [arrayM0 removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    [arrayM0 insertObject:@"1" atIndex:5];
    [arrayM0 insertObjects:@[@"1",@"4"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 1)]];
    NSLog(@"arrayM0:%@",arrayM0);
    //数组元素为nil
    NSArray *testArray = @[@"1",@"2",key,key];
    NSLog(@"testArray:%@",testArray);
    [arrayM0 addObject:key];
    
    [arrayM0 addObjectsFromArray:@[@"1",@"1",key,key]];
    NSLog(@"arrayM0:%@",arrayM0);
    [arrayM0 insertObject:key atIndex:2];
    NSLog(@"arrayM0:%@",arrayM0);
    [arrayM0 insertObjects:@[@"1",@"1",key,key] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)]];
    NSLog(@"arrayM0:%@",arrayM0);
    
    NSDictionary *dic = @{
                              @"abc":@"das",
                              @"abd":@"das",
                              @"abg":@"das",
                              @"ada":key
                              };
    NSLog(@"dic:%@",dic);
    NSLog(@"dicKey:%@",dic[key]);
    NSLog(@"xxss:%@",dic[@"xsss"]);
    NSLog(@"objectforkey:%@", [dic objectForKey:@"ddd"]);
   
    
     [NSDictionary dictionaryWithObject:@"d" forKey:key];//initWithObjects
    [NSDictionary dictionaryWithObjects:@[@"1",@"1",key] forKeys:@[@"dd",@"dss",key]];

    
    @{
      @"kkd":key
      };
  
    
    @{
      @"1":@"dee",
      @"kdka":key,
      key:@"dad"
      };
    
    [NSMutableDictionary dictionaryWithObject:@"ddad" forKey:key];
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    
    [dicM setObject:@"ddk" forKey:key];
    [dicM removeObjectForKey:key];
    
    NSString *string = @"dfdfdklfd";
    [string characterAtIndex:10];
    [string substringFromIndex:10];//-[__NSCFConstantString BMP_substringFromIndex:]: Index 10 out of bounds; string length 9
    [string substringToIndex:20];//-[__NSCFConstantString BMP_substringFromIndex:]: Index 10 out of bounds; string length 9
    NSString *rangeString = [string substringWithRange:NSMakeRange(7, 20)];
    NSLog(@"rangeString:%@",rangeString);
    NSString *replacingString = [string  stringByReplacingOccurrencesOfString:@"fdk*" withString:@"xxxxx"];
    NSLog(@"replacingString:%@",replacingString);
    
    NSString *rangeString2 = [string stringByReplacingCharactersInRange:NSMakeRange(2, 10) withString:@"********"];
    NSLog(@"rangeString2:%@",rangeString2);
    
    NSMutableString *stringM = [NSMutableString stringWithFormat:@"mutable"];
    [stringM insertString:@"xxx" atIndex:stringM.length];
    NSLog(@"stringM:%@",stringM);
    
    [stringM deleteCharactersInRange:NSMakeRange(2, 10)];
    NSLog(@"deleteStringM:%@",stringM);
    
    [stringM replaceCharactersInRange:NSMakeRange(2, 10) withString:@"dds"];
    NSLog(@"deleteStringM:%@",stringM);

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


