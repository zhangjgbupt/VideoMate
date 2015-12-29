//
//  AppDelegate.m
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "AppDelegate.h"

#import "SettingViewController.h"
#import "ChannelCollectionViewController.h"
#import "MyMediaViewController.h"
#import "LiveViewController.h"
#import "LoginViewController.h"
#import "CustomerUINavigationController.h"
#import "GlobalData.h"

//＝＝＝＝＝＝＝＝＝＝ShareSDK头文件＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"
//新浪微博SDK头文件
#import "WeiboSDK.h"


#import <MOBFoundation/MOBFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize navController;
@synthesize tabBarController, channelViewController, mediaViewController, settingViewController, liveViewController;
@synthesize userName, password, svrAddr, apnsClientId;
@synthesize accessToken, expireTimer, heartBeatTimer;
@synthesize alertView;
@synthesize isLoginSuccessful;
@synthesize isAnonymous;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    isLoginSuccessful = -1;
    apnsClientId = nil;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //setup viewcontroller:
    //1. if never login, first go to login page.
    //2. if login before, just login automaticly, and go to main page.
    [self setupViewControllers];
    
    self.navController = [[CustomerUINavigationController alloc] initWithRootViewController:self.viewController];
    self.navController.navigationBar.hidden = YES;
    
    //set the color for navigation bar background to red.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:221.0f/255.0f green:77.0f/255.0f blue:53.0f/255.0f alpha:1.0f]];
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    //[self customizeInterface];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkLostAlert)
                                                 name:@"NETWORK_LOST"
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loginSuccess)
//                                                 name:@"LOGIN_SUCCESS"
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loginFail)
//                                                 name:@"LOGIN_FAIL"
//                                               object:nil];
    
    [self startNetworkConnectionMonitor];
    
    
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    
    // 注册APNS
    [self registerUserNotification];
    
    // 处理远程通知启动APP
    [self receiveNotificationByLaunchingOptions:launchOptions];
    
//    if (![WXApi registerApp:@"wxd83e3fe2fa3784ea"]) {
//        NSLog(@"Failed to register with Weixin!");
//    }
    
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:@"chrisios"
          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeTencentWeibo),
                            @(SSDKPlatformTypeMail),
                            @(SSDKPlatformTypeSMS),
                            @(SSDKPlatformTypeCopy),
                            @(SSDKPlatformTypeFacebook),
                            @(SSDKPlatformTypeTwitter),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                              redirectUri:@"http://www.sharesdk.cn"
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeTencentWeibo:
                      //设置腾讯微博应用信息
                      [appInfo SSDKSetupTencentWeiboByAppKey:@"801307650"
                                                   appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                                 redirectUri:@"http://www.sharesdk.cn"];
                      break;
                  case SSDKPlatformTypeWechat:
                      //设置微信应用信息
                      [appInfo SSDKSetupWeChatByAppId:@"wxd83e3fe2fa3784ea"
                                            appSecret:@"9e42072688302fd8da1d7a17f6a86413"];
                      break;
                  case SSDKPlatformTypeQQ:
                      //设置QQ应用信息，其中authType设置为只用SSO形式授权
                      [appInfo SSDKSetupQQByAppId:@"100371282"
                                           appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                         authType:SSDKAuthTypeSSO];
                      break;
                  default:
                      break;
              }
          }];

    return YES;
}

-(void) loginSuccess {
    self.viewController = tabBarController;
    [self.window makeKeyAndVisible];
}

-(void) loginFail {
    LoginViewController* loginViewController = [[LoginViewController alloc] init];
    self.viewController = loginViewController;
    [self.window makeKeyAndVisible];
}

#pragma mark - Methods

