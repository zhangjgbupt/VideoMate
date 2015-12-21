//
//  MediaPlayerViewController.m
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "MediaPlayerViewController.h"
#import "ArchiveFileData.h"
#import "Utils.h"
#import "ShareView.h"

@interface MediaPlayerViewController ()

@end

@implementation MediaPlayerViewController
@synthesize episodeFiles, archiveName, archiveDes, archiveId, thumUrl;
@synthesize player;
@synthesize streamingURLlist;
@synthesize mediaFileCrateTime, mediaFileTitle, mediaFileDes, timeIcon, seperator;
@synthesize likeBtn, likeLabel, shareBtn, shareLabel, likeStatus, likeCount;
@synthesize appDelegate;

//for weixin share
@synthesize shareTitle  = _shareTitle;
@synthesize detailInfo = _detailInfo;
@synthesize shareImage = _shareImage;
@synthesize shareImageURL = _shareImageURL;
@synthesize shareWebPageURL = _shareWebPageURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ArchiveFileData* fileData = nil;
    self.streamingURLlist = [[NSMutableArray alloc]init];
   
    if ([self.episodeFiles count]==1) {
        fileData   = [self.episodeFiles objectAtIndex:0];
    }

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
    
    CGFloat title_x = 10;
    CGFloat title_y = player_y + player_h + 15;
    CGFloat title_w = (screenWidth - title_x*2)*3/5;
    CGFloat title_h = 25;
    CGRect titleFrame = CGRectMake(title_x, title_y, title_w, title_h);
    [self.mediaFileTitle setFrame:titleFrame];
    [self.mediaFileTitle setText:self.archiveName];
    
    CGFloat timeIcon_x = title_x+title_w;
    CGFloat timeIcon_y = title_y+3;
    CGFloat timeIcon_h = 20;
    CGFloat timeIcon_w = 20;
    CGRect timeIconFrame = CGRectMake(timeIcon_x, timeIcon_y, timeIcon_h, timeIcon_w);
    [self.timeIcon setFrame:timeIconFrame];
    
    CGFloat createTime_x = title_x+title_w+25;
    CGFloat createTime_y = title_y;
    CGFloat createTime_h = title_h;
    CGFloat createTime_w = (screenWidth - title_x*2 - title_w - 25);
    CGRect createTimeFrame = CGRectMake(createTime_x, createTime_y, createTime_w, createTime_h);
    [self.mediaFileCrateTime setFrame:createTimeFrame];
    
    CGFloat seperator_x = title_x;
    CGFloat seperator_y = title_y + title_h + 5;
    CGFloat seperator_w = screenWidth - title_x*2;
    CGFloat seperator_h = 1;
    CGRect seperatorFrame = CGRectMake(seperator_x, seperator_y, seperator_w, seperator_h);
    [self.seperator setFrame:seperatorFrame];
    
    CGFloat description_x = title_x;
    CGFloat description_y = seperator_y + seperator_h + 5;
    CGFloat description_w = screenWidth - title_x*2;
    CGFloat description_h = 30;
    CGRect descriptionFrame = CGRectMake(description_x, description_y, description_w, description_h);
    [self.mediaFileDes setFrame:descriptionFrame];
    [self.mediaFileDes setText:self.archiveDes];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:([fileData.creatTime doubleValue]/ 1000)];
    [self.mediaFileCrateTime setText:[NSDateFormatter localizedStringFromDate:date
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterShortStyle]];
    CGFloat likeBtn_x = 50;
    CGFloat likeBtn_y = screenHeight-50;
    CGFloat likeBtn_w = 32;
    CGFloat likeBtn_h = 32;
    CGRect likeBtnFrame = CGRectMake(likeBtn_x, likeBtn_y, likeBtn_w, likeBtn_h);
    [likeBtn setFrame:likeBtnFrame];
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like_normal.png"] forState:UIControlStateNormal];
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like_pressed.png"] forState:UIControlStateHighlighted];
    
    CGFloat likeLabel_x = likeBtn_x+likeBtn_w+5;
    CGFloat likeLabel_y = likeBtn_y;
    CGFloat likeLabel_w = 50;
    CGFloat likeLabel_h = 32;
    CGRect likeLabelFrame = CGRectMake(likeLabel_x, likeLabel_y, likeLabel_w, likeLabel_h);
    [self.likeLabel setFrame:likeLabelFrame];
    [self.likeLabel setText:self.likeCount];
    
    CGFloat shareBtn_x = screenWidth - 50 - 50 - 5 - 32;
    CGFloat shareBtn_y = likeBtn_y;
    CGFloat shareBtn_w = 32;
    CGFloat shareBtn_h = 32;
    CGRect shareBtnFrame = CGRectMake(shareBtn_x, shareBtn_y, shareBtn_w, shareBtn_h);
    [self.shareBtn setFrame:shareBtnFrame];
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"icon_share_normal.png"] forState:UIControlStateNormal];
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"icon_share_pressed.png"] forState:UIControlStateHighlighted];
    
    CGFloat shareLabel_x = shareBtn_x+shareBtn_w+5;
    CGFloat shareLabel_y = shareBtn_y;
    CGFloat shareLabel_w = 50;
    CGFloat shareLabel_h = 32;
    CGRect shareLabelFrame = CGRectMake(shareLabel_x, shareLabel_y, shareLabel_w, shareLabel_h);
    [self.shareLabel setFrame:shareLabelFrame];
    
    //[self.shareBtn setHidden:TRUE];
    //[self.shareLabel setHidden:TRUE];
    
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
    if ([self.episodeFiles count] == 0) {
        [[Utils getInstance] invokeAlert:@"Error" message:@"There is no compatible video format" delegate:self];
        //[self invokeAlert:@"Error" message:@"There is no compatible video format" delegate:self];
        return;
    }
    ArchiveFileData* file = [self.episodeFiles objectAtIndex:0];
    [self getStreamingURL:file.archiveId withFileId:file.fileId];
    [self getLikeStatus];
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

