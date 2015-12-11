//
//  MyMediaViewController.h
//  MediaSuiteMate
//
//  Created by derek on 23/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ArchiveTableViewCell.h"
#import "ChannelData.h"
#import "ArchiveData.h"
#import "ArchiveFileData.h"
#import "IGLDropDownMenu.h"
#import "SDRefresh.h"
#import "DropDownListView.h"

@interface LiveViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *emptyView;
@property (strong, nonatomic) IBOutlet UILabel *emptyVideoTitle;
@property (strong, nonatomic) IBOutlet UILabel *emptyVideoDetail;

@property (nonatomic, retain) NSMutableArray* liveList;
@property (nonatomic, retain) NSString* liveCount;
@property (nonatomic, retain) NSURL *videoURL;
@property (strong, nonatomic) IBOutlet UIImageView *emptyVideoImg;

@property int currentPageIndex;
@property int maxPageNumber;

@property (nonatomic, strong) IGLDropDownMenu *videoSourceSelectorMenu;
@property (strong, nonatomic) DropDownListView * channelDropListView;
@property (strong, nonatomic) NSMutableArray* channelNameList;
@property (strong, nonatomic) NSMutableDictionary * channelListNameAndIdDict;
@property (strong, nonatomic) ArchiveData* selectedArchive2Share;
@property BOOL isUploadClick;

@property (nonatomic, strong) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, strong) SDRefreshHeaderView *refreshHeader4EmptyView;

@property (nonatomic,assign) AppDelegate* appDelegate;



@end
