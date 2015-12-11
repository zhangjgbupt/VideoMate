//
//  LiveTableViewCell.h
//  VideoMate
//
//  Created by Chris Ling on 15/12/3.
//  Copyright © 2015年 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *subject;
@property (strong, nonatomic) IBOutlet UIImageView *liveThum;
@property (strong, nonatomic) IBOutlet UIImageView *backBar;
@property (strong, nonatomic) IBOutlet UILabel *liveCreateTime;
@end
