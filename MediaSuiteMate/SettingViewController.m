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
#import "SettingLabel.h"

@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize isLogin;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.topViewController.title = NSLocalizedString(@"setting_page_title", nil);
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:240.0/255];
    [appDelegate setShouldRotate:NO];
    isLogin = !appDelegate.isAnonymous;
    
//    setttingAnimationImgView.animationImages = [NSArray arrayWithObjects:
//                                                [UIImage imageNamed:@"image_setting01"],
//                                                [UIImage imageNamed:@"image_setting02"],
//                                                [UIImage imageNamed:@"image_setting03"],
//                                                nil];
//    setttingAnimationImgView.animationDuration = 0.5f;
//    setttingAnimationImgView.animationRepeatCount = 0;
//    [setttingAnimationImgView startAnimating];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // add login button
    UIButton *loginBtn = [[UIButton alloc] init];
    loginBtn.frame = CGRectMake(0, 74, screenWidth, 74);
    [loginBtn setBackgroundColor:[UIColor whiteColor]];
    [loginBtn setImage:[UIImage imageNamed:@"setting_login.png"] forState:UIControlStateNormal];
    
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [loginBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [loginBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    [loginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 23, 0, 0)];
    if (appDelegate.isAnonymous) {
        [loginBtn setTitle:@"点击登录" forState:UIControlStateNormal];
        [loginBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 23, 20, 0)];
        UILabel *tips = [[UILabel alloc] init];
        tips.text =@"登录后可使用更多功能";
        tips.font = [UIFont systemFontOfSize:11.0];
        tips.textColor = [UIColor colorWithRed:139.0/255 green:139.0/255 blue:139.0/255 alpha:1];
        tips.frame = CGRectMake(13 + 40 + 10, 74/2, 300, 20);
        [loginBtn addSubview: tips];
    } else {
        [loginBtn setTitle:appDelegate.userName forState:UIControlStateNormal];
        loginBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    }
   

    
    // is important
    self.view.userInteractionEnabled = YES;
    
    [loginBtn addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.frame = CGRectMake(screenWidth - 30, 74/2 - 5, 10, 10);
    [arrow setImage:[UIImage imageNamed:@"icon_arrow"]];
    [loginBtn addSubview:arrow];
    [self.view addSubview:loginBtn];

    CGFloat seperator1_y = 74 + 74;
    CGFloat seperator1_h = 1;
    self.seperator1.frame = CGRectMake(0, seperator1_y, screenWidth, seperator1_h);
    
    // add server title
    CGFloat serverLabel_y = seperator1_h + seperator1_y;
    CGFloat serverLabel_h = 40;
    self.serverLabel.frame = CGRectMake(13, serverLabel_y, screenWidth, serverLabel_h);

    // add server info
    CGFloat serverTitle_y = serverLabel_y + serverLabel_h;
    CGFloat serverTitle_h = 49;
    self.serverTitle.frame = CGRectMake(0, serverTitle_y, screenWidth/2, serverTitle_h);
    
    SettingLabel *serverAddress = [[SettingLabel alloc] init];
    serverAddress.frame = CGRectMake(screenWidth/2, serverTitle_y, screenWidth/2, serverTitle_h);
    [serverAddress setText:appDelegate.svrAddr];
    [serverAddress setInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
    [serverAddress setTextColor:[UIColor colorWithRed:139.0/255 green:139.0/255 blue:139.0/255 alpha:1]];
    [serverAddress setFont:[UIFont systemFontOfSize:14.0]];
    [serverAddress setBackgroundColor:[UIColor whiteColor]];
    [serverAddress setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:serverAddress];
    
    CGFloat seperator2_y = serverTitle_y + serverTitle_h;
    CGFloat seperator2_h = 1;
    self.seperator2.frame = CGRectMake(0, seperator2_y, screenWidth, seperator2_h);
    
    // add description
    CGFloat desLabel_y = seperator2_h + seperator2_y;
    CGFloat desLabel_h = 40;
    self.desLabel.frame = CGRectMake(13, desLabel_y, screenWidth, desLabel_h);

    CGFloat version_y = desLabel_y + desLabel_h;
    CGFloat version_h = 49;
    self.versionTitle.frame = CGRectMake(0, version_y, screenWidth/2, version_h);
    
    SettingLabel *version = [[SettingLabel alloc] init];
    version.frame = CGRectMake(screenWidth/2, version_y, screenWidth/2, version_h);
    [version setInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
    [version setTextColor:[UIColor colorWithRed:139.0/255 green:139.0/255 blue:139.0/255 alpha:1]];
    [version setText:@"已更新到最新版本"];
    [version setFont:[UIFont systemFontOfSize:14.0]];
    [version setBackgroundColor:[UIColor whiteColor]];
    [version setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:version];

    CGFloat seperator3_y = version_y + version_h;
    CGFloat seperator3_h = 1;
    self.seperator3.frame = CGRectMake(0, seperator3_y, screenWidth, seperator3_h);
    
    CGFloat mark_y = seperator3_y + seperator3_h;
    CGFloat mark_h = 49;
    self.mark.frame = CGRectMake(0, mark_y, screenWidth, mark_h);
    [self.mark setTitle:@"给汇视通打分" forState:UIControlStateNormal];
    [self.mark setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.mark setTitleEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    UIImageView *arrow1 = [[UIImageView alloc] init];
    [arrow1 setImage:[UIImage imageNamed:@"icon_arrow"]];
    arrow1.frame = CGRectMake(screenWidth - 30, 50/2 - 5, 10, 10);
    
    [self.mark addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
    [self.mark addSubview:arrow1];

    CGFloat seperator4_y = mark_y + mark_h;
    CGFloat seperator4_h = 1;
    self.seperator4.frame = CGRectMake(0, seperator4_y, screenWidth, seperator4_h);

    CGFloat about_y = seperator4_y + seperator4_h;
    CGFloat about_h = 49;
    self.about.frame = CGRectMake(0, about_y, screenWidth, about_h);
    [self.about setTitle:@"关于" forState:UIControlStateNormal];
    [self.about setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.about setTitleEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    UIImageView *arrow2 = [[UIImageView alloc] init];
    [arrow2 setImage:[UIImage imageNamed:@"icon_arrow"]];
    arrow2.frame = CGRectMake(screenWidth - 30, 50/2 - 5, 10, 10);
    [self.about addSubview:arrow2];
    
    CGFloat seperator5_y = about_y + about_h;
    CGFloat seperator5_h = 1;
    self.seperator5.frame = CGRectMake(0, seperator5_y, screenWidth, seperator5_h);
    
    // logout button
    CGFloat logout_y = screenHeight - 170;
    CGFloat logout_h = 49;
    self.logoutBtn.frame = CGRectMake(0, logout_y, screenWidth, logout_h);
    [self.logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];

    CGFloat seperator6_y = logout_y + logout_h;
    CGFloat seperator6_h = 1;
    self.seperator6.frame = CGRectMake(0, seperator6_y, screenWidth, seperator6_h);
    
    if (!self.isLogin) {
        [self.logoutBtn setHidden:YES];
        [self.seperator6 setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate startNetworkConnectionMonitor];
    [appDelegate setShouldRotate:NO];
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

-(void)doLogin {
    if (!isLogin) {
        [self doLogout];
    }
}

- (IBAction)doLogout {
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

- (void)evaluate{
    
    //初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    //加载一个新的视图展示
    [storeProductViewContorller loadProductWithParameters:
     //appId唯一的
     @{SKStoreProductParameterITunesItemIdentifier : @"1055310874"} completionBlock:^(BOOL result, NSError *error) {
         //block回调
         if(error){
             NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
         }else{
             //模态弹出appstore
             [self presentViewController:storeProductViewContorller animated:YES completion:^{
                 
             }
              ];
         }
     }];
}

//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
