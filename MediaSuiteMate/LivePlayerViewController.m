//
//  LivePlayerViewController.m
//  VideoMate
//
//  Created by Chris Ling on 15/12/4.
//  Copyright © 2015年 derek. All rights reserved.
//

#import "LivePlayerViewController.h"

@interface LivePlayerViewController ()

@end

@implementation LivePlayerViewController
@synthesize callID, subject, createTime, description, isEasyCapture, desTitle;
@synthesize player;
@synthesize streamingURLlist;
@synthesize mediaFileCrateTime, liveIcon, liveText, mediaFileTitle, mediaFileDes, timeIcon, seperator1, seperator2, slide1, slide2, recommendTitle, recommendImg;
@synthesize appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.streamingURLlist = [[NSMutableArray alloc]init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat player_h = screenWidth*9/16;
    CGFloat player_y = self.navigationController.navigationBar.frame.size.height+20;
    
    if (self.player == nil)
    {
        self.player = [[MPMoviePlayerController alloc] init];
    }
    [self.player.view setFrame:CGRectMake (0, player_y, screenWidth, player_h)];
    [self.view addSubview:[self.player view]];
    [self.player setFullscreen:YES];
    [self.player setShouldAutoplay:NO];   //Stop it from autoplaying
    [self.player prepareToPlay];          //Start preparing the video

    CGFloat liveIcon_x = 5;
    CGFloat liveIcon_y = player_y + player_h + 15;
    CGFloat liveIcon_w = 25;
    CGFloat liveIcon_h = 25;
    [self.liveIcon setFrame:CGRectMake(liveIcon_x, liveIcon_y, liveIcon_w, liveIcon_h)];
    [self.liveIcon setImage:[UIImage imageNamed:@"icon_live_back"]];
    
    [self.liveText setTextColor:[UIColor whiteColor]];
    [self.liveText setFont:[UIFont fontWithName:@"Arial" size:12]];
    [self.liveText setFrame:CGRectMake(liveIcon_x, liveIcon_y, liveIcon_w, liveIcon_h)];
    [self.liveText setText:NSLocalizedString(@"live_icon", nil)];
    
    CGFloat title_x = liveIcon_x + liveIcon_w +5;
    CGFloat title_y = player_y + player_h + 15;
    CGFloat title_w = (screenWidth - title_x*2)*3/5;
    CGFloat title_h = 25;
    CGRect titleFrame = CGRectMake(title_x, title_y, title_w, title_h);
    [self.mediaFileTitle setFrame:titleFrame];
    [self.mediaFileTitle setText:self.subject];
    [self.mediaFileTitle setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:18.0]];
    
    CGFloat timeIcon_x = title_x+title_w;
    CGFloat timeIcon_y = title_y+3;
    CGFloat timeIcon_h = 20;
    CGFloat timeIcon_w = 20;
    CGRect timeIconFrame = CGRectMake(timeIcon_x, timeIcon_y, timeIcon_h, timeIcon_w);
    [self.timeIcon setFrame:timeIconFrame];
    
    CGFloat createTime_x = title_x+title_w + 25;
    CGFloat createTime_y = title_y;
    CGFloat createTime_h = title_h;
    CGFloat createTime_w = (screenWidth - title_x*2 - title_w - 25);
    CGRect createTimeFrame = CGRectMake(createTime_x, createTime_y, createTime_w, createTime_h);
    [self.mediaFileCrateTime setFrame:createTimeFrame];
    
    CGFloat seperator1_x = 0;
    CGFloat seperator1_y = title_y + title_h + 10;
    CGFloat seperator1_w = screenWidth;
    CGFloat seperator1_h = 1;
    CGRect seperatorFrame = CGRectMake(seperator1_x, seperator1_y, seperator1_w, seperator1_h);
    [self.seperator1 setFrame:seperatorFrame];

    CGFloat slide1_x = 0;
    CGFloat slide1_y = seperator1_y + seperator1_h + 5;
    CGFloat slide1_w = 5;
    CGFloat slide1_h = 30;
    [self.slide1 setFrame:CGRectMake(slide1_x, slide1_y, slide1_w, slide1_h)];
    [self.slide1 setImage:[UIImage imageNamed:@"live_tag"]];
    
    CGFloat desTitle_y = seperator1_y + seperator1_h + 10;
    CGFloat desTitle_h = 20;
    CGRect desTitleFrame = CGRectMake(10, desTitle_y, 100, desTitle_h);
    [self.desTitle setFrame:desTitleFrame];
    [self.desTitle setText:NSLocalizedString(@"live_description_title", nil)];
    [self.desTitle setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:18.0]];
    
    CGFloat description_x = 10;
    CGFloat description_y = desTitle_y + desTitle_h;
    CGFloat description_w = screenWidth - title_x*2;
    CGFloat description_h = 30;
    CGRect descriptionFrame = CGRectMake(description_x, description_y, description_w, description_h);
    [self.mediaFileDes setFrame:descriptionFrame];
    [self.mediaFileDes setFont:[UIFont fontWithName:@"Arial" size:14.0]];
    [self.mediaFileDes setTextColor:[UIColor grayColor]];
    if ([self.description length] == 0) {
       [self.mediaFileDes setText:NSLocalizedString(@"no_description", nil)];
    } else {
        [self.mediaFileDes setText:self.description];
    }
    
    if (self.createTime != nil) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:([self.createTime doubleValue]/ 1000)];
        [self.mediaFileCrateTime setText:[NSDateFormatter localizedStringFromDate:date
                                                                    dateStyle:NSDateFormatterShortStyle
                                                                    timeStyle:NSDateFormatterShortStyle]];
    } else {
        [self.mediaFileCrateTime setText:@""];
        [self.timeIcon setHidden:YES];
    }
    CGFloat seperator2_y = description_y + description_h + 5;
    CGRect seperatorFrame2 = CGRectMake(seperator1_x, seperator2_y, seperator1_w, 1);
    [self.seperator2 setFrame:seperatorFrame2];
    
    CGFloat slide2_x = 0;
    CGFloat slide2_y = seperator2_y + 1 + 5;
    CGFloat slide2_w = 5;
    CGFloat slide2_h = 30;
    [self.slide2 setFrame:CGRectMake(slide2_x, slide2_y, slide2_w, slide2_h)];
    [self.slide2 setImage:[UIImage imageNamed:@"live_tag"]];
    
    CGFloat recommendTitle_x = 10;
    CGFloat recommendTitle_y = seperator2_y + 1 + 10;
    CGFloat recommendTitle_w = 100;
    CGFloat recommendTitle_h = 20;
    CGRect recommendTitleFrame = CGRectMake(recommendTitle_x, recommendTitle_y, recommendTitle_w, recommendTitle_h);
    [self.recommendTitle setFrame:recommendTitleFrame];
    [self.recommendTitle setText:NSLocalizedString(@"recommend_title", nil)];
    [self.recommendTitle setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:18.0]];
    
    CGFloat recommendImg_x = 0;
    CGFloat recommendImg_y = slide2_y + slide2_h;
    CGFloat recommendImg_w = screenWidth;
    CGFloat recommendImg_h = screenHeight - recommendImg_y;
    [self.recommendImg setFrame:CGRectMake(recommendImg_x, recommendImg_y, recommendImg_w, recommendImg_h)];
    [self.recommendImg setImage:[UIImage imageNamed:@"no_recommend_live"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(moviePlayerPlaybackStateDidChange:)  name:MPMoviePlayerPlaybackStateDidChangeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(moviePlayBackDidFinish:)  name:MPMoviePlayerPlaybackDidFinishNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    if (error) {
        NSLog(@"Did finish with error: %@", error);
    }
}

- (void) moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    NSLog(@"playbackDidChanged");
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    if(playbackState == MPMoviePlaybackStateStopped) {
        NSLog(@"MPMoviePlaybackStateStopped");
    } else if(playbackState == MPMoviePlaybackStatePlaying) {
        NSLog(@"MPMoviePlaybackStatePlaying");
    } else if(playbackState == MPMoviePlaybackStatePaused) {
        NSLog(@"MPMoviePlaybackStatePaused");
    } else if(playbackState == MPMoviePlaybackStateInterrupted) {
        NSLog(@"MPMoviePlaybackStateInterrupted");
    } else if(playbackState == MPMoviePlaybackStateSeekingForward) {
        NSLog(@"MPMoviePlaybackStateSeekingForward");
    } else if(playbackState == MPMoviePlaybackStateSeekingBackward) {
        NSLog(@"MPMoviePlaybackStateSeekingBackward");
    }
}

