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

@interface MyMediaViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,IGLDropDownMenuDelegate>
@property (nonatomic, retain) NSMutableArray* archiveList;
@property (nonatomic, retain) NSString* archiveCount;
@property (nonatomic, retain) UIBarButtonItem *uploadButton;
@property (nonatomic, retain) NSURL *videoURL;

@property int currentPageIndex;
@property int maxPageNumber;

@property (nonatomic, strong) IGLDropDownMenu *videoSourceSelectorMenu;
@property BOOL isUploadClick;

@property (nonatomic, strong) SDRefreshFooterView *refreshFooter;
@property (nonatomic, strong) SDRefreshHeaderView *refreshHeader;

@property (strong, nonatomic) AppDelegate* appDelegate;



@end
