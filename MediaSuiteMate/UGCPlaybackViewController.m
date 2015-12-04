//
//  UGCPlaybackViewController.m
//  MediaSuite Mate
//
//  Created by Zhang Derek on 10/24/15.
//  Copyright (c) 2015 Polycom. All rights reserved.
//

#import "UGCPlaybackViewController.h"
#import "ChannelData.h"
#import "Utils.h"

@interface UGCPlaybackViewController ()

@end

@implementation UGCPlaybackViewController
@synthesize videoController, videoURL, ugcArchiveData;
@synthesize uploadMediaFilesHandle;
@synthesize textMediaFileName, textDescription,progressView, placeholderLabel;
@synthesize channelNameList,channelListNameAndIdDict,channelDropListView,channelSelected;
@synthesize seperator_1, seperator_2;
@synthesize appDelegate;
@synthesize original_y_center;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.channelNameList = [[NSMutableArray alloc]init];
    self.channelListNameAndIdDict = [[NSMutableDictionary alloc] init];
    self.textMediaFileName.delegate = self;
    self.textDescription.delegate = self;
    self.videoController = [[MPMoviePlayerController alloc] init];
    self.uploadMediaFilesHandle = [[UploadMediaFiles alloc] init];
    self.ugcArchiveData = [[ArchiveData alloc]init];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat player_x = 0;
    CGFloat player_y = self.navigationController.navigationBar.frame.size.height;
    CGFloat player_w = screenWidth;
    CGFloat player_h = screenWidth*9/16;
    
    [self.videoController setContentURL:self.videoURL];
    [self.videoController.view setFrame:CGRectMake (player_x, player_y, player_w, player_h)];
    [self.view addSubview:self.videoController.view];
    [self.videoController play];

    CGFloat progress_x = player_x;
    CGFloat progress_y = player_y+player_h+5;
    CGRect frame = CGRectMake(progress_x, progress_y, screenWidth, 5);
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.progressView setFrame:frame];
    [self.view addSubview:self.progressView];
    [self.progressView setHidden:YES];
    self.progressView.progressTintColor = [UIColor colorWithRed:93.0f/255.0f green:177.0f/255.0f blue:1.0f alpha:1.0f];
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 5.0)];
    
    CGFloat title_x = 5;
    CGFloat title_y = progress_y + 16;
    CGFloat title_w = player_w-10;
    CGFloat title_h = 40;
    [self.textMediaFileName setFrame:CGRectMake(title_x, title_y, title_w, title_h)];
    [self.textMediaFileName setPlaceholder:NSLocalizedString(@"file_name_label_title", nil)];
    
    CGFloat seperator_1_x = 0;
    CGFloat seperator_1_y = title_y + title_h;
    CGFloat seperator_1_w = screenWidth;
    CGFloat seperator_1_h = 5;
    [self.seperator_1 setFrame:CGRectMake(seperator_1_x, seperator_1_y, seperator_1_w, seperator_1_h)];
    
    CGFloat channel_x = title_x;
    CGFloat channel_y = seperator_1_y+seperator_1_h;
    CGFloat channel_w = title_w;
    CGFloat channel_h = title_h;
    [self.btnChannelList setFrame:CGRectMake(channel_x, channel_y, channel_w, channel_h)];
    [self.btnChannelList setTitle:NSLocalizedString(@"channel_label_title", nil) forState:UIControlStateNormal];
    
    CGFloat seperator_2_x = 0;
    CGFloat seperator_2_y = channel_y + channel_h;
    CGFloat seperator_2_w = screenWidth;
    CGFloat seperator_2_h = 5;
    [self.seperator_2 setFrame:CGRectMake(seperator_2_x, seperator_2_y, seperator_2_w, seperator_2_h)];
    
    CGFloat description_x = title_x;
    CGFloat description_y = seperator_2_y + seperator_2_h;
    CGFloat description_w = title_w;
    CGFloat description_h = 80;
    [self.textDescription setFrame:CGRectMake(description_x, description_y, description_w, description_h)];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.textDescription.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:NSLocalizedString(@"description_label_title", nil)];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [placeholderLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.textDescription addSubview:placeholderLabel];
    
    CGFloat upload_x = 40;
    CGFloat upload_y = screenHeight - 150;
    CGFloat upload_w = screenWidth - 80;
    CGFloat upload_h = 40;
    [self.btnUpload setFrame:CGRectMake(upload_x, upload_y, upload_w, upload_h)];
    [self.btnUpload setTitle:NSLocalizedString(@"upload_btn_title", nil) forState:UIControlStateNormal];
    [self.btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_login_normal"] forState:UIControlStateNormal];
    [self.btnUpload setBackgroundImage:[UIImage imageNamed:@"btn_login_pressed"] forState:UIControlStateSelected];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(submitNewArchive)
                                                 name:@"UPLOAD_SUCCESSFUL"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadMediaFileFail)
                                                 name:@"UPLOAD_FAIL"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [self getContributedChannels];
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate.tabBarController setTabBarHidden:YES];
    [super viewWillAppear:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    // key board height = 216 for portrait, and 162 for landscape
    self.original_y_center = self.view.center.y;
    self.view.center = CGPointMake(self.view.center.x, self.view.center.y-200);
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    self.view.center = CGPointMake(self.view.center.x, self.original_y_center);
}

