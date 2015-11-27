//
//  SettingViewController.m
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize setttingAnimationImgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.topViewController.title = NSLocalizedString(@"setting_page_title", nil);
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    setttingAnimationImgView.animationImages = [NSArray arrayWithObjects:
                                                [UIImage imageNamed:@"image_setting01"],
                                                [UIImage imageNamed:@"image_setting02"],
                                                [UIImage imageNamed:@"image_setting03"],
                                                nil];
    setttingAnimationImgView.animationDuration = 0.5f;
    setttingAnimationImgView.animationRepeatCount = 0;
    [setttingAnimationImgView startAnimating];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat logout_x = 30;
    CGFloat logout_y = screenHeight - 150;
    CGFloat logout_w = screenWidth - 60;
    CGFloat logout_h = 50;
    [self.logoutBtn setFrame:CGRectMake(logout_x, logout_y, logout_w, logout_h)];
    
    [self.logoutBtn setTitle:NSLocalizedString(@"sign_out_title", nil) forState:UIControlStateNormal];
    [self.logoutBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_normal"] forState:UIControlStateNormal];
    //[self.logoutBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_pressed"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate startNetworkConnectionMonitor];
    [appDelegate.tabBarController setTabBarHidden:NO];
    [super viewWillAppear:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doLogout:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableArray *childViewControllers = [[NSMutableArray alloc] initWithArray: appDelegate.tabBarController.navigationController.viewControllers];
    if ([[childViewControllers objectAtIndex:0] isKindOfClass:[LoginViewController class]]) {
        [appDelegate.navController popToRootViewControllerAnimated:YES];
    } else {
        LoginViewController* loginViewController = [[LoginViewController alloc]init];
        [childViewControllers insertObject:loginViewController atIndex:0];
        appDelegate.navController.viewControllers = childViewControllers;
        [appDelegate.navController popToRootViewControllerAnimated:YES];
    }
}
@end
