//
//  LiveTableViewCell.m
//  VideoMate
//
//  Created by Chris Ling on 15/12/3.
//  Copyright © 2015年 derek. All rights reserved.
//

#import "LiveTableViewCell.h"

@implementation LiveTableViewCell
@synthesize liveCreateTime, subject, liveThum, backBar;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
