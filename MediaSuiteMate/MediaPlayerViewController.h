//
//  MediaPlayerViewController.h
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import"ShareToolViewController.h"


@interface MediaPlayerViewController : UIViewController <UIActionSheetDelegate, ShareToolViewControllerDelegate>
@property (strong, nonatomic) NSString* archiveName;
@property (strong, nonatomic) NSString* archiveDes;
@property (strong, nonatomic) NSString* archiveId;
@property (strong, nonatomic) NSString* likeStatus;
@property (strong, nonatomic) NSString* likeCount;
@property (strong, nonatomic) NSString* thumUrl;
@property (strong, nonatomic) NSMutableArray* episodeFiles;
@property (nonatomic, retain) MPMoviePlayerController *player;
@property (strong, nonatomic) NSMutableArray* streamingURLlist;
@property (strong, nonatomic) IBOutlet UILabel *mediaFileTitle;
@property (strong, nonatomic) IBOutlet UILabel *mediaFileCrateTime;
@property (strong, nonatomic) IBOutlet UIImageView *timeIcon;
@property (strong, nonatomic) IBOutlet UILabel *mediaFileDes;
@property (strong, nonatomic) IBOutlet UILabel *seperator;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UILabel *likeLabel;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel;

//for weixin share
@property (nonatomic, retain)NSString *shareTitle;
@property (nonatomic, retain)NSString *detailInfo;
@property (nonatomic, retain)UIImage *shareImage;
@property (nonatomic, retain)NSString *shareImageURL;
@property (nonatomic, retain)NSString *shareWebPageURL;

@property (strong, nonatomic) AppDelegate* appDelegate;

- (void)setFiles:(NSMutableArray *)files;
- (IBAction)likeBtnClick:(id)sender;
- (IBAction)shareBtnClick:(id)sender;

//for weixin share
- (void)initWhithTitle:(NSString *)title detailInfo:(NSString*)detailInfo
                 image:(UIImage *)image imageUrl:(NSString *)imageUrl webpageUrl:(NSString*)webpageUrl;


@end