- (void)setFiles:(NSMutableArray *)files {
    self.episodeFiles = files;
}

- (IBAction)likeBtnClick:(id)sender {
    [self doLike];
}

- (IBAction)shareBtnClick:(id)sender {
    NSString *imageURL=self.thumUrl;
    NSString *title=self.archiveName;
    NSString *detailInfo = self.archiveDes;
    NSString *webUrl=[[appDelegate.svrAddr stringByAppendingString:@"/userportal/video?v="] stringByAppendingString:self.archiveId];
    webUrl = [NSString stringWithFormat:@"http://%@", webUrl ];
    
    //ShareToolViewController *shareToolViewController = [[ShareToolViewController alloc]
    //                                                    initWithNibName:@"ShareToolViewController" bundle:nil];
    //shareToolViewController.delegate = self;
    //[self addChildViewController:shareToolViewController];
    [self initWhithTitle:title detailInfo:detailInfo image:nil imageUrl:imageURL webpageUrl:webUrl];
    //[self.view addSubview:shareToolViewController.view];
}

- (IBAction)toSendView {
    
    //SharePopupVC *vc = [[SharePopupVC alloc]init];
    
    //UIImage *image = [UIImage imageWithCaputureView:self.view];
    
    //vc.backImg = image;
    
    //[self presentViewController:vc animated:NO completion:nil];
    
    ShareView *view = [[ShareView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 160, self.view.frame.size.width, 160)];
    [view show];
    
}

-(void) doLike {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentLiked", appDelegate.svrAddr];
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-liked+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-liked+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-liked+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    NSString* state = nil;
    if ([self.likeStatus isEqualToString:@"LIKE"]) {
        state = @"NONE";
    } else {
        state = @"LIKE";
    }
    
    if (self.likeStatus == nil) {
        self.likeStatus = @"NONE";
    }
        
    NSDictionary *body = @{ @"archiveId" : self.archiveId,
                            @"status" : state,
                            @"oldStatus" : self.likeStatus};
    
    [manager POST:requestStr parameters:body
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSNumber* numLikeCount = [responseObject valueForKey:@"likeCount"];
             self.likeCount = [numLikeCount stringValue];
             [self.likeLabel setText:self.likeCount];
             [self getLikeStatus];
             //long unlikedCount = [responseObject valueForKey:@"unlikeCount"];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get like count fail!");
             NSLog(@"Error: %@", error.description);
         }];
}

-(void) getLikeStatus {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentLiked/archiveId/%@/userId", appDelegate.svrAddr, self.archiveId];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-liked+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-liked+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-liked+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //long userid = [responseObject valueForKey:@"userId"];
        
             //LIKE/DISLIKE
             self.likeStatus = [responseObject valueForKey:@"status"];
             if ([self.likeStatus isEqualToString:@"LIKE"]) {
                 [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like_pressed.png"] forState:UIControlStateNormal];
                 [self.likeLabel setTextColor:[UIColor colorWithRed:221.0f/255.0f green:77.0f/255.0f blue:53.0f/255.0f alpha:1.0f]];
             } else {
                 [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like_normal.png"] forState:UIControlStateNormal];
                 [self.likeLabel setTextColor:[UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f]];
             }
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get like status fail!");
             NSLog(@"Error: %@", error.description);
         }];
}

