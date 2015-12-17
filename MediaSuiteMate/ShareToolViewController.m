//
//  ShareToolViewController.m
//  VideoMate
//
//  Created by derek on 15/12/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "ShareToolViewController.h"

#import "WXApi.h"

@interface ShareToolViewController ()

@end

@implementation ShareToolViewController
@synthesize shareTitle  = _shareTitle;
@synthesize detailInfo = _detailInfo;
@synthesize shareImage = _shareImage;
@synthesize shareImageURL = _shareImageURL;
@synthesize shareWebPageURL = _shareWebPageURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect mainScreenBounds = [[UIScreen mainScreen] bounds];
    self.view.frame = mainScreenBounds;
}

#pragma mark - 分享
- (void)initWhithTitle:(NSString *)title
            detailInfo:(NSString*)info
                 image:(UIImage *)image
              imageUrl:(NSString *)imageUrl
            webpageUrl:(NSString*)webpageUrl{
    _shareTitle = title;
    _detailInfo = info;
    _shareImage = image;
    _shareImageURL = imageUrl;
    _shareWebPageURL = webpageUrl;
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"分享到微信朋友",@"分享到微信朋友圈",nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //通过微信好友分享
            [self shareInformationWithType:kShareTool_WeiXinFriends];
            break;
        case 1: //通过微信朋友圈分享
            [self shareInformationWithType:kShareTool_WeiXinCircleFriends];
            break;
        default:
            break;
    }
}

- (void)shareInformationWithType:(ShareToolType)shareToolType {
    switch (shareToolType) {
        case kShareTool_WeiXinFriends:{
            WXImageObject *imgObj = [WXImageObject object];
            imgObj.imageUrl = _shareImageURL;
            
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = _shareWebPageURL;
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = _shareTitle;
            message.description = _detailInfo;
            message.mediaObject = webObj;
            
            UIImage *desImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareImageURL]]];
            UIImage *thumbImg = [self thumbImageWithImage:desImage limitSize:CGSizeMake(150, 150)];
            message.thumbData = UIImageJPEGRepresentation(thumbImg, 1);
            //            NSLog(@"%@,%d",thumbImg,message.thumbData.length);
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.scene = WXSceneSession;
            req.bText = NO;
            req.message = message;
            [WXApi sendReq:req];
            [self shareHasDone];
            break;
        }
        case kShareTool_WeiXinCircleFriends:{
            WXWebpageObject *webObj = [WXWebpageObject object];
            webObj.webpageUrl = _shareImageURL;
            
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = _shareTitle;
            message.description = _detailInfo;
            message.mediaObject = webObj;
            
            UIImage *desImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareImageURL]]];
            UIImage *thumbImg = [self thumbImageWithImage:desImage limitSize:CGSizeMake(150, 150)];
            message.thumbData = UIImageJPEGRepresentation(thumbImg, 1);
            //            NSLog(@"%@,%d",thumbImg,message.thumbData.length);
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.scene = WXSceneTimeline;
            req.bText = NO;
            req.message = message;
            [WXApi sendReq:req];
            [self shareHasDone];
            break;
        }
        default:
            break;
    }
}
- (UIImage *)thumbImageWithImage:(UIImage *)scImg limitSize:(CGSize)limitSize
{
    if (scImg.size.width <= limitSize.width && scImg.size.height <= limitSize.height) {
        return scImg;
    }
    CGSize thumbSize;
    if (scImg.size.width / scImg.size.height > limitSize.width / limitSize.height) {
        thumbSize.width = limitSize.width;
        thumbSize.height = limitSize.width / scImg.size.width * scImg.size.height;
    }
    else {
        thumbSize.height = limitSize.height;
        thumbSize.width = limitSize.height / scImg.size.height * scImg.size.width;
    }
    UIGraphicsBeginImageContext(thumbSize);
    [scImg drawInRect:(CGRect){CGPointZero,thumbSize}];
    UIImage *thumbImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbImg;
}
- (void)shareHasDone{
    self.shareImage = nil;
    self.shareTitle = nil;
    self.shareImageURL = nil;
    self.detailInfo = nil;
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
