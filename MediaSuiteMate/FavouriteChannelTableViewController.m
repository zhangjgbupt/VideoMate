//
//  FavouriteChannelTableViewController.m
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "FavouriteChannelTableViewController.h"
#import "ChannelFollowViewCell.h"
#import "ChannelData.h"

@interface FavouriteChannelTableViewController ()
@end

@implementation FavouriteChannelTableViewController

static NSString * const reuseFollowChannelCellIdentifier = @"ChannelFollowCell";

// channleList: original data from channel page.
// followChannelIdList: followed channel id list, only string object save in this array.
// tableViewDataSourceList: just a reference for data source of tableview.
// followedChannelObjectList: followed channels array which save channel object, not just id.
@synthesize channelCount, channelList, followChannelIdList,tableViewDataSourceList,followedChannelObjectList;
@synthesize followBtnNormalBgImg,followBtnFollowedBgImg;
@synthesize appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    followedChannelObjectList = [[NSMutableArray alloc]init];
    tableViewDataSourceList = channelList;
    [self readFollowChannelListFromFile];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.topViewController.title = NSLocalizedString(@"channel_follow_page_title", nil);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChannelFollowViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseFollowChannelCellIdentifier];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    followBtnNormalBgImg = [UIImage imageNamed:@"btn_follow_normal"];
    followBtnFollowedBgImg = [UIImage imageNamed:@"btn_followed_pressed"];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.title=NSLocalizedString(@"channel_follow_edit_btn_text", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveFollowChannelListToFile];
    [super viewWillDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [appDelegate startNetworkConnectionMonitor];
    self.navigationController.topViewController.title = NSLocalizedString(@"channel_follow_page_title", nil);
    [super viewWillAppear:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableViewDataSourceList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChannelFollowViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseFollowChannelCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ChannelData* channelData = [self.tableViewDataSourceList objectAtIndex:indexPath.row];
    UIImage* thumImage = [UIImage imageNamed:@"image_default_bg"];
    NSString* thumUrlString = channelData.firstArchiveThumbnailURL;
    if (thumUrlString!=nil) {
        //if thumnail url is avaliable, just get the image async.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSURL* thumUrl = [NSURL URLWithString:thumUrlString];
            UIImage* thumImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumUrl]];
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [cell.channelThumb setImage:thumImage];
            });
        });
    }
    [cell.channelThumb setImage:thumImage];
    
    cell.channleTitle.text = channelData.name;
    cell.channelOwner.text = channelData.ownerName;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:([channelData.creatTime doubleValue]/ 1000)];
    cell.createDate.text = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    if (channelData.isFollowed) {
        [cell.followBtn setBackgroundImage:followBtnFollowedBgImg forState:UIControlStateNormal];
        [cell.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.followBtn setTitle:NSLocalizedString(@"navigation_channel_follow", nil) forState:UIControlStateNormal];
        
    } else {
        [cell.followBtn setBackgroundImage:followBtnNormalBgImg forState:UIControlStateNormal];
        [cell.followBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cell.followBtn setTitle:NSLocalizedString(@"navigation_channel_follow", nil) forState:UIControlStateNormal];
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (self.tableView.editing) {
        //self.editButtonItem.title = NSLocalizedString(@"channel_follow_edit_btn_text", nil);
    }
    else {
        self.editButtonItem.title = NSLocalizedString(@"channel_follow_edit_btn_text", nil);
    }
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if(editing == YES)
    {
        [followedChannelObjectList removeAllObjects];
        for (ChannelData* data in self.channelList) {
            if (data.isFollowed) {
                [followedChannelObjectList addObject:data];
            }
        }
        self.tableViewDataSourceList = self.followedChannelObjectList;
    } else {
        NSMutableArray* newArray = [self.followedChannelObjectList mutableCopy];
        [self.channelList removeObjectsInArray:self.followedChannelObjectList];
        [newArray addObjectsFromArray:self.channelList];
        self.channelList = newArray;
        self.tableViewDataSourceList = self.channelList;
    }
    [self.tableView reloadData];
    
    [self saveFollowChannelListToFile];
    [super setEditing:editing animated:animated];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    if (fromIndexPath > toIndexPath) {
        for (NSInteger i=fromIndex; i>toIndex; i--) {
            [self.followChannelIdList exchangeObjectAtIndex:i withObjectAtIndex:i-1];
            [followedChannelObjectList exchangeObjectAtIndex:i withObjectAtIndex:i-1];
        }
    } else {
        for (NSInteger j=fromIndex; j<toIndex; j++) {
            [self.followChannelIdList exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            [followedChannelObjectList exchangeObjectAtIndex:j withObjectAtIndex:j+1];
        }
    }
    
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

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

//定义每个UICollectionView 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGRect rectSize = [self.view frame];
//    int width = rectSize.size.width/3;
//    return CGSizeMake(width, width*9/16);
//}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    // Here pass new size you need
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//- (IBAction)longPressGestureRecognized:(id)sender {
//    
//    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
//    UIGestureRecognizerState state = longPress.state;
//    
//    CGPoint location = [longPress locationInView:self.tableView];
//    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
//    
//    ChannelData* channelData = [self.channelList objectAtIndex:indexPath.row];
//    if (!channelData.isFollowed) {
//        return;
//    }
//    
//    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
//    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
//    
//    switch (state) {
//        case UIGestureRecognizerStateBegan: {
//            if (indexPath) {
//                sourceIndexPath = indexPath;
//                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//                
//                // Take a snapshot of the selected row using helper method.
//                snapshot = [self customSnapshoFromView:cell];
//                
//                // Add the snapshot as subview, centered at cell's center...
//                __block CGPoint center = cell.center;
//                snapshot.center = center;
//                snapshot.alpha = 0.0;
//                [self.tableView addSubview:snapshot];
//                [UIView animateWithDuration:0.25 animations:^{
//                    
//                    // Offset for gesture location.
//                    center.y = location.y;
//                    snapshot.center = center;
//                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
//                    snapshot.alpha = 0.98;
//                    cell.alpha = 0.0;
//                    
//                } completion:^(BOOL finished) {
//                    
//                    cell.hidden = YES;
//                    
//                }];
//            }
//            break;
//        }
//            
//        case UIGestureRecognizerStateChanged: {
//            CGPoint center = snapshot.center;
//            center.y = location.y;
//            snapshot.center = center;
//            
//            // Is destination valid and is it different from source?
//            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
//                
//                // ... update data source.
//                [self.followChannelIdList exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
//                
//                // ... move the rows.
//                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
//                
//                // ... and update source so it is in sync with UI changes.
//                sourceIndexPath = indexPath;
//            }
//            break;
//        }
//            
//        default: {
//            // Clean up.
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
//            cell.hidden = NO;
//            cell.alpha = 0.0;
//            
//            [UIView animateWithDuration:0.25 animations:^{
//                
//                snapshot.center = cell.center;
//                snapshot.transform = CGAffineTransformIdentity;
//                snapshot.alpha = 0.0;
//                cell.alpha = 1.0;
//                
//            } completion:^(BOOL finished) {
//                
//                sourceIndexPath = nil;
//                [snapshot removeFromSuperview];
//                snapshot = nil;
//                
//            }];
//            
//            break;
//        }
//    }
//}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - read and write follow channle

- (bool)saveFollowChannelListToFile {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"follow_channel.plist"];
    NSLog(@"follow channle file path: %@", filePath);

    BOOL success = [self.followChannelIdList writeToFile:filePath atomically:YES];
    if(success) {
        return true;
    } else {
        return false;
    }
    
}

-(bool) readFollowChannelListFromFile {
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory ,NSUserDomainMask, YES);
    NSString *documentsDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"follow_channel.plist"];
    NSLog(@"follow channle file path: %@", filePath);
    self.followChannelIdList = [NSMutableArray arrayWithContentsOfFile:filePath];
    if(self.followChannelIdList) {
        return false;
    } else {
        return true;
    }
}

-(void) addChannel2FollowList:(NSString*) channelId {
    if (self.followChannelIdList == nil) {
        self.followChannelIdList = [[NSMutableArray alloc]init];
    }
    [self.followChannelIdList addObject:channelId];
}

-(void) removeChannelFromeFollowList:(NSString*) channelId {
    if (self.followChannelIdList == nil || [self.followChannelIdList count]==0) {
        return;
    }
    for (int i=0; i<[self.followChannelIdList count]; i++) {
        NSString* id = [self.followChannelIdList objectAtIndex:i];
        if ([channelId isEqualToString:id]) {
            [self.followChannelIdList removeObjectAtIndex:i];
        }
    }
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
