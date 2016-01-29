//
//  MyMediaViewController.m
//  MediaSuiteMate
//
//  Created by derek on 23/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "MyMediaViewController.h"
#import "LoginViewController.h"
#import "MediaPlayerViewController.h"
#import "UGCPlaybackViewController.h"
#import "BGTableViewRowActionWithImage.h"


@interface MyMediaViewController ()

@end

@implementation MyMediaViewController
@synthesize archiveCount, selectedArchive2Share, archiveList, channelNameList, channelListNameAndIdDict;
@synthesize uploadButton;
@synthesize videoURL;
@synthesize videoSourceSelectorMenu, isUploadClick;
@synthesize refreshFooter, refreshHeader, refreshHeader4EmptyView;
@synthesize maxPageNumber, currentPageIndex;
@synthesize appDelegate;
@synthesize channelDropListView;
@synthesize emptyVideoImg, emptyVideoTitle, emptyVideoDetail;

static NSString * const reuseArchiveIdentifier = @"ArchiveCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageIndex = 0;
    self.maxPageNumber = 0;
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.appDelegate setShouldRotate:NO];
    
    self.channelNameList = [[NSMutableArray alloc]init];
    self.channelListNameAndIdDict = [[NSMutableDictionary alloc] init];
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = screenFrame.size.width;
    tableViewFrame.size.height = screenFrame.size.height-66;
    [self.tableView setFrame:tableViewFrame];
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ArchiveTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseArchiveIdentifier];
    
    [self.emptyView setFrame:tableViewFrame];

    //force UIView to UIScrollView
    [(UIScrollView *)self.emptyView setContentSize:CGSizeMake(tableViewFrame.size.width, tableViewFrame.size.height+1)];

    CGRect emptyViewFrame = self.emptyView.frame;
    CGFloat viewWidth = emptyViewFrame.size.width;
    CGFloat viewHeight = emptyViewFrame.size.height;
    
    CGFloat empty_img_x = viewWidth/4;
    CGFloat empty_img_y = viewHeight/3;
    CGFloat empty_img_w = viewWidth/2;
    CGFloat empty_img_h = empty_img_w;
    [self.emptyVideoImg setFrame:CGRectMake(empty_img_x, empty_img_y, empty_img_w, empty_img_h)];
    
    CGFloat empty_title_x = viewWidth/5;
    CGFloat empty_title_y = empty_img_y + empty_img_h + 10;
    CGFloat empty_title_w = viewWidth*3/5;
    CGFloat empty_title_h = 20;
    [self.emptyVideoTitle setFrame:CGRectMake(empty_title_x, empty_title_y, empty_title_w, empty_title_h)];
    [self.emptyVideoTitle setText:NSLocalizedString(@"no_media_title", nil)];
    
    CGFloat empty_detail_x = viewWidth/10;
    CGFloat empty_detail_y = empty_img_y + empty_img_h + 10 + 20;
    CGFloat empty_detail_w = viewWidth*4/5;
    CGFloat empty_detail_h = 20;
    [self.emptyVideoDetail setFrame:CGRectMake(empty_detail_x, empty_detail_y, empty_detail_w, empty_detail_h)];
    [self.emptyVideoDetail setText:NSLocalizedString(@"no_media_info", nil)];
    
    [self.emptyView addSubview:emptyVideoImg];
    [self.emptyView addSubview:emptyVideoTitle];
    [self.emptyView addSubview:emptyVideoDetail];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyView];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.topViewController.title = NSLocalizedString(@"my_media_page_title", nil);
    uploadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_upload"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(go2ugcSourceSelect)];
    self.navigationItem.rightBarButtonItem = uploadButton;
    
    [self initUgcSourceSelectorView];
    isUploadClick = NO;
    
     self.archiveList = [[NSMutableArray alloc]init];
    [self getContributedChannels];
    [self getMyArchives];
    [self setupHeader];
    [self setupFooter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMyArchives)
                                                 name:@"UPDATE_PEROPERTY_SUCCESS"
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate startNetworkConnectionMonitor];
    [appDelegate setShouldRotate:NO];
    [self getContributedChannels];
    [appDelegate.tabBarController setTabBarHidden:NO];
    [super viewWillAppear:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.archiveList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArchiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseArchiveIdentifier forIndexPath:indexPath];
    ArchiveData* archive = [self.archiveList objectAtIndex:indexPath.row];
    NSString* thumUrlString = archive.archiveCoverURL;
    UIImage* thumImage = [UIImage imageNamed:@"image_default_media"];
    if (thumUrlString!=nil) {
        //if thumnail url is avaliable, just get the image async.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSURL* thumUrl = [NSURL URLWithString:thumUrlString];
            UIImage* thumImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumUrl]];
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                if (thumImage==nil) {
                    [cell.archiveThum setImage:[UIImage imageNamed:@"image_default_media"]];
                } else {
                   [cell.archiveThum setImage:thumImage];
                }
            }
           );
        });
    }
    
    
    CGFloat w = cell.frame.size.width;
    CGFloat thum_w = w - 40;
    CGFloat thum_h = thum_w*9/16;
    CGRect frame = cell.archiveThum.frame;
    [cell.archiveThum setFrame:CGRectMake(frame.origin.x, frame.origin.y, thum_w, thum_h)];
    [cell.archiveThum setImage:thumImage];
    [cell.archiveName setText:archive.displayName];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:([archive.creatTime doubleValue]/ 1000)];
    [cell.archiveCreateTime setText:[NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle]];
    NSString* duration = [self timeFormatted:[archive.duration integerValue]];
    [cell.archiveDuration setText:duration];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat imageWidth = screenWidth - 40;
    CGFloat imageHight = imageWidth*9/16;
    //title height = 30px
    CGFloat cellHeight = imageHight + 30 + 30;
    return cellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //dropdown view always in top-right.
    CGRect fixedFrame = self.videoSourceSelectorMenu.frame;
    fixedFrame.origin.y = 10 + scrollView.contentOffset.y;
    self.videoSourceSelectorMenu.frame = fixedFrame;
    
    //popup channel selected view in middle of the mainview.
    CGRect channelSelectViewRect = self.channelDropListView.frame;
    channelSelectViewRect.origin.y = 100 + scrollView.contentOffset.y;
    self.channelDropListView.frame = channelSelectViewRect;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //ArchiveData* archive = [self.archiveList objectAtIndex:indexPath.row];
        //[self deleteArchive:archive.achiveId];
        //[self.archiveList removeObjectAtIndex:indexPath.row];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedArchive2Share = [self.archiveList objectAtIndex:indexPath.row];
    BGTableViewRowActionWithImage *deleteBtn = [BGTableViewRowActionWithImage rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"slide_delete", nil) backgroundColor:[UIColor colorWithRed:221.0f/255.0f green:77.0f/255.0f blue:53.0f/255.0f alpha:1.0f] image:[UIImage imageNamed:@"icon_delete"] forCellHeight:260 handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                            NSLog(@"Action to perform with Delete");
                                            ArchiveData* archive = [self.archiveList objectAtIndex:indexPath.row];
                                            [self deleteArchive:archive.achiveId];
                                            //[self.archiveList removeObjectAtIndex:indexPath.row];
                                            //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    BGTableViewRowActionWithImage *shareBtn = [BGTableViewRowActionWithImage rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"slide_share", nil) backgroundColor:[UIColor colorWithRed:201.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:1.0f] image:[UIImage imageNamed:@"icon_share"] forCellHeight:260 handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"Action to perform with Share!");
        [self share2Channel];
    }];
    
    return @[deleteBtn, shareBtn];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ArchiveData* archive = [self.archiveList objectAtIndex:indexPath.row];
    NSMutableArray* episodeFiles = archive.archiveFiles;
    MediaPlayerViewController* mediaPlayer = [[MediaPlayerViewController alloc]init];
    [mediaPlayer setFiles:episodeFiles];
    [mediaPlayer setArchiveId:archive.achiveId];
    [mediaPlayer setArchiveName:archive.displayName];
    [mediaPlayer setArchiveDes:archive.description];
    [mediaPlayer setLikeCount:archive.likeCount];
    [mediaPlayer setThumUrl:archive.archiveCoverURL];
    [mediaPlayer setCreateTime:archive.creatTime];
    [self.navigationController pushViewController:mediaPlayer animated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - restapi

-(void) getMyArchives {
    if (self.archiveCount == nil) {
        self.archiveCount = @"3";
    }
    
    NSString* userName = [appDelegate.userName stringByReplacingOccurrencesOfString:@"\\"
                                                                         withString:@" "];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/content/archives/%@/page?ownerPublic=2&page=0&pageSize=100&sort=Time", appDelegate.svrAddr,userName];
    requestStr = [self escapeUrl:requestStr];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-archive+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSArray* archiveArray = responseObject;
            [self.archiveList removeAllObjects];
             
             for (int i=0; i<[archiveArray count]; i++) {
                 NSDictionary* archiveOrigialData = archiveArray[i];
                 ArchiveData* archiveObj = [[ArchiveData alloc]init];
                 archiveObj.achiveId = archiveOrigialData[@"archiveId"];
                 archiveObj.displayName = archiveOrigialData[@"displayName"];
                 archiveObj.description = archiveOrigialData[@"description"];
                 archiveObj.creatTime = archiveOrigialData[@"createTime"];
                 archiveObj.viewCount = archiveOrigialData[@"viewCount"];
                 archiveObj.contentCount = archiveOrigialData[@"contentCount"];
                 archiveObj.updateTime = archiveOrigialData[@"updateTime"];
                 archiveObj.duration = archiveOrigialData[@"duration"];
                 archiveObj.owner = archiveOrigialData[@"owner"];
                 archiveObj.thumbnail = archiveOrigialData[@"thumbnail"];
                 archiveObj.deviceAddress = archiveOrigialData[@"deviceAddress"];
                 archiveObj.mediaPath = archiveOrigialData[@"mediaPath"];
                 archiveObj.deviceId = archiveOrigialData[@"deviceId"];
                 archiveObj.channelList = archiveOrigialData[@"channelIds"];
                 
                 NSNumber* likedCount = archiveOrigialData[@"likeCount"];
                 archiveObj.likeCount = [likedCount stringValue];
                 
                 if (isNSNull(archiveObj.description)) {
                     archiveObj.description = @"";
                 }
                 
                 if ((isNSNull(archiveOrigialData[@"archiveCoverURL"])) || archiveOrigialData[@"archiveCoverURL"]==nil) {
                     archiveObj.archiveCoverURL = nil;
                 } else {
                     archiveObj.archiveCoverURL = archiveOrigialData[@"archiveCoverURL"];
                     archiveObj.archiveCoverURL = [archiveObj.archiveCoverURL stringByReplacingOccurrencesOfString:@"{port}" withString:@"8888"];
                     archiveObj.archiveCoverURL = [NSString stringWithFormat:@"http://%@", archiveObj.archiveCoverURL];
                 }
                 
                 archiveObj.archiveFiles = [[NSMutableArray alloc]init];
                 
                 NSArray* archiveFileArray = archiveOrigialData[@"archiveFiles"];
                 int episode = 0;
                 for (int j=0; j<[archiveFileArray count]; j++) {
                     ArchiveFileData* fileData = [[ArchiveFileData alloc]init];
                     NSDictionary* fileOrigialData = archiveFileArray[j];
                     fileData.fileId = fileOrigialData[@"fileId"];
                     fileData.fileName = fileOrigialData[@"fileName"];
                     fileData.displayName = fileOrigialData[@"displayName"];
                     fileData.fileType = fileOrigialData[@"fileType"];
                     fileData.creatTime = fileOrigialData[@"createTime"];
                     fileData.resolution = fileOrigialData[@"resolution"];
                     fileData.flocate = fileOrigialData[@"flocate"];
                     fileData.archiveId = fileOrigialData[@"archiveId"];
                     fileData.length = fileOrigialData[@"length"];
                     fileData.duration = fileOrigialData[@"duration"];
                     fileData.episode = fileOrigialData[@"episode"];
                     int tmpEpisode = [fileData.episode intValue];
                     if(tmpEpisode > episode && [fileData.fileType isEqualToString:@"MP4"]) {
                         episode = tmpEpisode;
                         [archiveObj.archiveFiles addObject:fileData];
                     }
                 }
                 [self.archiveList addObject:archiveObj];
             }
             if ([self.archiveList count]==0) {
                 //[self.view bringSubviewToFront:self.emptyView];
                 //[self.tableView removeFromSuperview];
                 //[self.emptyView removeFromSuperview];
                 //[self.view addSubview:self.emptyView];
                 
                 for (UIView *subView in self.view.subviews) {
                     if([subView isKindOfClass:[UITableView class]]) {
                         [subView removeFromSuperview];
                     }
                 }
                 [self.view addSubview:self.emptyView];
             } else {
                 //[self.view bringSubviewToFront:self.tableView];
                 [self.view addSubview:self.tableView];
                 [self.tableView reloadData];
             }
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get Channle List Failed!");
             NSLog(@"Error: %@", error.description);
         }];
    
}

