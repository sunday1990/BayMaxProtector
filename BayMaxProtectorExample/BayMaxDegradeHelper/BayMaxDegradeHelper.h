//
//  BayMaxDegradeHelper.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

/*
 配置时需要
[
     {
        vc - name
        vcUrl- url
        Array:
        [
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
        ]
     },
 
     {
         vc - name
         vcUrl- url
         Array:
         [
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
             {H5Param-IosParam对应关系}
         ]
      }
 ]
 返回一个字典数组

 */

#import <Foundation/Foundation.h>
#import "BayMaxDegradeProtocol.h"

/*vc*/
FOUNDATION_EXPORT NSString *const BMPHelperKey_VC;
/*params*/
FOUNDATION_EXPORT NSString *const BMPHelperKey_Params;
/*url*/
FOUNDATION_EXPORT NSString *const BMPHelperKey_Url;

@protocol BayMaxDegradeHelperDelegate
@required;
- (NSInteger)numberOfRelations;
- (NSString *)nameOfViewControllerAtIndex:(NSInteger)index;
- (NSString *)urlOfViewControllerAtIndex:(NSInteger)index;
- (NSArray *)paramsBetweenH5andIosAtIndex:(NSInteger)index;

@end

@interface BayMaxDegradeHelper : NSObject

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *relations;

@property (nonatomic, assign) id<BayMaxDegradeHelperDelegate>degradeDelegate;

+ (instancetype)sharedBayMaxDegradeHelper;

- (void)reloadRelations;

- (NSDictionary *)relationForViewController:(Class)cls;

@end
