//
//  ViewController.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"

#import "TestAutoDegradeVC.h"
#import "TestManaulDegradeVC.h"

#import "AssistMicros.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titleArray;
}
/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];
    titleArray = @[
                   @{
                       @"title":@"UnrecognizedSelector",
                       @"class":@"TestUnrecognizedSelVC"
                       },
                   @{
                       @"title":@"TimerError",
                       @"class":@"TestTimerErrorVC"
                       },
                   @{
                       @"title":@"KVOError",
                       @"class":@"TestKVOErrorVC"
                       },
                   @{
                       @"title":@"NotificationError",
                       @"class":@"TestNotificationErrorVC"                       
                       },
                   @{
                       @"title":@"AutoDegrade",
                       @"class":@"TestAutoDegradeVC"
                       },
                   @{
                       @"title":@"ManaulDegrade",
                       @"class":@"TestManaulDegradeVC"
                       }
                   ];
    [self.view addSubview:self.tableview];
}

#pragma mark ======== System Delegate ========

#pragma mark UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID = @"mainCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    cell.textLabel.text = [titleArray[indexPath.row]objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item =  titleArray[indexPath.row];
    Class cls = NSClassFromString([item objectForKey:@"class"]);
    [self presentViewController:[[cls alloc]init] animated:YES completion:nil];
}

#pragma mark ======== Custom Delegate ========


#pragma mark ======== Private Methods ========


#pragma mark ======== Setters && Getters ========


- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 44;
        _tableview.tableFooterView = [[UIView alloc]init];
    }
    return _tableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
