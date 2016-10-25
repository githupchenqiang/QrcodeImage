//
//  ViewController.m
//  GDLString
//
//  Created by QAING CHEN on 16/10/25.
//  Copyright © 2016年 QiangChen. All rights reserved.
//

#import "ViewController.h"
#import "MKController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *click = [UIButton buttonWithType:UIButtonTypeSystem];
    click.frame = CGRectMake(100, 100, 100, 40);
    [click addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchDown];
    click.layer.cornerRadius = 2;
    click.layer.masksToBounds =  YES;
    click.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:click];
 
    _valueNumber = [[UITextField alloc]initWithFrame:CGRectMake(100,220,100,20)];
    _valueNumber.placeholder = @"";
    _valueNumber.font = [UIFont systemFontOfSize:14];
    _valueNumber.textColor = [UIColor orangeColor];
    [self.view addSubview:_valueNumber];
    
}



- (void)clickAction
{
    MKController* vc = [[MKController alloc] init];
    vc.pvc = self;
    [self.navigationController pushViewController:vc animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
