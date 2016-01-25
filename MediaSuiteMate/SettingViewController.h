//
//  SettingViewController.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>

@interface SettingViewController : UIViewController <SKStoreProductViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *logoutBtn, *mark, *about;
@property (strong, nonatomic) IBOutlet UILabel *serverLabel, *serverTitle, *seperator1, *seperator2, *desLabel, *versionTitle, *seperator3, *seperator4, *seperator5, *seperator6;

@property Boolean isLogin;

@end