-(void) getMyArchiveCount {
    NSString* userName = [appDelegate.userName stringByReplacingOccurrencesOfString:@"\\" withString:@" "];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/content/archives/%@/count?ownerPublic=2", appDelegate.svrAddr, userName];
    requestStr = [self escapeUrl:requestStr];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-archive+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //for MediaSuit2.1, only api response only return countvalue;
             //for MediaSuit2.5, will return searchType, searchKey, count.
             self.archiveCount = [responseObject valueForKey:@"count"];
             [self getMyArchives];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get archive Count Failed!");
             NSLog(@"Error: %@", error.description);
         }];
    
    
}

-(void) deleteArchive:(NSString*) archiveId {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/content/archives/%@", appDelegate.svrAddr, archiveId];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-archive+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-archive+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager DELETE:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Delete Archive ---  SUCCESS");
             [self getMyArchives];
        }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Delete Archive ---  FAIL");
             NSLog(@"Error: %@", error.description);
         }];
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

- (void) updateArchivePeroperty:(NSString*) archiveId withChannelIds:(NSMutableArray*)selectedChannelList
{
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/content/archives/%@", appDelegate.svrAddr, archiveId];
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
    
    if (selectedChannelList==nil) {
        selectedChannelList = [[NSMutableArray alloc]init];
    }
    
    NSDictionary *body = @{ @"archiveId" : archiveId,
                            @"description" : self.selectedArchive2Share.description,
                            @"displayName" : self.selectedArchive2Share.displayName,
                            @"channelIds" : selectedChannelList,
                            @"owner" : self.selectedArchive2Share.owner,
                            };
    
    [manager PUT:requestStr parameters:body
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"update archive peropery success!");
             [self getMyArchives];
             
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"update archive peroperty Failed!");
             NSLog(@"Error: %@", error.description);
         }];
}

