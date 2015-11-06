//
//  ChannelFollowViewCell.m
//  MediaSuiteMate
//
//  Created by derek on 22/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "ChannelFollowViewCell.h"
#import "GlobalMacroDefine.h"
#import "FavouriteChannelTableViewController.h"
#import "ChannelData.h"

@implementation ChannelFollowViewCell
@synthesize channelOwner, channleTitle, createDate, followBtn, channelThumb;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onFollowBtnClick:(id)sender {
    UIImage* followBtnNormalBgImg = [UIImage imageNamed:@"btn_follow_normal"];
    UIImage* followBtnFollowedBgImg = [UIImage imageNamed:@"btn_followed_pressed"];
    
    UITableView* parent = [self parentTableView];
    FavouriteChannelTableViewController* viewController = (FavouriteChannelTableViewController*)(parent.dataSource);
   
    NSMutableArray* channelList = viewController.channelList;
    long channelIndex = [parent indexPathForCell:self].row;
    ChannelData* data = [channelList objectAtIndex:channelIndex];
    UIButton *button = (UIButton *)sender;
    if (data.isFollowed) {
        [button setBackgroundImage:followBtnNormalBgImg forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        data.isFollowed = false;
        [viewController removeChannelFromeFollowList :data.channelId];
    } else {
        [button setBackgroundImage:followBtnFollowedBgImg forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        data.isFollowed = true;
        [viewController addChannel2FollowList:data.channelId];
    }
}

- (UITableView *)parentTableView {
    UITableView *tableView = nil;
    UIView *view = self;
    while(view != nil) {
        if([view isKindOfClass:[UITableView class]]) {
            tableView = (UITableView *)view;
            break;
        }
        view = [view superview];
    }
    return tableView;
}
@end
