//
//  FavouriteChannelTableViewController.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FavouriteChannelTableViewController : UITableViewController
@property (nonatomic, retain) NSString* channelCount;
@property (nonatomic, retain) UIImage* followBtnNormalBgImg;
@property (nonatomic, retain) UIImage* followBtnFollowedBgImg;
@property (nonatomic, retain) NSMutableArray* channelList;
@property (nonatomic, retain) NSMutableArray* followedChannelObjectList;
@property (nonatomic, retain) NSMutableArray* followChannelIdList;
@property (nonatomic, retain) NSMutableArray* tableViewDataSourceList;

@property (strong, nonatomic) AppDelegate* appDelegate;

-(void) addChannel2FollowList:(NSString*)channelId;
-(void) removeChannelFromeFollowList:(NSString*) channelId;
@end
