//
//  LiveViewContorller.m
//  VideoMate
//
//  Created by Chris Ling on 15/12/1.
//  Copyright © 2015年 derek. All rights reserved.
//

#import "LiveViewController.h"
#import "MediaPlayerViewController.h"
#import "LiveData.h"
#import "LiveTableViewCell.h"
#import "LivePlayerViewController.h"

@interface LiveViewController ()

@end

@implementation LiveViewController
@synthesize maxPageNumber, currentPageIndex;
@synthesize appDelegate;
@synthesize emptyVideoImg, emptyVideoTitle, emptyVideoDetail;
@synthesize refreshHeader, refreshHeader4EmptyView;
@synthesize liveList,liveCount;

static NSString * const reuseArchiveIdentifier = @"LiveCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageIndex = 0;
    self.maxPageNumber = 0;
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = screenFrame.size.width;
    tableViewFrame.size.height = screenFrame.size.height-66;
    [self.tableView setFrame:tableViewFrame];
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LiveTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseArchiveIdentifier];
    
    [self.emptyView setFrame:tableViewFrame];
    [self.emptyView setScrollEnabled:YES];
    [(UIScrollView *)self.emptyView setContentSize:CGSizeMake(tableViewFrame.size.width, tableViewFrame.size.height+1)];

    
    CGRect emptyViewFrame = self.emptyView.frame;
    CGFloat viewWidth = emptyViewFrame.size.width;
    CGFloat viewHeight = emptyViewFrame.size.height;
    
    CGFloat empty_img_x = viewWidth/8;
    CGFloat empty_img_y = viewHeight/3;
    CGFloat empty_img_w = viewWidth*3/4;
    CGFloat empty_img_h = empty_img_w*3/5;
    [self.emptyVideoImg setFrame:CGRectMake(empty_img_x, empty_img_y, empty_img_w, empty_img_h)];
    
    CGFloat empty_title_x = viewWidth/5;
    CGFloat empty_title_y = empty_img_y + empty_img_h + 10;
    CGFloat empty_title_w = viewWidth*3/5;
    CGFloat empty_title_h = 20;
    [self.emptyVideoTitle setFrame:CGRectMake(empty_title_x, empty_title_y, empty_title_w, empty_title_h)];
    [self.emptyVideoTitle setText:NSLocalizedString(@"no_live_title", nil)];
    
    CGFloat empty_detail_x = viewWidth/5;
    CGFloat empty_detail_y = empty_img_y + empty_img_h + 10 + 20;
    CGFloat empty_detail_w = viewWidth*3/5;
    CGFloat empty_detail_h = 20;
    [self.emptyVideoDetail setFrame:CGRectMake(empty_detail_x, empty_detail_y, empty_detail_w, empty_detail_h)];
    [self.emptyVideoDetail setText:NSLocalizedString(@"no_live_info", nil)];
    
    [self.emptyView addSubview:emptyVideoImg];
    [self.emptyView addSubview:emptyVideoTitle];
    [self.emptyView addSubview:emptyVideoDetail];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyView];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.topViewController.title = NSLocalizedString(@"my_live_page_title", nil);
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMyLives)
                                                 name:@"UPDATE_PEROPERTY_SUCCESS"
                                               object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.liveList = [[NSMutableArray alloc]init];
    [self setupHeader];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate startNetworkConnectionMonitor];
    //[self getMyArchives];
    [appDelegate.tabBarController setTabBarHidden:NO];
    [super viewWillAppear:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.liveList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseArchiveIdentifier forIndexPath:indexPath];
    LiveData* live = [self.liveList objectAtIndex:indexPath.row];
    NSString* thumUrlString = live.coverUrl;
    UIImage* thumImage = [UIImage imageNamed:@"img"];
    if (thumUrlString!=nil) {
        //if thumnail url is avaliable, just get the image async.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSURL* thumUrl = [NSURL URLWithString:thumUrlString];
            UIImage* thumImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumUrl]];
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [cell.liveThum setImage:thumImage];
            });
        });
    }
    
    CGFloat w = cell.frame.size.width;
    CGFloat thum_w = w - 20;
    CGFloat thum_h = thum_w*9/16;
    
    [cell.liveThum setFrame:CGRectMake(10, 10, thum_w, thum_h)];
    [cell.liveThum setImage:thumImage];
    [cell.subject setText:live.subject];
    [cell.subject setTextColor:[UIColor whiteColor]];
    
    UIImage *backBarImg = [UIImage imageNamed:@"bg_title"];
    CGFloat backBar_w = thum_w;
    CGFloat backBar_h = backBar_w*7/32;
    CGFloat backBar_y = 10+thum_h-backBar_h;
    [cell.backBar setFrame:CGRectMake(10, backBar_y, backBar_w, backBar_h)];
    [cell.backBar setImage:backBarImg];

    
    [cell.subject setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:18.0]];

    if (live.creatTime == nil) {
        [cell.liveCreateTime setText:@""];
    } else {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:([live.creatTime doubleValue]/ 1000)];
        [cell.liveCreateTime setTextColor:[UIColor grayColor]];
        [cell.liveCreateTime setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:14.0]];
        [cell.liveCreateTime setText:[NSDateFormatter localizedStringFromDate:date
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterShortStyle]];
    }
    
    [cell.subject setFrame:CGRectMake(20, backBar_y, thum_w, backBar_h/2)];
    [cell.liveCreateTime setFrame:CGRectMake(20, backBar_y+backBar_h/2, thum_w, backBar_h/2)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat imageWidth = screenWidth - 40;
    CGFloat imageHight = imageWidth*9/16;
    //title height = 30px
    CGFloat cellHeight = imageHight + 30 ;
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveData* live = [self.liveList objectAtIndex:indexPath.row];
    LivePlayerViewController* livePlayer = [[LivePlayerViewController alloc]init];
    [livePlayer setCallID:live.callId];
    [livePlayer setSubject:live.subject];
    [livePlayer setCreateTime:live.creatTime];
    [livePlayer setDescription:live.description];
    [livePlayer setIsEasyCapture:live.isEasyCapture];
    [self.navigationController pushViewController:livePlayer animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        [weakSelf getMyLives];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakRefreshHeader endRefreshing];
        });
    };
    
    __weak SDRefreshHeaderView *weakRefreshHeader4EmptyView = refreshHeader4EmptyView;
    refreshHeader4EmptyView.beginRefreshingOperation = ^{
        [weakSelf getMyLives];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakRefreshHeader4EmptyView endRefreshing];
        });
    };
    
    // 进入页面自动加载一次数据
    [refreshHeader autoRefreshWhenViewDidAppear];
}

