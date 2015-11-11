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
#import "LoginViewController.h"
#import "CustomerUINavigationController.h"
#import "GlobalData.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize navController;
@synthesize tabBarController;
@synthesize userName, password, svrAddr;
@synthesize accessToken, expireTimer, heartBeatTimer;
@synthesize alertView;
@synthesize isLoginSuccessful;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    isLoginSuccessful = -1;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //setup viewcontroller:
    //1. if never login, first go to login page.
    //2. if login before, just login automaticly, and go to main page.
    [self setupViewControllers];
    
    self.navController = [[CustomerUINavigationController alloc] initWithRootViewController:self.viewController];
    
    //set the text color for navigation bar to white color
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navController.navigationBar.titleTextAttributes = textAttributes;
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //set the color for navigation bar background to red.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:221.0f/255.0f green:77.0f/255.0f blue:53.0f/255.0f alpha:1.0f]];
    //[[UINavigationBar appearance] setTranslucent:NO];
    
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
    SettingViewController* settingViewController = [[SettingViewController alloc]init];
    MyMediaViewController* myMediaViewController = [[MyMediaViewController alloc]init];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    ChannelCollectionViewController *channelListViewController = [[ChannelCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[myMediaViewController, channelListViewController,settingViewController]];
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
        
        if (self.isLoginSuccessful == 1) {
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


- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"icon_mymedia", @"icon_channel", @"icon_setting"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        //[item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_pressed",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
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
                                  message:@"Network connection lost, please check you network reachability."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    
//    alertView = [[UIAlertView alloc] initWithTitle:nil
//                                           message:@"Network connection lost, please check you network reachability!"
//                                          delegate:nil
//                                 cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(dismissAlertView:)
                                   userInfo:nil
                                    repeats:NO];
    [self.viewController presentViewController:alertView animated:YES completion:nil];
    //[alertView show];
}

- (void)dismissAlertView:(NSTimer*)timer {
    NSLog(@"Dismiss alert view");
    [alertView dismissViewControllerAnimated:YES completion:nil];
    //[alertView dismissWithClickedButtonIndex:0 animated:YES];
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  // iOS 6 autorotation fix
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

@end
