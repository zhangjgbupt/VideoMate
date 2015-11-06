//
//  AchiveListTableViewController.m
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "AchiveListTableViewController.h"
#import "AppDelegate.h"
#import "MediaPlayerViewController.h"

#define isNSNull(value) [value isKindOfClass:[NSNull class]]

@interface AchiveListTableViewController ()

@end

@implementation AchiveListTableViewController
@synthesize archiveCount, archiveList,channleData;

static NSString * const reuseArchiveIdentifier = @"ArchiveCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArchiveTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseArchiveIdentifier];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.topViewController.title = [NSString stringWithFormat:NSLocalizedString(@"archive_page_title", nil)];
    self.archiveList = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate startNetworkConnectionMonitor];
    self.navigationController.topViewController.title = [NSString stringWithFormat:NSLocalizedString(@"archive_page_title", nil)];
    [self getArchiveCountInChannel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
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
                [cell.archiveThum setImage:thumImage];
            });
        });
    }
    
    CGFloat w = cell.frame.size.width;
    CGFloat thum_w = w -40;
    CGRect frame = cell.archiveThum.frame;
    [cell.archiveThum setFrame:CGRectMake(frame.origin.x, frame.origin.y, thum_w, frame.size.height)];
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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    ArchiveData* archive = [self.archiveList objectAtIndex:indexPath.row];
    NSMutableArray* episodeFiles = archive.archiveFiles;
    MediaPlayerViewController* mediaPlayer = [[MediaPlayerViewController alloc]init];
    [mediaPlayer setFiles:episodeFiles];
    [mediaPlayer setArchiveName:archive.displayName];
    [mediaPlayer setArchiveDes:archive.description];
    [mediaPlayer setLikeCount:archive.likeCount];
    [mediaPlayer setArchiveId:archive.achiveId];
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
-(void) setChannelData:(ChannelData*)data {
    self.channleData = data;
}

- (NSString *)timeFormatted:(long)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

-(void) getArchivesInChannle {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (self.archiveCount == nil) {
        self.archiveCount = @"5";
    }
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentChannels/%@/archives/?startIndex=0&pageSize=%@&sort=TIME", appDelegate.svrAddr, self.channleData.channelId, self.archiveCount];
    
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
             NSArray* archiveArray = responseObject;
             
             if(archiveArray!=nil && [archiveArray count]>0) {
                 //if get channel successful, remove the older.
                 [self.archiveList removeAllObjects];
             }
             
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
                 
                 NSNumber* likedCount = archiveOrigialData[@"likeCount"];
                 archiveObj.likeCount = [likedCount stringValue];
                 
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
                         [archiveObj.archiveFiles addObject:fileData];
                     }
                 }
                 
                [self.archiveList addObject:archiveObj];
             }
             [self.tableView reloadData];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get Channle List Failed!");
             NSLog(@"Error: %@", error.description);
         }];
    
}

-(void) getArchiveCountInChannel {
    
    if(self.channleData == nil) {
        return;
    }
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/userportal/api/rest/contentChannels/%@/archives/count", appDelegate.svrAddr, channleData.channelId];
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
             self.archiveCount = [responseObject valueForKey:@"count"];
             [self getArchivesInChannle];
         }
         failure:^(AFHTTPRequestOperation* task, NSError* error){
             NSLog(@"Get archive Count Failed!");
             NSLog(@"Error: %@", error.description);
         }];
}

@end
