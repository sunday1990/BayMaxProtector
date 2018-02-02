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
#import "WebViewController.h"
#import "AssistMicros.h"


#import "BayMaxDegradeAssist.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,BayMaxDegradeAssistDelegate,BayMaxDegradeAssistDataSource>
{
    NSArray *titleArray;
    
    NSArray<NSString *> *_vcNames;
    NSArray<NSArray<NSDictionary *> *> *_params;
    NSArray<NSString *> *_urls;
    NSArray<NSString *> *_initiativeVCS;
}
/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableview;
/**
 获取自动降级配置的按钮
 */
@property (nonatomic, strong) UIButton *autoDegradeBtn;
/**
 获取手动降级配置的按钮
 */
@property (nonatomic, strong) UIButton *manaulDegradeBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    titleArray = @[
                   @{
                       @"title":@"UnrecognizedSelector || AutoDegrade",
                       @"class":@"TestUnrecognizedSelVC"
                       },
                   @{
                       @"title":@"UnrecognizedSelector-ViewDidLoad",
                       @"class":@"TestViewDidloadUnrecognizedSelVC"
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
                       @"title":@"ManaulDegrade",
                       @"class":@"TestManaulDegradeVC"
                       }
                   ];
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.autoDegradeBtn];
    [self.view addSubview:self.manaulDegradeBtn];
    
    /*设置Assist的代理与数据源*/
    [BayMaxDegradeAssist Assist].degradeDelegate = self;
    [BayMaxDegradeAssist Assist].degradeDatasource = self;
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
    if ([[item objectForKey:@"class"] isEqualToString:@"TestUnrecognizedSelVC"]) {
        UIViewController *vc = [[cls alloc]init];
        [vc setValue:@"someOne" forKey:@"userName"];
        [vc setValue:@"00001" forKey:@"userID"];
        [self presentViewController:vc animated:YES completion:nil];
        return;//
    }else if ([[item objectForKey:@"class"] isEqualToString:@"TestManaulDegradeVC"]){
        UIViewController *vc = [[cls alloc]init];
        [vc setValue:@"100000" forKey:@"uid"];
        [vc setValue:@"type001" forKey:@"type"];
        [self presentViewController:vc animated:YES completion:nil];
        return;//        
    }
    [self presentViewController:[[cls alloc]init] animated:YES completion:nil];
}

#pragma mark ======== Custom Delegate ========
#pragma mark BayMaxDegradeAssistDataSource
- (NSInteger)numberOfRelations{
    return _vcNames.count;
}

- (NSString *)nameOfViewControllerAtIndex:(NSInteger)index{
    return _vcNames[index];
}

- (NSArray<NSDictionary<NSString * , NSString *> *> *)correspondencesBetweenH5AndIOSParametersAtIndex:(NSInteger)index{
    if (_params.count>index) {
        return _params[index];
    }else{
        return nil;
    }
}

- (NSString *)urlOfViewControllerAtIndex:(NSInteger)index{
    if (_urls.count>index) {
        return _urls[index];
    }else{
        return nil;
    }
}

- (NSArray *)viewControllersToDegradeInitiative{
    return _initiativeVCS;
}

#pragma mark BayMaxDegradeAssistDelegate
- (void)autoDegradeInstanceOfViewController:(UIViewController *)degradeVC ifErrorHappensInProcessExceptViewDidLoadWithReplacedCompleteURL:(NSString *)completeURL relation:(NSDictionary *)relation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [degradeVC.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"用来替代该页面的URL为：%@",completeURL] maskType:SVProgressHUDMaskTypeBlack];
        //获取拼接后的url
        WebViewController *webVC = [[WebViewController alloc]init];
        webVC.url = completeURL;
        [degradeVC addChildViewController:webVC];
        [degradeVC.view addSubview:webVC.view];
    });
}

- (void)autoDegradeClassOfViewController:(Class)degradeCls ifErrorHappensInViewDidLoadProcessWithReplacedURL:(NSString *)URL relation:(NSDictionary *)relation{
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.url = URL;
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"用来替代该页面的URL为：%@",URL] maskType:SVProgressHUDMaskTypeBlack];
    UIViewController *vc = [[BayMaxDegradeAssist Assist]topViewController];
    [vc presentViewController:webVC animated:YES completion:nil];
}


#pragma mark ======== Event Response ========
- (void)requestAutoDegradeConfiguration{
    [SVProgressHUD showWithStatus:@"获取自动降级配置" maskType:SVProgressHUDMaskTypeBlack];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _vcNames = @[
                     @"TestUnrecognizedSelVC",
                     @"TestViewDidloadUnrecognizedSelVC",
                     @"TestManaulDegradeVC"
                     ];
        /*H5-ios参数对应关系，与上面的vc一一对应，数组可以为空，但不能为Null*/
        _params = @[
                        @[
                            @{@"userid":@"userID"},
                            @{ @"username":@"userName"}
                        ],
                        
                        @[
                         ],
                                            
                        @[
                            @{@"uid":@"uid"},
                            @{@"typeid":@"type"}
                         ]
                    ];
        
        _urls = @[
                  @"https://juejin.im",
                  @"https://sina.cn",
                  @"https://www.baidu.com"
                  ];
        [SVProgressHUD showSuccessWithStatus:@"获取自动降级配置" maskType:SVProgressHUDMaskTypeBlack];
        [[BayMaxDegradeAssist Assist]reloadRelations];
    });
    
}

- (void)requestManaulDegradeConfiguration{
    [SVProgressHUD showWithStatus:@"获取需要手动降级的视图控制器"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:@"获取成功"];
        _initiativeVCS = @[
                           @"TestManaulDegradeVC"
                           ];
        [[BayMaxDegradeAssist Assist]reloadRelations];
    });
}

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

- (UIButton *)autoDegradeBtn{
    if (!_autoDegradeBtn) {
        _autoDegradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _autoDegradeBtn.frame  = CGRectMake(12, HEIGHT-120, 120, 50);
        [_autoDegradeBtn setTitle:@"获取自动降级配置" forState:UIControlStateNormal];
        _autoDegradeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_autoDegradeBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_autoDegradeBtn addTarget:self action:@selector(requestAutoDegradeConfiguration) forControlEvents:UIControlEventTouchUpInside];
        _autoDegradeBtn.backgroundColor = DEFAULT_COLOR;
        _autoDegradeBtn.layer.cornerRadius = 10;
    }
    return _autoDegradeBtn;
}

- (UIButton *)manaulDegradeBtn{
    if (!_manaulDegradeBtn) {
        _manaulDegradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _manaulDegradeBtn.frame  = CGRectMake(12+120+12, HEIGHT-120, 150, 50);
        [_manaulDegradeBtn setTitle:@"获取需手动降级的页面" forState:UIControlStateNormal];
        _manaulDegradeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _manaulDegradeBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_manaulDegradeBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_manaulDegradeBtn addTarget:self action:@selector(requestManaulDegradeConfiguration) forControlEvents:UIControlEventTouchUpInside];
        _manaulDegradeBtn.backgroundColor = DEFAULT_COLOR;
        _manaulDegradeBtn.layer.cornerRadius = 10;
    }
    return _manaulDegradeBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
