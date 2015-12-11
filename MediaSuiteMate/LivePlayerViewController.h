//
//  LivePlayerViewController.h
//  VideoMate
//
//  Created by Chris Ling on 15/12/4.
//  Copyright © 2015年 derek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LivePlayerViewController : UIViewController

@property (nonatomic, retain) NSString* callID;
@property (nonatomic, retain) NSString* subject;
@property (nonatomic, retain) NSString* createTime;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) Boolean isEasyCapture;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (nonatomic, retain) MPMoviePlayerController *player;
@property (strong, nonatomic) NSMutableArray* streamingURLlist;
@property (strong, nonatomic) IBOutlet UILabel *mediaFileTitle, *liveText;
@property (strong, nonatomic) IBOutlet UILabel *mediaFileCrateTime;
@property (strong, nonatomic) IBOutlet UIImageView *timeIcon, *liveIcon, *slide1, *slide2, *recommendImg;
@property (strong, nonatomic) IBOutlet UILabel *desTitle;
@property (strong, nonatomic) IBOutlet UILabel *mediaFileDes;
@property (strong, nonatomic) IBOutlet UILabel *seperator1, *seperator2, *recommendTitle;

@end