#pragma mark - UIImagePickerController Delegate

- (void)captureVideo {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor],NSForegroundColorAttributeName,
                                        [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
        picker.navigationBar.titleTextAttributes = textAttributes;
        picker.navigationBar.tintColor = [UIColor whiteColor];
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = YES;
        picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        [self presentModalViewController: picker animated: YES];
        
        //[self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)getVideoFromAlbum {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor],NSForegroundColorAttributeName,
                                        [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
        picker.navigationBar.titleTextAttributes = textAttributes;
        picker.navigationBar.tintColor = [UIColor whiteColor];
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        //picker.videoMaximumDuration = 300.0f; // 300 seconds
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.videoURL = info[UIImagePickerControllerMediaURL];
    
    if ((picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        && (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([self.videoURL path])))
    {
        UISaveVideoAtPathToSavedPhotosAlbum([self.videoURL path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
    
    UGCPlaybackViewController*  ugcPlaybackViewController = [[UGCPlaybackViewController alloc]init];
    ugcPlaybackViewController.videoURL = self.videoURL;
    [self.navigationController pushViewController:ugcPlaybackViewController animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
    
}


-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    /*
     if (error) {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];
     } else {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
     delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];
     }
     */
}

- (void)videoPlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    // Stop the video player and remove it from view
    //[self.videoController play];
    //[self.videoController.view removeFromSuperview];
    //self.videoController = nil;
    /*
     // Display a message
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle:@"Video Playback" message:@"Just finished the video playback. The video is now removed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];
     */
}

#pragma mark - IGLDropDownMenu Delegate

- (void) go2ugcSourceSelect {
    
    if(videoSourceSelectorMenu.expanding) {
        [self.videoSourceSelectorMenu setExpanding:NO];
        [self.videoSourceSelectorMenu removeFromSuperview];
    } else {
        float height = self.navigationController.navigationBar.frame.size.height;
        float width = self.navigationController.navigationBar.frame.size.width/2;
        [self.videoSourceSelectorMenu setFrame:CGRectMake(width, height-25, width, 45)];
        [self.view addSubview:self.videoSourceSelectorMenu];
        [self.videoSourceSelectorMenu setExpanding:YES];
    }
}

- (void) initUgcSourceSelectorView {
    
    NSArray *dataArray = @[
                            @{@"image":@"icon_media",@"title":NSLocalizedString(@"context_menu_item_exist_video", nil)},
                            @{@"image":@"icon_recording",@"title":NSLocalizedString(@"context_menu_item_new_capture", nil)}
                           ];
    NSMutableArray *dropdownItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < dataArray.count; i++) {
        NSDictionary *dict = dataArray[i];
        
        IGLDropDownItem *item = [[IGLDropDownItem alloc] init];
        [item setIconImage:[UIImage imageNamed:dict[@"image"]]];
        [item setText:dict[@"title"]];
        [dropdownItems addObject:item];
    }
    
    float height = self.navigationController.navigationBar.frame.size.height + 20;
    float width = self.navigationController.navigationBar.frame.size.width/2;
    
    self.videoSourceSelectorMenu = [[IGLDropDownMenu alloc] init];
    //self.videoSourceSelectorMenu.menuText = @"Video Source";
    self.videoSourceSelectorMenu.dropDownItems = dropdownItems;
    self.videoSourceSelectorMenu.paddingLeft = 15;
    [self.videoSourceSelectorMenu setFrame:CGRectMake(width, height, width, 45)];
    self.videoSourceSelectorMenu.delegate = self;
    self.videoSourceSelectorMenu.type = IGLDropDownMenuTypeStack;
    self.videoSourceSelectorMenu.gutterY = 5;
    [self.videoSourceSelectorMenu reloadView];
}

- (void)selectedItemAtIndex:(NSInteger)index
{
    //IGLDropDownItem *item = self.videoSourceSelectorMenu.dropDownItems[index];
    [self.videoSourceSelectorMenu setExpanding:NO];
    [self.videoSourceSelectorMenu removeFromSuperview];
    if (index == 0) {
        [self getVideoFromAlbum];
    } else {
        [self captureVideo];
    }
}


#pragma mark - header and footer refresh

- (void)setupHeader
{
    refreshHeader = [SDRefreshHeaderView refreshView];
    refreshHeader4EmptyView = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tableView];
    [refreshHeader4EmptyView addToScrollView:self.emptyView];
    //[refreshHeader addTarget:self refreshAction:@selector(headerRefresh)];
    
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf getMyArchives];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakRefreshHeader endRefreshing];
        });
    };
    
     __weak SDRefreshHeaderView *weakRefreshHeader4EmptyView = refreshHeader4EmptyView;
    refreshHeader4EmptyView.beginRefreshingOperation = ^{
        [weakSelf getMyArchives];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakRefreshHeader4EmptyView endRefreshing];
        });
    };

    // 进入页面自动加载一次数据
    [refreshHeader autoRefreshWhenViewDidAppear];
}

