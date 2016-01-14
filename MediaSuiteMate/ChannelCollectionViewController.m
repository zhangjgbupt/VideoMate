//
//  ChannelGridViewCollectionViewController.m
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "ChannelCollectionViewController.h"
#import "ChannelCollectionViewCell.h"
#import "ChannelData.h"
#import "AchiveListTableViewController.h"
#import "LoginViewController.h"
#import "FavouriteChannelTableViewController.h"

@interface ChannelCollectionViewController ()

@end

@implementation ChannelCollectionViewController
@synthesize channelList, channelCount,sortedChannelList, channleFollowStatusCheckNumber, followedChannelCount, isOnlyDisplayFollowedChannel;
@synthesize refreshFooter, refreshHeader;
@synthesize appDelegate;

static NSString * const reuseChannelIdentifier = @"channelCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    channelList = [NSMutableArray array];
    sortedChannelList = [NSMutableArray array];
    
    isOnlyDisplayFollowedChannel = FALSE;
    [self.appDelegate setShouldRotate:NO];
    
    self.navigationController.topViewController.title = NSLocalizedString(@"channel_page_title", nil);
    self.navigationItem.backBarButtonItem = nil;
    UIBarButtonItem* channelFollowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_management"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(go2ChannelFollowPage)];
  
    UIBarButtonItem* channelListSwitchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_follow"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(switchChannelListDataSource)];
    
    self.navigationItem.rightBarButtonItem = channelFollowButton;
    self.navigationItem.leftBarButtonItem = channelListSwitchButton;
    
    
    NSMutableArray *childViewControllers = [[NSMutableArray alloc] initWithArray: appDelegate.navController.viewControllers];
    if ([[childViewControllers objectAtIndex:0] isKindOfClass:[LoginViewController class]]) {
        [childViewControllers removeObjectAtIndex:0];
    }
    appDelegate.navController.viewControllers = childViewControllers;
    
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[ChannelCollectionViewCell class] forCellWithReuseIdentifier:reuseChannelIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ChannelCollectionViewCell"
                                                    bundle:[NSBundle mainBundle]]
                                forCellWithReuseIdentifier:reuseChannelIdentifier];
    
    [self setupHeader];
    //[self setupFooter];
    
    //在这里向ms服务器注册可以确保登录已成功， 如果apnsClientId不位nil，说明在该view到生成之前已经成功获得，直接注册即可。
    if (appDelegate.apnsClientId != nil) {
        [appDelegate register2apns];
    }
    
    //当apnsClientId生成较晚（在程序跳转到该view之后获得），该程序段可以确保向ms服务器注册。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(register2apns)
                                                      name:@"GET_CLIENT_ID_SUCCESS"
                                                    object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate startNetworkConnectionMonitor];
    //[self getContributeChannleCount];
    [appDelegate.tabBarController setTabBarHidden:NO];
    [self.appDelegate setShouldRotate:NO];
    [super viewWillAppear:YES];
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (isOnlyDisplayFollowedChannel) {
        return self.followedChannelCount;
    } else {
        return [self.sortedChannelList count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseChannelIdentifier forIndexPath:indexPath];
    ChannelData* channelData = [self.sortedChannelList objectAtIndex:indexPath.row];
    CGFloat image_w = cell.frame.size.width-4;
    CGFloat image_h = image_w*9/16-2;
    cell.channelThum.frame = CGRectMake(2, 2, image_w-2, image_h-2);
    [cell.channelThum setContentMode:UIViewContentModeScaleToFill];
    NSString* thumUrlString = channelData.firstArchiveThumbnailURL;
    UIImage* thumImage = [UIImage imageNamed:@"image_default_bg"];
    
    if (thumUrlString!=nil) {
        //if thumnail url is avaliable, just get the image async.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSURL* thumUrl = [NSURL URLWithString:thumUrlString];
            UIImage* thumImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumUrl]];
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [cell.channelThum setImage:thumImage];
            });
        });
    }
    
    CGRect thumbRectSize = [cell.channelThum frame];
    [cell.channelThum setImage:thumImage];
    
    CGFloat title_bg_x = thumbRectSize.origin.x;
    CGFloat title_bg_y = thumbRectSize.origin.x + thumbRectSize.size.height-40;
    CGFloat title_bg_w = thumbRectSize.size.width;
    CGFloat title_bg_h = 40;
    CGRect titleBgSize = CGRectMake(title_bg_x, title_bg_y, title_bg_w, title_bg_h);
    [cell.titleBackground setFrame:titleBgSize];

    CGFloat titleWidth = thumbRectSize.size.width*3/5;
    CGFloat title_x = thumbRectSize.size.width/10;
    CGFloat title_y = thumbRectSize.size.height-25;
    CGRect titleRectSize = CGRectMake(title_x,
                                      title_y,
                                      titleWidth,
                                      cell.channelTitle.frame.size.height);
    [cell.channelTitle setFrame:titleRectSize];
    NSString* title = [NSString stringWithFormat:@"%@",channelData.name];
    [cell.channelTitle setText:title];
    
    NSString* itemNum = [NSString stringWithFormat:@"(%@ %@)", channelData.contentCount,NSLocalizedString(@"item_count", nil)];
    CGFloat countLabelWidth = thumbRectSize.size.width*3/10;
    CGFloat countLabel_x = thumbRectSize.size.width*7/10;
    CGFloat countLable_y = title_y;
    CGRect countRectSize = CGRectMake(countLabel_x,
                                      countLable_y,
                                      countLabelWidth,
                                      cell.itemNum.frame.size.height);
    [cell.itemNum setFrame:countRectSize];
    [cell.itemNum setText:itemNum];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.backgroundColor = [UIColor redColor];
    NSLog(@"touched cell %@ at indexPath %@", cell, indexPath);
    AchiveListTableViewController* archiveListViewController = [[AchiveListTableViewController alloc]init];
    [archiveListViewController setChannleData:[self.sortedChannelList objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:archiveListViewController animated:YES];
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rectSize = [self.view frame];
    CGFloat cellWidth = rectSize.size.width/2-1;
    CGFloat imageWidth = cellWidth;
    CGFloat imageHeight = imageWidth*9/16;
    CGFloat cellHeight = imageHeight;
    
    return CGSizeMake(cellWidth, cellHeight);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void) getContentChannels {
    if (self.channelCount == nil) {
        self.channelCount = @"10";
    }

    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentChannels/?startIndex=0&pageSize=%@&sort=TIME", appDelegate.svrAddr, self.channelCount];
    
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
                  [channelList removeAllObjects];
              }
              for (int i=0; i<[channelArray count]; i++) {
                  NSDictionary* channelOrigialData = channelArray[i];
                  ChannelData* channelObj = [[ChannelData alloc]init];
                  channelObj.channelId = channelOrigialData[@"channelId"];
                  channelObj.name = channelOrigialData[@"name"];
                  channelObj.description = channelOrigialData[@"description"];
                  channelObj.creatTime = channelOrigialData[@"createTime"];
                  channelObj.viewCount = channelOrigialData[@"viewCount"];
                  channelObj.contentCount = channelOrigialData[@"contentCount"];
                  channelObj.updateTime = channelOrigialData[@"updateTime"];
                  channelObj.ownerName = channelOrigialData[@"ownerName"];
                  channelObj.firstArchiveId = channelOrigialData[@"firstArchiveId"];
                  channelObj.firstArchiveThumbnailURL = channelOrigialData[@"firstArchiveThumbnailURL"];
                  
                  if (isNSNull(channelOrigialData[@"firstArchiveThumbnailURL"])) {
                      channelObj.firstArchiveThumbnailURL = nil;
                  } else {
                      channelObj.firstArchiveThumbnailURL = [channelObj.firstArchiveThumbnailURL stringByReplacingOccurrencesOfString:@"{port}"
                                                                                                                           withString:@"8888"];
                      channelObj.firstArchiveThumbnailURL = [NSString stringWithFormat:@"http://%@", channelObj.firstArchiveThumbnailURL];
                  }
                  [channelList addObject:channelObj];
              }
              [self refreshChannelListCollectView];
          }
          failure:^(AFHTTPRequestOperation* task, NSError* error){
              NSLog(@"Get Channle List Failed!");
              NSLog(@"Error: %@", error.description);
          }];

}

