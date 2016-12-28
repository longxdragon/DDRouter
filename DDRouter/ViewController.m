//
//  ViewController.m
//  DDRouter
//
//  Created by longxdragon on 2016/12/23.
//  Copyright © 2016年 longxdragon. All rights reserved.
//

#import "ViewController.h"
#import "DDRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)jump:(id)sender {
    BOOL islogin = YES;
    [[DDRouter shareRouter] openUrl:@"gkoudai://a/avc" toHandle:^(UIViewController *viewController) {
        if (islogin) {
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没登陆，请先登陆？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
}

@end
