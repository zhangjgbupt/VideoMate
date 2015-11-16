//
//  AppDelegate.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"//af里面监听网络状态的类
#import "AFHTTPRequestOperation.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "GlobalMacroDefine.h"
#import "GeTuiSdk.h"

/// 个推开发者网站中申请App时注册的AppId、AppKey、AppSecret
#define kGtAppId           @"zW5idAIl9R7Q8Lda9Lav89"
#define kGtAppKey          @"2pJIB7o8GK686qmAXSgQR8"
#define kGtAppSecret       @"HZwEpyzG9GA0l98L698Pa7"


@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) RDVTabBarController *tabBarController;

@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* svrAddr;
@property (nonatomic, retain) NSString* accessToken;
@property (nonatomic, retain) NSString* expireTimer;
@property (nonatomic, retain) NSTimer* heartBeatTimer;
@property (nonatomic, retain) UIAlertController* alertView;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//-1: init
//0: login fail
//1: login success
@property int isLoginSuccessful;

- (void)saveContext;
- (void)loginRestApi;
- (void)setupTabViewControllers;
- (NSURL *)applicationDocumentsDirectory;
- (void) startNetworkConnectionMonitor;


@end