-(void) getContentChannelCount {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentChannels/count", appDelegate.svrAddr];
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-count+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-count+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-count+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.channelCount = [responseObject valueForKey:@"count"];
             [self getContentChannels];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get Channle Count Failed!");
             NSLog(@"Error: %@", error.description);
         }];
}

-(void) getFollowStatus:(ChannelData*) channelData {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentChannels/%@/subscribeStatus", appDelegate.svrAddr, channelData.channelId];
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
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSNumber* flag = [responseObject valueForKey:@"flag"];
             if ([flag intValue]==1) {
                 channelData.isFollowed = true;
             } else {
                 channelData.isFollowed = false;
             }
             
             channleFollowStatusCheckNumber ++;
             if (channleFollowStatusCheckNumber == [self.channelList count]) {
               [[NSNotificationCenter defaultCenter] postNotificationName:@"FOLLOW_STATUS_CHECK_COMPLETE" object:nil];
             }
             
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get subscribe status Failed!");
             NSLog(@"Error: %@", error.description);
             channleFollowStatusCheckNumber ++;
             if (channleFollowStatusCheckNumber == [self.channelList count]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FOLLOW_STATUS_CHECK_COMPLETE" object:nil];
             }
         }];
}

-(void) sortChannels {
    [self.sortedChannelList removeAllObjects];
    
    // there followed status maybe change not by app, by browser for example,
    // so we need double check the channel id is still in followed list.
    NSMutableArray* notFollowedChannelIds = [[NSMutableArray alloc]init];
    
    // followed channel id list, which is store in local and sorted.
    NSMutableArray* followedChannels = [self readFollowChannelListFromFile];
    
    NSString* followedChannelId=nil;
    for (followedChannelId in followedChannels) {
        bool isStillFollowed = false;
        NSUInteger originalChannelCount =[self.channelList count];
        for (int i=0; i<originalChannelCount; i++) {
            ChannelData* originalChannel = [self.channelList objectAtIndex:i];
            if (([originalChannel.channelId isEqualToString:followedChannelId]) && (originalChannel.isFollowed)) {
                [self.sortedChannelList addObject:originalChannel];
                isStillFollowed = true;
            }
        }
        if (!isStillFollowed) {
            [notFollowedChannelIds addObject:followedChannelId];
        }
    }
    // remove all the channels which not followed already, remove from followed list and re-save to local file.
    [followedChannels removeObjectsInArray: notFollowedChannelIds];
    
    //remove all followed channle from original channel list.
    [self.channelList removeObjectsInArray:self.sortedChannelList];
    
    // find the followed channel in original channles which is not in local file.
    NSMutableArray* followedChannelNotInLocalFile = [[NSMutableArray alloc]init];
    for (ChannelData* channel in self.channelList) {
        if (channel.isFollowed) {
            [followedChannelNotInLocalFile addObject:channel];
            [followedChannels addObject:channel.channelId];
        }
    }
    [self saveFollowChannelListToFile:followedChannels];
    self.followedChannelCount = [followedChannels count];
    
    [self.sortedChannelList addObjectsFromArray:followedChannelNotInLocalFile];
    
    //remove all followed channle from original channel list.
    [self.channelList removeObjectsInArray:self.sortedChannelList];
    [self.sortedChannelList addObjectsFromArray:self.channelList];
}

