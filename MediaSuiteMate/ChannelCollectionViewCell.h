//
//  ChannelCellViewControllerCollectionViewCell.h
//  MediaSuiteMate
//
//  Created by derek on 15/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *channelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *channelThum;
@property (strong, nonatomic) IBOutlet UIImageView *titleBackground;
@property (strong, nonatomic) IBOutlet UILabel *itemNum;

@end
