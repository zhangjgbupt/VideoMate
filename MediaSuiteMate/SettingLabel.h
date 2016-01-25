//
//  SettingLabel.h
//  VideoMate
//
//  Created by Chris Ling on 16/1/24.
//  Copyright © 2016年 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingLabel : UILabel
@property(nonatomic) UIEdgeInsets insets;
-(id) initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets) insets;
-(id) initWithInsets: (UIEdgeInsets) insets;
@end
