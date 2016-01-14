//
//  LikeBtn.h
//  VideoMate
//
//  Created by Chris Ling on 16/1/13.
//  Copyright © 2016年 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, LikeBtnType) {
    LikeBtnTypeFirework,
    LikeBtnTypeFocus
};

@interface LikeBtn : UIControl

/**
 *  A bool value for button current status
 */
@property (nonatomic) BOOL isLike;

/**
 *  A enum for button animation type
 */
@property (nonatomic) LikeBtnType type;

/**
 *  A handler for click button action
 */
@property (nonatomic, copy) void (^clickHandler)(LikeBtn *zanButton);

/**
 *  Initializes a new likeButton with appoint properties
 *
 *  @param frame      Button frame
 *  @param liveImage   Image for button active status
 *  @param unLikeIamge Image for button inactive status
 *
 *  @return New likeButton object
 */
-(instancetype)initWithFrame:(CGRect)frame likeImage:(UIImage *)likeImage unLikeImage:(UIImage *)unLikeIamge;

@end

