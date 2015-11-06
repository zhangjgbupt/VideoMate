//
//  ArchiveTableViewCell.m
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "ArchiveTableViewCell.h"

@implementation ArchiveTableViewCell
@synthesize archiveCreateTime, archiveDuration, archiveName, archiveThum;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
