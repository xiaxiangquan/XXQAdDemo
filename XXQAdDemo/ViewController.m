//
//  ViewController.m
//  XXQAdDemo
//
//  Created by 夏祥全 on 16/6/17.
//  Copyright © 2016年 xiaxiangquan. All rights reserved.
//

#import "ViewController.h"
#import "WJLaunchAdMonitor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [WJLaunchAdMonitor showAtView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
