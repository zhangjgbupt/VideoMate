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
#import "WXApi.h"

/// 个推开发者网站中申请App时注册的AppId、AppKey、AppSecret
#define kGtAppId           @"slEp4JgV6e9HwYdXBRVEK9"
#define kGtAppKey          @"mY9tyJfgfQ9yeUFIacGFe4"
#define kGtAppSecret       @"s5zkkTB5rz7aYCRgMdWGD6"


@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL shouldRotate;

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) RDVTabBarController *tabBarController;

@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* svrAddr;
@property (nonatomic, retain) NSString* accessToken;
@property (nonatomic, retain) NSString* expireTimer;
@property (nonatomic, retain) NSString* apnsClientId;
@property (nonatomic, retain) NSTimer* heartBeatTimer;
@property (nonatomic, retain) UIAlertController* alertView;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIViewController* mediaViewController;
@property (strong, nonatomic) UIViewController* channelViewController;
@property (strong, nonatomic) UIViewController* settingViewController;
@property (strong, nonatomic) UIViewController* liveViewController;

//-1: init
//0: login fail
//1: login success
@property int isLoginSuccessful;
@property Boolean isAnonymous;

- (void)saveContext;
- (void)loginRestApi;
- (void)setupTabViewControllers;
- (NSURL *)applicationDocumentsDirectory;
- (void) startNetworkConnectionMonitor;
- (void) register2apns;


@end

