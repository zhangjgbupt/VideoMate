//
//  ChannelFollowViewCell.h
//  MediaSuiteMate
//
//  Created by derek on 22/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelFollowViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *channleTitle;
@property (strong, nonatomic) IBOutlet UILabel *channelOwner;
@property (strong, nonatomic) IBOutlet UILabel *createDate;
@property (strong, nonatomic) IBOutlet UIButton *followBtn;
@property (strong, nonatomic) IBOutlet UIImageView *channelThumb;
- (IBAction)onFollowBtnClick:(id)sender;
@end
