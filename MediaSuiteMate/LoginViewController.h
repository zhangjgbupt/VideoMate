//
//  LoginViewController.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *userNameText;

@property (strong, nonatomic) IBOutlet UILabel *passwordLabel;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;

@property (strong, nonatomic) IBOutlet UILabel *serverAddrLabel;
@property (strong, nonatomic) IBOutlet UITextField *serverAddrText;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIImageView *appiconImag;
@property (strong, nonatomic) IBOutlet UIButton *anonymousBtn;
@property (strong, nonatomic) AppDelegate* appDelegate;

- (IBAction)doLogin:(id)sender;
@end
