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

@interface MediaPlayerViewController : UIViewController
@property (strong, nonatomic) NSString* archiveName;
@property (strong, nonatomic) NSString* archiveDes;
@property (strong, nonatomic) NSString* archiveId;
@property (strong, nonatomic) NSString* likeStatus;
@property (strong, nonatomic) NSString* likeCount;
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
//@property (strong, nonatomic) IBOutlet UIButton *downloadBtn;
//@property (strong, nonatomic) IBOutlet UILabel *downloadLabel;

@property (strong, nonatomic) AppDelegate* appDelegate;

- (void)setFiles:(NSMutableArray *)files;
- (IBAction)likeBtnClick:(id)sender;
- (IBAction)shareBtnClick:(id)sender;


@end