- (void)setupFooter
{
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    //[refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    
    __weak SDRefreshFooterView *weakRefreshFooter = refreshFooter;
    __weak typeof(self) weakSelf = self;
    refreshFooter.beginRefreshingOperation = ^{
        [weakSelf getMyArchives];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakRefreshFooter endRefreshing];
        });
    };
}


//- (void)headerRefresh
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//        [self.refreshFooter endRefreshing];
//    });
//}
//
//- (void)footerRefresh
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//        [self.refreshFooter endRefreshing];
//    });
//}


#pragma mark - dropdown list delegate

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    channelDropListView = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    channelDropListView.delegate = self;
    [channelDropListView showInView:self.tableView animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [channelDropListView SetBackGroundDropDown_R:255.0 G:255.0 B:255.0 alpha:1.0];
    
    NSArray* exitingChannels = self.selectedArchive2Share.channelList;
    if (!isNSNull(exitingChannels)) {
        for (int i=0; i<[channelNameList count]; i++) {
            NSString* channelName = [channelNameList objectAtIndex:i];
            NSString* channelId = [channelListNameAndIdDict objectForKey:channelName];
            if ([exitingChannels containsObject:channelId]) {
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                [channelDropListView.kTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
                [channelDropListView.kTableView.delegate tableView:channelDropListView.kTableView didSelectRowAtIndexPath:path];
            }
        }
    }
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
    [self updateArchivePeroperty:self.selectedArchive2Share.achiveId withChannelIds:ArryData];
}

- (void)DropDownListViewDidCancel{
    
}

- (void)share2Channel {
    [self.channelDropListView fadeOut];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    int w = 315;
    int h = screenHeight - 100;
    int x = (screenWidth - w)/2;
    int y = self.videoSourceSelectorMenu.frame.origin.y+100;
    
    [self showPopUpWithTitle:NSLocalizedString(@"channel_select_title",nil) withOption:channelNameList xy:CGPointMake(x, y) size:CGSizeMake(w, h) isMultiple:YES];
}

#pragma mark - others

- (NSString *)escapeUrl:(NSString *)string
{
    NSMutableCharacterSet *cs = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    //[cs removeCharactersInString:@"?&="];
    return [string stringByAddingPercentEncodingWithAllowedCharacters: cs];
}

- (NSString *)timeFormatted:(long)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = (int)(totalSeconds / 3600);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
