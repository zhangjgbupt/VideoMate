//
//  ChannelGridViewCollectionViewController.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SDRefresh.h"

@interface ChannelCollectionViewController : UICollectionViewController
@property (nonatomic, retain) NSMutableArray* channelList;
@property (nonatomic, retain) NSMutableArray* sortedChannelList;
@property (nonatomic, retain) NSString* channelCount;
@property (nonatomic, retain) UIBarButtonItem *channelFollowButton;

@property (nonatomic, strong) SDRefreshFooterView *refreshFooter;
@property (nonatomic, strong) SDRefreshHeaderView *refreshHeader;

@property (nonatomic, retain) AppDelegate* appDelegate;
@end
