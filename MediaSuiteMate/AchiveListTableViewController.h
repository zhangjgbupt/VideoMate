//
//  AchiveListTableViewController.h
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ArchiveTableViewCell.h"
#import "ChannelData.h"
#import "ArchiveData.h"
#import "ArchiveFileData.h"

@interface AchiveListTableViewController : UITableViewController
@property (nonatomic, retain) NSMutableArray* archiveList;
@property (nonatomic, retain) NSString* archiveCount;
@property (nonatomic, retain) ChannelData* channleData;
@property (strong, nonatomic) AppDelegate* appDelegate;
@end