-(void)getProgressValue

{
    if(progressView.progress < 1.0)
    {
        progressView.progress = uploadMediaFilesHandle.progressValue;
        [self performSelector:@selector(getProgressValue) withObject:self afterDelay:0.1];
    }
//    else
//    {
//        self.btnUpload.hidden = NO;
//        self.progressView.hidden = YES;
//        uploadMediaFilesHandle.progressValue = 0;
//        progressView.progress = 0;
//        return;
//    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)uploadMediaFile:(id)sender {
    
    [self.textDescription resignFirstResponder];
    [self.textMediaFileName resignFirstResponder];
    
    if (self.textMediaFileName.text == nil || [self.textMediaFileName.text isEqualToString:@""]) {
        
        [[Utils getInstance] invokeAlert:@"" message:NSLocalizedString(@"file_name_blank_error", nil) delegate:self];
        return;
    }

    self.progressView.hidden = NO;
    self.btnUpload.hidden = YES;
    [self getProgressValue];
    
    NSString* fileName = self.textMediaFileName.text;
    if (![[fileName pathExtension] isEqualToString:@".mp4"]){
        fileName = [fileName stringByAppendingString:@".mp4"];
    }
    [uploadMediaFilesHandle upLoadMediaFiles:fileName From:[self.videoURL path]];
}

- (IBAction)dismissKeyBoard:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void) getContributedChannels
{
    NSString* userName = [appDelegate.userName stringByReplacingOccurrencesOfString:@"\\" withString:@" "];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/user/%@/contributedChannels/?startIndex=0&pageSize=10000", appDelegate.svrAddr,userName];
    requestStr = [self escapeUrl:requestStr];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-channel-list+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-channel-list+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-channel-list+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray* channelArray =[responseObject valueForKey:@"plcm-content-channel"];
             if(channelArray!=nil && [channelArray count]>0) {
                 //if get channel successful, remove the older.
                 [channelNameList removeAllObjects];
                 [channelListNameAndIdDict removeAllObjects];
             }
             for (int i=0; i<[channelArray count]; i++) {
                 NSDictionary* channelOrigialData = channelArray[i];
                 ChannelData* channelObj = [[ChannelData alloc]init];
                 channelObj.channelId = channelOrigialData[@"channelId"];
                 channelObj.name = channelOrigialData[@"name"];
                 channelObj.description = channelOrigialData[@"description"];
                 //channelObj.creatTime = channelOrigialData[@"createTime"];
                 //channelObj.viewCount = channelOrigialData[@"viewCount"];
                 //channelObj.contentCount = channelOrigialData[@"contentCount"];
                 //channelObj.updateTime = channelOrigialData[@"updateTime"];
                 //channelObj.ownerName = channelOrigialData[@"ownerName"];
                 //channelObj.firstArchiveId = channelOrigialData[@"firstArchiveId"];
                 //channelObj.firstArchiveThumbnailURL = channelOrigialData[@"firstArchiveThumbnailURL"];
                 [channelNameList addObject:channelObj.name];
                 [channelListNameAndIdDict setObject: channelObj.channelId forKey:channelObj.name];
             }
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get Channle List Failed!");
             NSLog(@"Error: %@", error.description);
         }];
    
}


- (void) getArchivePeroperty
{
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/upload/ugc/mediafile/property", appDelegate.svrAddr];
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-csc+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    NSString* filePath = [NSString stringWithFormat:@"%@/ugc.mp4",self.uploadMediaFilesHandle.desUploadFilePathData.fileSavePath];
    NSDictionary *body = @{ @"ipAddr" : self.uploadMediaFilesHandle.desUploadFilePathData.ipAddr,
                            @"port" : self.uploadMediaFilesHandle.desUploadFilePathData.port,
                            @"fileSavePath" : filePath,
                            @"owner" : appDelegate.userName,
                            @"arcDisplayName" : self.textMediaFileName.text};
    
    [manager PUT:requestStr parameters:body
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             ugcArchiveData.achiveId = responseObject[@"archiveId"];
             ugcArchiveData.displayName = responseObject[@"displayName"];
             ugcArchiveData.description = responseObject[@"description"];
             ugcArchiveData.creatTime = responseObject[@"createTime"];
             ugcArchiveData.viewCount = responseObject[@"viewCount"];
             ugcArchiveData.contentCount = responseObject[@"contentCount"];
             ugcArchiveData.updateTime = responseObject[@"updateTime"];
             ugcArchiveData.duration = responseObject[@"duration"];
             ugcArchiveData.owner = responseObject[@"owner"];
             ugcArchiveData.thumbnail = responseObject[@"thumbnail"];
             ugcArchiveData.deviceAddress = responseObject[@"deviceAddress"];
             ugcArchiveData.mediaPath = responseObject[@"mediaPath"];
             ugcArchiveData.deviceId = responseObject[@"deviceId"];
             [self updateArchivePeroperty];

         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get archive peroperty Failed!");
             NSLog(@"Error: %@", error.description);
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_FAIL" object:nil];
         }];
}

