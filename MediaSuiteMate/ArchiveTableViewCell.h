//
//  ArchiveTableViewCell.h
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArchiveTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *archiveName;
@property (strong, nonatomic) IBOutlet UIImageView *archiveThum;
@property (strong, nonatomic) IBOutlet UILabel *archiveCreateTime;
@property (strong, nonatomic) IBOutlet UILabel *archiveDuration;
@end