- (bool)saveFollowChannelListToFile:(NSMutableArray*)channelIds {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"follow_channel.plist"];
    NSLog(@"follow channle file path: %@", filePath);
    
    BOOL success = [channelIds writeToFile:filePath atomically:YES];
    if(success) {
        return true;
    } else {
        return false;
    }
}

-(NSMutableArray*) readFollowChannelListFromFile {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"follow_channel.plist"];
    NSLog(@"follow channle file path: %@", filePath);
    NSMutableArray* followedChannels = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (followedChannels==nil) {
        followedChannels = [[NSMutableArray alloc]init];
    }
    return followedChannels;
}

//-(void) refreshChannelListUiView {
//    [self.collectionView reloadData];
//}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    // Here pass new size you need
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)go2ChannelFollowPage {
    FavouriteChannelTableViewController* followChannelViewController = [[FavouriteChannelTableViewController alloc]init];
    followChannelViewController.channelCount = self.channelCount;
    followChannelViewController.channelList = [self.sortedChannelList mutableCopy];
    [self.navigationController pushViewController:followChannelViewController animated:YES];
}

-(void)switchChannelListDataSource {
    
    if (self.isOnlyDisplayFollowedChannel) {
        self.isOnlyDisplayFollowedChannel = FALSE;
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"icon_follow"]];
    } else {
        self.isOnlyDisplayFollowedChannel = TRUE;
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"icon_followed"]];
    }
    [self.collectionView reloadData];
}

#pragma mark - header and footer refresh
- (void)setupHeader
{
    refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.collectionView];
    //[refreshHeader addTarget:self refreshAction:@selector(headerRefresh)];
    
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf getContentChannelCount];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[weakSelf sortChannels];
            //[weakSelf.collectionView reloadData];
            [weakRefreshHeader endRefreshing];
        });
    };
    
    // 进入页面自动加载一次数据
    [refreshHeader autoRefreshWhenViewDidAppear];
}

- (void)setupFooter
{
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.collectionView];
    //[refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    
    __weak SDRefreshFooterView *weakRefreshFooter = refreshFooter;
    __weak typeof(self) weakSelf = self;
    refreshFooter.beginRefreshingOperation = ^{
        [weakSelf getContentChannelCount];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[weakSelf sortChannels];
            //[weakSelf.collectionView reloadData];
            [weakRefreshFooter endRefreshing];
        });
    };
}

- (void) refreshChannelListCollectView {
    [self refreshChannelFollowStatus];
}

-(void) onFollowStatusComplete {
    [self sortChannels];
    [self.collectionView reloadData];
}

-(void) refreshChannelFollowStatus {
    channleFollowStatusCheckNumber = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FOLLOW_STATUS_CHECK_COMPLETE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFollowStatusComplete)
                                                 name:@"FOLLOW_STATUS_CHECK_COMPLETE"
                                               object:nil];
    for (int i=0; i<[self.channelList count]; i++) {
        ChannelData* channel = [self.channelList objectAtIndex:i];
        [self getFollowStatus:channel];
    }
}

-(void)register2apns{
    [self.appDelegate register2apns];
}
@end
