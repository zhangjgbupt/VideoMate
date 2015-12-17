//
//  ShareToolViewController.h
//  VideoMate
//
//  Created by derek on 15/12/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kShareTool_WeiXinFriends = 0, // 微信好友
    kShareTool_WeiXinCircleFriends, // 微信朋友圈
} ShareToolType;

@protocol ShareToolViewControllerDelegate <NSObject>

@end

@interface ShareToolViewController : UIViewController<UIActionSheetDelegate>
{
    
}

@property (nonatomic, retain)NSString *shareTitle;
@property (nonatomic, retain)NSString *detailInfo;
@property (nonatomic, retain)UIImage *shareImage;
@property (nonatomic, retain)NSString *shareImageURL;
@property (nonatomic, retain)NSString *shareWebPageURL;


@property (nonatomic, assign)id<ShareToolViewControllerDelegate> delegate;


- (void)initWhithTitle:(NSString *)title detailInfo:(NSString*)detailInfo
                 image:(UIImage *)image imageUrl:(NSString *)imageUrl webpageUrl:(NSString*)webpageUrl;

@end