- (void)moviePlayerLoadStateChanged:(NSNotification *)notification
{
    //NSLog(@"State changed to: %d\n", self.player.loadState);
    if((self.player.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable)
    {
        [self.player play];//play the video
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.appDelegate.tabBarController setTabBarHidden:YES];
    if (!self.isEasyCapture) {
        [self getLiveStreamingURL:self.callID];
    } else {
        [self getEasyCaptureStreamingURL:self.callID];
    }
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(![self.player isFullscreen]) {
        [self.player stop];
    }
    [super viewWillDisappear:YES];
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLiveStreamingURL:(NSString*) callId {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/streaming/lives/call/%@", appDelegate.svrAddr, callId];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-stream-live+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-stream-live+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-stream-live+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSMutableArray* liveStreamingList = [responseObject valueForKey:@"streamingDetails"];
             for (int i=0; i<[liveStreamingList count]; i++) {
                 NSDictionary* streamingOrigialData = liveStreamingList[i];
                 NSMutableArray* streamingUrlList = [streamingOrigialData valueForKey:@"streamingUrls"];
                 
                 [self.streamingURLlist removeAllObjects];
                 
                 for (int j=0; j<[streamingUrlList count]; j++) {
                     NSDictionary* streamingUrlOrigialData = streamingUrlList[j];
                     NSString* streamingProtocol =streamingUrlOrigialData[@"streamingProtocol"];
                     if ([streamingProtocol isEqualToString:@"AHLS"]) {
                         NSString* steamingUrl = streamingUrlOrigialData[@"streamingUrl"];
                         [self.streamingURLlist addObject:steamingUrl];
                     }
                 }
                 [self startPlay];
             }
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get streaming URL fail!");
             NSLog(@"Error: %@", error.description);
         }];
}

- (void)getEasyCaptureStreamingURL:(NSString*) callId {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/streaming/easycapture/url/%@", appDelegate.svrAddr, callId];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-stream-easycapture+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-stream-easycapture+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-stream-easycapture+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self.streamingURLlist removeAllObjects];
             NSMutableArray* easyCaptureStreamingList = responseObject;
             for (int i=0; i<[easyCaptureStreamingList count]; i++) {
                 NSDictionary* streamingUrlOrigialData = easyCaptureStreamingList[i];
                 NSString* streamingProtocol =streamingUrlOrigialData[@"protocol"];
                     if ([streamingProtocol isEqualToString:@"AHLS"]) {
                         NSString* steamingUrl = streamingUrlOrigialData[@"url"];
                         [self.streamingURLlist addObject:steamingUrl];
                     }
             }
             [self startPlay];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get streaming URL fail!");
             NSLog(@"Error: %@", error.description);
         }];
}


- (void) startPlay {
    NSString* url = [self.streamingURLlist objectAtIndex:0];
    [self.player setContentURL:[NSURL URLWithString:url]];
    [self.player prepareToPlay];
    //[self.player play];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
