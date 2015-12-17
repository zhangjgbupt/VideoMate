//
//  SettingViewController.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;
@property (strong, nonatomic) IBOutlet UILabel *appName;
@property (strong, nonatomic) IBOutlet UILabel *serverAddress;
//@property (strong, nonatomic) IBOutlet UIImageView *setttingAnimationImgView;
@property (strong, nonatomic) IBOutlet UIImageView *appicon;

- (IBAction)doLogout:(id)sender;
@end