#pragma mark - restapi

- (void) getMyLives {
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/lives/visible", appDelegate.svrAddr];
    requestStr = [self escapeUrl:requestStr];
    
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-content-user-call-list+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-user-call-list+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-content-user-call-list+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    [manager GET:requestStr parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *liveObject = responseObject;
             [self.liveList removeAllObjects];
             
             NSArray *callList = liveObject[@"plcm-content-call-info"];
             NSArray *easyList = liveObject[@"plcm-content-easy-stream-info"];
             
             for (int i=0; i<[callList count]; i++) {
                 NSDictionary *callData = callList[i];
                 LiveData *livedata = [[LiveData alloc] init];
                 livedata.isEasyCapture = NO;
                 livedata.callId = callData[@"callId"];
                 livedata.subject = callData[@"subject"];
                 livedata.creatTime = callData[@"startCallTime"];
                 livedata.description = callData[@"description"];
                 if ((isNSNull(callData[@"coverUrl"])) || callData[@"coverUrl"]==nil) {
                     livedata.coverUrl = nil;
                 } else {
                     livedata.coverUrl = callData[@"coverUrl"];
                     livedata.coverUrl = [livedata.coverUrl stringByReplacingOccurrencesOfString:@"{port}" withString:@"8888"];
                     livedata.coverUrl = [NSString stringWithFormat:@"http://%@", livedata.coverUrl];
                 }
                 
                 [self.liveList addObject:livedata];
             }
             
             for (int j=0; j<[easyList count]; j++) {
                 NSDictionary *easyData = easyList[j];
                 LiveData *livedata = [[LiveData alloc] init];
                 livedata.isEasyCapture = YES;
                 livedata.callId = easyData[@"eventId"];
                 livedata.description = easyData[@"description"];
                 livedata.subject = easyData[@"subject"];
                 //livedata.creatTime = @"";
                 livedata.coverUrl = nil;
                 
                 [self.liveList addObject:livedata];
                 
             }
             
             if ([self.liveList count]==0) {
                 for (UIView *subView in self.view.subviews) {
                     if([subView isKindOfClass:[UITableView class]]) {
                         [subView removeFromSuperview];
                     }
                 }
                 [self.view addSubview:self.emptyView];
             } else {
                 [self.view addSubview:self.tableView];
                 [self.tableView reloadData];
             }
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get Channle List Failed!");
             NSLog(@"Error: %@", error.description);
         }];

}

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