- (void)setupTabViewControllers {
    SettingViewController* mySettingViewController = [[SettingViewController alloc]init];
    MyMediaViewController* myMediaViewController = [[MyMediaViewController alloc]init];
    LiveViewController* myLiveViewController = [[LiveViewController alloc]init];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 1;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    ChannelCollectionViewController *myChannelListViewController = [[ChannelCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    //set the text color for navigation bar to white color
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    UIColor* barTintColor = [UIColor colorWithRed:221.0f/255.0f green:77.0f/255.0f blue:53.0f/255.0f alpha:1.0f];

    
    UINavigationController *myMediaNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:myMediaViewController];
    UINavigationController *myChannelNavigationController = [[UINavigationController alloc]
                                                     initWithRootViewController:myChannelListViewController];
    UINavigationController *mySettingNavigationController = [[UINavigationController alloc]
                                                     initWithRootViewController:mySettingViewController];
    UINavigationController *myLiveNavigationController = [[UINavigationController alloc] initWithRootViewController:myLiveViewController];
    
    
    myMediaNavigationController.navigationBar.titleTextAttributes = textAttributes;
    myChannelNavigationController.navigationBar.titleTextAttributes = textAttributes;
    mySettingNavigationController.navigationBar.titleTextAttributes = textAttributes;
    myLiveNavigationController.navigationBar.titleTextAttributes = textAttributes;
    
    [myMediaNavigationController.navigationBar setBarTintColor:barTintColor];
    [myChannelNavigationController.navigationBar setBarTintColor:barTintColor];
    [mySettingNavigationController.navigationBar setBarTintColor:barTintColor];
    [myLiveNavigationController.navigationBar setBarTintColor:barTintColor];

    
    [myMediaNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [myChannelNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [mySettingNavigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [myLiveNavigationController.navigationBar setTintColor:[UIColor whiteColor]];

    self.mediaViewController = myMediaViewController;
    self.channelViewController = myChannelListViewController;
    self.settingViewController = mySettingViewController;
    self.liveViewController = myLiveNavigationController;

    
    tabBarController = [[RDVTabBarController alloc] init];
    //[tabBarController setViewControllers:@[myMediaViewController, channelListViewController,settingViewController]];
    if (self.isAnonymous) {
        [tabBarController setViewControllers:@[myChannelNavigationController, mySettingNavigationController]];
    } else {
        [tabBarController setViewControllers:@[myChannelNavigationController, myLiveNavigationController, myMediaNavigationController,mySettingNavigationController]];
    }
    [self customizeTabBarForController:tabBarController];
}

- (void)setupViewControllers {
    //here need check if configuration exist:
    // 1. if Yes, just go to main page.
    // 2. if No, go to login page.
    if ([self isUserInfoFileExist]) {
        //login to system.
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self loginRestApi];
//        });
        [self loginRestApi];
//        while (self.isLoginSuccessful == -1) {
//            NSLog(@"Login not return!");
//        }
        
        if (self.isLoginSuccessful == 1 || self.isAnonymous) {
            [self setupTabViewControllers];
            self.viewController = self.tabBarController;
        } else {
            LoginViewController* loginViewController = [[LoginViewController alloc] init];
            self.viewController = loginViewController;
        }
        
    } else {
        self.isLoginSuccessful = -1;
        LoginViewController* loginViewController = [[LoginViewController alloc] init];
        self.viewController = loginViewController;
    }  
}


- (void)customizeTabBarForController:(RDVTabBarController *)tabbarController {
    //UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    //UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages, *tabBarItemTexts;
    
    if (self.isAnonymous) {
        tabBarItemImages = @[@"icon_channel", @"icon_setting"];
        tabBarItemTexts = @[NSLocalizedString(@"icon_channel_text", nil),NSLocalizedString(@"icon_setting_text", nil)];
    } else {
        tabBarItemImages = @[@"icon_channel", @"icon_live", @"icon_mymedia", @"icon_setting"];
        tabBarItemTexts = @[NSLocalizedString(@"icon_channel_text", nil),NSLocalizedString(@"icon_live_text", nil),NSLocalizedString(@"icon_mymedia_text", nil),NSLocalizedString(@"icon_setting_text", nil)];
    }
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabbarController tabBar] items]) {
        //[item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_pressed",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        [item setTitle:tabBarItemTexts[index]];
        
        index++;
    }
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}

