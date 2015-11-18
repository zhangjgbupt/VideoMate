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
@synthesize channelList, channelCount,sortedChannelList;
@synthesize channelFollowButton;
@synthesize refreshFooter, refreshHeader;
@synthesize appDelegate;

static NSString * const reuseChannelIdentifier = @"channelCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    channelList = [NSMutableArray array];
    sortedChannelList = [NSMutableArray array];
    
    self.navigationController.topViewController.title = NSLocalizedString(@"channel_page_title", nil);
    self.navigationItem.backBarButtonItem = nil;
    channelFollowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_follow"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(go2ChannelFollowPage)];
    
    self.navigationItem.rightBarButtonItem = channelFollowButton;
    
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
    
    //[self getContributeChannleCount];
    [self setupHeader];
    //[self setupFooter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate startNetworkConnectionMonitor];
    //[self getContributeChannleCount];
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
    return [self.sortedChannelList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseChannelIdentifier forIndexPath:indexPath];
    ChannelData* channelData = [self.sortedChannelList objectAtIndex:indexPath.row];
    CGFloat image_w = cell.frame.size.width;
    CGFloat image_h = image_w*9/16;
    cell.channelThum.frame = CGRectMake(0, 30, image_w, image_h);
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

    CGFloat titleWidth = thumbRectSize.size.width*3/4;
    CGRect titleRectSize = CGRectMake(cell.channelTitle.frame.origin.x,
                                      cell.channelTitle.frame.origin.y,
                                      titleWidth,
                                      cell.channelTitle.frame.size.height);
    [cell.channelTitle setFrame:titleRectSize];
    NSString* title = NSLocalizedString(@"channel_page_title_text", nil);
    title = [NSString stringWithFormat:@"%@%@", title,channelData.name];
    [cell.channelTitle setText:title];
    
    NSString* itemNum = [NSString stringWithFormat:@"(%@ %@)", channelData.contentCount,NSLocalizedString(@"item_count", nil)];
    CGFloat countLabelWidth = thumbRectSize.size.width/4;
    CGRect countRectSize = CGRectMake(cell.channelTitle.frame.origin.x+titleWidth-1,
                                      cell.itemNum.frame.origin.y,
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
    //title height = 30 px
    CGFloat cellHeight = imageHeight + 30;
    
    return CGSizeMake(cellWidth, cellHeight);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void) getContributeChannle {
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

-(void) getContributeChannleCount {
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
             [self getContributeChannle];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get Channle Count Failed!");
             NSLog(@"Error: %@", error.description);
         }];
}

-(void) sortChannels {
    [self.sortedChannelList removeAllObjects];
    NSMutableArray* followedChannels = [self readFollowChannelListFromFile];
    NSString* followedChannelId=nil;
    for (followedChannelId in followedChannels) {
        NSUInteger originalChannelCount =[self.channelList count];
        for (int i=0; i<originalChannelCount; i++) {
            ChannelData* originalChannel = [self.channelList objectAtIndex:i];
            if ([originalChannel.channelId isEqualToString:followedChannelId]) {
                originalChannel.isFollowed=true;
                [self.sortedChannelList addObject:originalChannel];
            }
        }
    }
    [self.channelList removeObjectsInArray:self.sortedChannelList];
    [self.sortedChannelList addObjectsFromArray:self.channelList];
}

-(NSMutableArray*) readFollowChannelListFromFile {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"follow_channel.plist"];
    NSLog(@"follow channle file path: %@", filePath);
    NSMutableArray* followedChannels = [NSMutableArray arrayWithContentsOfFile:filePath];
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

#pragma mark - header and footer refresh
- (void)setupHeader
{
    refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.collectionView];
    //[refreshHeader addTarget:self refreshAction:@selector(headerRefresh)];
    
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf getContributeChannleCount];
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
        [weakSelf getContributeChannleCount];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[weakSelf sortChannels];
            //[weakSelf.collectionView reloadData];
            [weakRefreshFooter endRefreshing];
        });
    };
}

- (void) refreshChannelListCollectView {
    [self sortChannels];
    [self.collectionView reloadData];
}
@end