- (void) updateArchivePeroperty
{
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/content/archives/%@", appDelegate.svrAddr, self.ugcArchiveData.achiveId];
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-csc+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    if (self.channelSelected==nil) {
        self.channelSelected = [[NSMutableArray alloc]init];
    }
    
    NSDictionary *body = @{ @"archiveId" : self.ugcArchiveData.achiveId,
                            @"description" : self.textDescription.text,
                            @"displayName" : self.textMediaFileName.text,
                            @"channelIds" : self.channelSelected,
                            @"isDownloadable" : @"false",
                            @"owner" : appDelegate.userName,
                            @"pinCode" : @"",
                            @"quickCode" : @"",
                            @"disableRating" : @"false",
                            };
    
    [manager PUT:requestStr parameters:body
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"update archive peropery success!");
             [self showUploadBtn];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_PEROPERTY_SUCCESS" object:nil];
             [self.navigationController popViewControllerAnimated:self];
             
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"update archive peroperty Failed!");
             NSLog(@"Error: %@", error.description);
             [self showUploadBtn];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_FAIL" object:nil];
         }];
}

-(void) submitNewArchive {
    [self getArchivePeroperty];
}

-(void) showUploadBtn {
    self.btnUpload.hidden = NO;
    self.progressView.hidden = YES;
    uploadMediaFilesHandle.progressValue = 0;
    progressView.progress = 0;
}

-(void) uploadMediaFileFail {
    [[Utils getInstance] invokeAlert:NSLocalizedString(@"info_level_error", nil)
                             message:NSLocalizedString(@"ugc_error", nil)
                            delegate:self];
    
    [self showUploadBtn];
    
}

- (NSString *)escapeUrl:(NSString *)string
{
    NSMutableCharacterSet *cs = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    //[cs removeCharactersInString:@"?&="];
    return [string stringByAddingPercentEncodingWithAllowedCharacters: cs];
}

#pragma mark - dropdown list delegate

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    
    channelDropListView = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    channelDropListView.delegate = self;
    [channelDropListView showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    //[channelDropListView SetBackGroundDropDown_R:0.0 G:108.0 B:194.0 alpha:0.70];
    // derek
    [channelDropListView SetBackGroundDropDown_R:255.0 G:255.0 B:255.0 alpha:1.0];
    
}
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{
    /*----------------Get Selected Value[Single selection]-----------------*/
    //NSString* channelId = [[self.channelList objectAtIndex:anIndex] channelId];
    //strChannelsSelected = [NSString stringWithFormat:@"%@%@,",strChannelsSelected, channelId];
}
- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSMutableArray*)ArryData{
    
    /*----------------Get Selected Value[Multiple selection]-----------------*/
    for(int i=0; i<[ArryData count]; i++) {
        NSString* id = [channelListNameAndIdDict objectForKey:ArryData[i]];
        [ArryData replaceObjectAtIndex:i withObject:id];
    }
    self.channelSelected = ArryData;
    NSInteger channelNumber = [ArryData count];
    NSString* title = [NSString stringWithFormat:@"%ld %@", (long)channelNumber,NSLocalizedString(@"selected_channel", nil)];
    [self.btnChannelList setTitle:title forState:UIControlStateNormal];
}
- (void)DropDownListViewDidCancel{
    
}

- (IBAction)DropDownPressed:(id)sender {
    [self.textDescription resignFirstResponder];
    [self.textMediaFileName resignFirstResponder];
    [self.channelDropListView fadeOut];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    int w = 315;
    int h = screenHeight - 100;
    int x = (screenWidth - w)/2;
    int y = 120;
    
    [self showPopUpWithTitle:NSLocalizedString(@"channel_select_title",nil) withOption:channelNameList xy:CGPointMake(x, y) size:CGSizeMake(w, h) isMultiple:YES];
}

//- (IBAction)DropDownSingle:(id)sender {
//    [channelDropListView fadeOut];
//    [self showPopUpWithTitle:@"Select Channel" withOption:channelNameList xy:CGPointMake(16, 150) size:CGSizeMake(287, 280) isMultiple:NO];
//}

//-(CGSize)GetHeightDyanamic:(UILabel*)lbl
//{
//    NSRange range = NSMakeRange(0, [lbl.text length]);
//    CGSize constraint;
//    constraint= CGSizeMake(288 ,MAXFLOAT);
//    CGSize size;
//    
//    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
//        NSDictionary *attributes = [lbl.attributedText attributesAtIndex:0 effectiveRange:&range];
//        CGSize boundingBox = [lbl.text boundingRectWithSize:constraint options: NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
//        
//        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
//    }
//    else{
//        size = [lbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    }
//    return size;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    
//    if ([touch.view isKindOfClass:[UGCPlaybackViewController class]]) {
//        [channelDropListView fadeOut];
//    }
//}


- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![self.textDescription hasText]) {
        self.placeholderLabel.hidden = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if(![self.textDescription hasText]) {
        self.placeholderLabel.hidden = NO;
    }
    else{
        self.placeholderLabel.hidden = YES;
    }
}

@end