- (BOOL)isUserInfoFileExist {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"user_info.plist"];
    NSLog(@"Plist File Path: %@", filePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

- (void)readUserInfo {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"user_info.plist"];
    NSLog(@"Plist File Path: %@", filePath);
    
    // Step2: Define mutable dictionary
    
    NSMutableDictionary *plistDict;
    
    // Step3: Check if file exists at path and read data from the file if exists
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    else
    {
        // Step4: If doesn't exist, start with an empty dictionary
        plistDict = [[NSMutableDictionary alloc] init];
    }
    
    //NSLog(@"plist data: %@", [plistDict description]);
    
    // Step5: Set data in dictionary
    GlobalData* globalData = [GlobalData getInstance];
    svrAddr = [plistDict objectForKey:globalData.SERVER_ADDRESS_KEY];
    userName = [plistDict objectForKey:globalData.USER_NAME_KEY];
    password = [plistDict objectForKey:globalData.PASSWORD_KEY];
}

#pragma mark - restApi Implementation

//- (void) setupOperationMgr {
//    [self readUserInfo];
//    self.baseUriString = [NSString stringWithFormat:@"http://%@:80/msc/rest/", self.svrAddr];
//    NSURL *baseUrl = [NSURL URLWithString:self.baseUriString];
//    
//    self.operationMgr = [[AFHTTPRequestOperationManager manager] initWithBaseURL:baseUrl];
//    self.operationMgr.securityPolicy.allowInvalidCertificates = YES;
//    self.operationMgr.securityPolicy.validatesDomainName = NO;
//    self.operationMgr.responseSerializer = [AFJSONResponseSerializer serializer];
//    self.operationMgr.requestSerializer = [AFJSONRequestSerializer serializer];
//    self.operationMgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-csc+json"];
//    [self.operationMgr.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Accept"];
//    [self.operationMgr.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Content-Type"];
//
//}


- (void) loginRestApi {
    
    [self readUserInfo];
    
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/msc/rest/accessToken", self.svrAddr];
    NSDictionary *body = @{ @"userName" : self.userName,
                            @"password" : self.password };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-csc+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Content-Type"];
    
    //dispatch_queue_t myQueue = dispatch_queue_create("com.CompanyName.AppName.methodTest", DISPATCH_QUEUE_SERIAL);
    //[manager setCompletionQueue:myQueue];
    
    [manager POST:requestStr parameters:body
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       NSLog(@"token: %@)", [responseObject valueForKey:@"token"]);
                       self.accessToken =[responseObject valueForKey:@"token"];
                       self.expireTimer = [responseObject valueForKey:@"expiresIn"];
                       [self startScheduleHeartBeat:expireTimer];
                       self.isLoginSuccessful = 1;
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_SUCCESS" object:nil];
                   }
                   failure:^(AFHTTPRequestOperation* task, NSError* error){
                       NSLog(@"Error: %@", error.description);
                       self.isLoginSuccessful = 0;
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_FAIL" object:nil];
                       
                   }];
}

- (void) register2apns {

    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/users/regToApns", self.svrAddr];
    NSDictionary *body = @{ @"userName" : self.userName,
                            @"clientId" : self.apnsClientId,
                        };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-csc+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:requestStr parameters:body
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"success");
          }
          failure:^(AFHTTPRequestOperation* task, NSError* error){
              NSLog(@"Error: %@", error.description);
          }];
}


- (void) startScheduleHeartBeat:(NSString*)interval {
    [self heartbeatRestApi];
    double timeInterval = [interval doubleValue] * 60 * 8/10;
    heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(heartbeatRestApi) userInfo:nil repeats:YES];
}

- (void) heartbeatRestApi {
    NSLog(@"HeartBeat invoked!");
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@:80/api/rest/util/heartbeat", self.svrAddr];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-util+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-util+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-util+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:self.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager POST:requestStr parameters:nil
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       NSLog(@"token: %@)", [responseObject valueForKey:@"token"]);
                   }
                   failure:^(AFHTTPRequestOperation* task, NSError* error){
                       NSLog(@"HeartBeat Failed!");
                       NSLog(@"Error: %@", error.description);
                   }];
}

