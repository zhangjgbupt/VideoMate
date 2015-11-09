//
//  LoginViewController.m
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "LoginViewController.h"
#import "GlobalData.h"
#import "GlobalMacroDefine.h"
#import "SettingViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userNameText, passwordText, serverAddrText, loginBtn;
@synthesize activityIndicatorView;
@synthesize appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    
    [activityIndicatorView setHidden:YES];
    [activityIndicatorView setHidesWhenStopped:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.userNameText setPlaceholder:NSLocalizedString(@"user_name", nil)];
    [self.passwordText setPlaceholder:NSLocalizedString(@"user_password", nil)];
    [self.serverAddrText setPlaceholder:NSLocalizedString(@"server_address", nil)];
    
    [self.loginBtn setTitle:NSLocalizedString(@"login_btn_text", nil) forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_normal"] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_pressed"] forState:UIControlStateSelected];
    
    self.serverAddrText.delegate=self;
    self.userNameText.delegate=self;
    self.passwordText.delegate=self;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat appicon_x = (screenWidth - self.appiconImag.frame.size.width)/2;
    CGFloat appicon_y = 40;
    CGFloat appicon_w = self.appiconImag.frame.size.width;
    CGFloat appicon_h = self.appiconImag.frame.size.height;
    [self.appiconImag setFrame:CGRectMake(appicon_x, appicon_y, appicon_w, appicon_h)];
    
    CGFloat login_x = 30;
    CGFloat login_y = screenHeight - 160;
    CGFloat login_w = screenWidth - 60;
    CGFloat login_h = 50;
    [self.loginBtn setFrame:CGRectMake(login_x, login_y, login_w, login_h)];

    
    if ([self isUserInfoFileExist]) {
        [self readUserInfo];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLoginSuccess)
                                                 name:@"LOGIN_SUCCESS"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLoginFail)
                                                 name:@"LOGIN_FAIL"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doLogin:(id)sender {
    
    NSString* userName = userNameText.text;
    NSString* password = passwordText.text;
    NSString* serverAddr = serverAddrText.text;
    if (userName.length==0 || password.length == 0 || serverAddr.length == 0) {
        [self popAlertDlg];
        return;
    }
    
    NSLog(@"username:%@, password:%@, serverAddr:%@", userName, password, serverAddr);
    [self saveSetting];
    
    [activityIndicatorView setHidden:NO];
    [activityIndicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [appDelegate loginRestApi];
    });
}

- (IBAction)backgroundTap:(id)sender
{
//    [userNameText resignFirstResponder];
//    [passwordText resignFirstResponder];
//    [serverAddrText resignFirstResponder];
    [self.view endEditing:YES];
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
    
    NSLog(@"plist data: %@", [plistDict description]);
    
    // Step5: Set data in dictionary
    GlobalData* globalData = [GlobalData getInstance];
    self.serverAddrText.text = [plistDict objectForKey:globalData.SERVER_ADDRESS_KEY];
    self.userNameText.text = [plistDict objectForKey:globalData.USER_NAME_KEY];
    self.passwordText.text = [plistDict objectForKey:globalData.PASSWORD_KEY];
}

//if login successful, need save login info to configuration file.
//if login fail, just ignore the login info.
- (void)saveSetting {
    
    // Step1: Get plist file path
    
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
    
    NSLog(@"user info plist data: %@", [plistDict description]);
    
    // Step5: Set data in dictionary
    NSString* name = userNameText.text;
    NSString* pass = passwordText.text;
    NSString* serverAddr = serverAddrText.text;
    
    [plistDict removeAllObjects];
    
    GlobalData* globalData = [GlobalData getInstance];
    [plistDict setObject:serverAddr forKey:globalData.SERVER_ADDRESS_KEY ];
    [plistDict setObject:name forKey:globalData.USER_NAME_KEY];
    [plistDict setObject:pass forKey:globalData.PASSWORD_KEY];
    
    NSLog(@"Save MediaSuite Addr:%@", serverAddr);
    NSLog(@"Save UserName: %@", name);
    NSLog(@"Save Password: %@", pass);
    
    // Step6: Write data from the mutable dictionary to the plist file
    
    BOOL didWriteToFile = [plistDict writeToFile:filePath atomically:YES];
    
    if (didWriteToFile)
    {
        NSLog(@"Write to .plist file is a SUCCESS!");
    }
    else
    {
        NSLog(@"Write to .plist file is a FAILURE!");
    }
}

- (void)popAlertDlg {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error:"
                                  message:@"You must input valid value for username, password and server adddress."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) onLoginSuccess {
    NSLog(@"Login success!");
    [activityIndicatorView stopAnimating];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [appDelegate setupTabViewControllers];
    [self.navigationController pushViewController:appDelegate.tabBarController animated:YES];
}

- (void) onLoginFail {
    NSLog(@"Login fail!");
    [activityIndicatorView stopAnimating];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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

@end