- (void)getStreamingURL:(NSString*) archiveid withFileId:(NSString*) fileId {
        NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/streaming/vods?archiveId=%@&archiveFileId=%@", appDelegate.svrAddr, archiveid, fileId];
        
        NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy.validatesDomainName = NO;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-stream-vod+json"];
        [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-stream-vod+json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-stream-vod+json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
        [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
        [manager GET:requestStr parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSMutableArray* vodStreamingList = [responseObject valueForKey:@"streamingDetails"];
                 for (int i=0; i<[vodStreamingList count]; i++) {
                     NSDictionary* streamingOrigialData = vodStreamingList[i];
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

- (void) startPlay {
    NSString* url = [self.streamingURLlist objectAtIndex:0];
    [self.player setContentURL:[NSURL URLWithString:url]];
    [self.player play];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - 分享
- (void)initWhithTitle:(NSString *)title
            detailInfo:(NSString*)info
                 image:(UIImage *)image
              imageUrl:(NSString *)imageUrl
            webpageUrl:(NSString*)webpageUrl{
    _shareTitle = title;
    _detailInfo = info;
    _shareImage = image;
    _shareImageURL = imageUrl;
    _shareWebPageURL = webpageUrl;
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"分享到微信朋友",@"分享到微信朋友圈",nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //通过微信好友分享
            [self shareInformationWithType:kShareTool_WeiXinFriends];
            break;
        case 1: //通过微信朋友圈分享
            [self shareInformationWithType:kShareTool_WeiXinCircleFriends];
            break;
        default:
            break;
    }
}

- (void)shareInformationWithType:(ShareToolType)shareToolType {
    switch (shareToolType) {
        case kShareTool_WeiXinFriends:{
            WXImageObject *imgObj = [WXImageObject object];
            imgObj.imageUrl = _shareImageURL;
            
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = _shareWebPageURL;
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = _shareTitle;
            message.description = _detailInfo;
            message.mediaObject = webObj;
            
            UIImage *desImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareImageURL]]];
            UIImage *thumbImg = [self thumbImageWithImage:desImage limitSize:CGSizeMake(150, 150)];
            message.thumbData = UIImageJPEGRepresentation(thumbImg, 1);
            //            NSLog(@"%@,%d",thumbImg,message.thumbData.length);
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.scene = WXSceneSession;
            req.bText = NO;
            req.message = message;
            [WXApi sendReq:req];
            [self shareHasDone];
            break;
        }
        case kShareTool_WeiXinCircleFriends:{
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = _shareImageURL;
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = _shareTitle;
            message.description = _detailInfo;
            message.mediaObject = webObj;
            
            UIImage *desImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareImageURL]]];
            UIImage *thumbImg = [self thumbImageWithImage:desImage limitSize:CGSizeMake(150, 150)];
            message.thumbData = UIImageJPEGRepresentation(thumbImg, 1);
            //            NSLog(@"%@,%d",thumbImg,message.thumbData.length);
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.scene = WXSceneTimeline;
            req.bText = NO;
            req.message = message;
            [WXApi sendReq:req];
            [self shareHasDone];
            break;
        }
        default:
            break;
    }
}
- (UIImage *)thumbImageWithImage:(UIImage *)scImg limitSize:(CGSize)limitSize
{
    if (scImg.size.width <= limitSize.width && scImg.size.height <= limitSize.height) {
        return scImg;
    }
    CGSize thumbSize;
    if (scImg.size.width / scImg.size.height > limitSize.width / limitSize.height) {
        thumbSize.width = limitSize.width;
        thumbSize.height = limitSize.width / scImg.size.width * scImg.size.height;
    }
    else {
        thumbSize.height = limitSize.height;
        thumbSize.width = limitSize.height / scImg.size.height * scImg.size.width;
    }
    UIGraphicsBeginImageContext(thumbSize);
    [scImg drawInRect:(CGRect){CGPointZero,thumbSize}];
    UIImage *thumbImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbImg;
}
- (void)shareHasDone{
    self.shareImage = nil;
    self.shareTitle = nil;
    self.shareImageURL = nil;
    self.detailInfo = nil;
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}



@end