- (void) startNetworkConnectionMonitor {
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // WiFi
     */
    
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"-----网络状态----%ld", status);
        if(status ==  AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NETWORK_LOST" object:nil];
        }
    }];
}


- (void)networkLostAlert {
    
    alertView =   [UIAlertController
                   alertControllerWithTitle:nil
                   message:NSLocalizedString(@"network_error_msg", nil)
                   preferredStyle:UIAlertControllerStyleAlert];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(dismissAlertView:)
                                   userInfo:nil
                                    repeats:NO];

    if (self.mediaViewController.isViewLoaded && self.mediaViewController.view.window) {
        [self.mediaViewController presentViewController:alertView animated:YES completion:nil];
        
    } else if(self.channelViewController.isViewLoaded && self.channelViewController.view.window) {
        [self.channelViewController presentViewController:alertView animated:YES completion:nil];
        
    } else if(self.settingViewController.isViewLoaded && self.settingViewController.view.window) {
        [self.settingViewController presentViewController:alertView animated:YES completion:nil];
        
    }
}

- (void)dismissAlertView:(NSTimer*)timer {
    NSLog(@"Dismiss alert view");
    [alertView dismissViewControllerAnimated:YES completion:nil];
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//- (BOOL)application:(UIApplication*)application handleOpenURL:(nonnull NSURL *)url {
//    return [WXApi handleOpenURL:url delegate:self];
//}
//
//- (BOOL)application:(UIApplication*)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
//    return [WXApi handleOpenURL:url delegate:self];
//}

//#pragma Weixin delegate
//- (void) onReq:(BaseReq *)req {
//    NSLog(@"on Request");
//}
//
//- (void) onResp:(BaseResp *)resp {
//    NSLog(@"on Response");
//}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.derek.MediaSuiteMate" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MediaSuiteMate" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MediaSuiteMate.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - GeTuiSdkDelegate

/** 注册用户通知 */
- (void)registerUserNotification {
    
    /*
     注册通知(推送)
     申请App需要接受来自服务商提供推送消息
     */
    
    // 判读系统版本是否是“iOS 8.0”以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ||
        [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        
        // 定义用户通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        // 注册用户通知 - 根据用户通知设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else {      // iOS8.0 以前远程推送设置方式
        // 定义远程通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        
        // 注册远程通知 -根据远程通知类型
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}

/** 自定义：APP被“推送”启动时处理推送消息处理（APP 未启动--》启动）*/
- (void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions {
    if (!launchOptions) return;
    
    /*
     通过“远程推送”启动APP
     UIApplicationLaunchOptionsRemoteNotificationKey 远程推送Key
     */
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"\n>>>[Launching RemoteNotification]:%@",userInfo);
    }
}

#pragma mark - 用户通知(推送)回调 _IOS 8.0以上使用

/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [GeTuiSdk registerDeviceToken:myToken];
    
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n",myToken);
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [GeTuiSdk registerDeviceToken:@""];
    
    NSLog(@"\n>>>[DeviceToken Error]:%@\n\n",error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;        // 标签
    
    NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    // 处理APN
    NSLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n",userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    apnsClientId = clientId;
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_CLIENT_ID_SUCCESS" object:nil];
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes length:payload.length encoding:NSUTF8StringEncoding];
    }
    
    NSString *msg = [NSString stringWithFormat:@" payloadId=%@,taskId=%@,messageId:%@,payloadMsg:%@%@",payloadId,taskId,aMsgId,payloadMsg,offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    NSLog(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n",msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    NSLog(@"\n>>>[GexinSdk SdkState]:%u\n\n",aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n",[error localizedDescription]);
        return;
    }
    
    NSLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n",isModeOff?@"开启":@"关闭");
}

@end
