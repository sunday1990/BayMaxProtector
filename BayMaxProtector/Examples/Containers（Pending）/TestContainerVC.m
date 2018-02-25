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
    NSArray *array0 = @[@"1",@"2"];
    NSLog(@"value:%@",array0[2]);
    NSLog(@"value1:%@",[array0 objectAtIndex:3]);
    NSArray * array1 = [NSArray arrayWithObjects:@"2",@"3",@"4", nil];
    NSLog(@"value2:%@",[array1 objectAtIndex:4]);
    NSLog(@"value3:%@",[array1 objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)]]);
    NSMutableArray *arrayM0 = [NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
    NSLog(@"valueM:%@",arrayM0[3]);
    [arrayM0 removeObjectAtIndex:4];
    [arrayM0 removeObjectsInRange:NSMakeRange(1, 3)];
    [arrayM0 removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    [arrayM0 insertObject:@"1" atIndex:5];
    [arrayM0 insertObjects:@[@"1",@"4"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 1)]];
    NSLog(@"arrayM0:%@",arrayM0);
    NSString *key = nil;
    //数组元素为nil
    NSArray *testArray = @[@"1",@"2",key,key];
    NSLog(@"testArray:%@",testArray);
//    [arrayM0 addObject:key];
    
//    [arrayM0 addObjectsFromArray:@[@"1",@"1",key,key]];
//    NSLog(@"arrayM0:%@",arrayM0);
//    [arrayM0 insertObject:key atIndex:2];
    NSLog(@"arrayM0:%@",arrayM0);
    [arrayM0 insertObjects:@[@"1",@"1",key,key] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)]];
    NSLog(@"arrayM0:%@",arrayM0);

    
    //    NSDictionary *dic = @{
    //                          @"abc":@"das",
    //                          @"ada":key
    //                          };
    
    
    //1、    [NSDictionary dictionaryWithObject:@"d" forKey:key];//initWithObjects
    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[@"1"] forKeys:@[key]];//-[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]'
    
//    NSDictionary dictionaryWithObjectsAndKeys:<#(nonnull id), ...#>, nil
    
//[NSDictionary dictionaryWithObjects:(id  _Nonnull const __unsafe_unretained * _Nullable) forKeys:<#(id<NSCopying>  _Nonnull const __unsafe_unretained * _Nullable)#> count:<#(NSUInteger)#>]
    
//    [NSDictionary dictionaryWithValuesForKeys:<#(nonnull NSArray<NSString *> *)#>]

    
//    @{
//      @"kkd":key
//      };
  
    
//    @{
//      @"1":@"dee",
//      @"kdka":key,
//      key:@"dad"
//      };
    
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


