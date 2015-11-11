//
//  UGCPlaybackViewController.h
//  RSSMate
//
//  Created by Zhang Derek on 8/29/14.
//  Copyright (c) 2014 Polycom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UploadMediaFiles.h"
#import "ArchiveData.h"
#import "DropDownListView.h"

@interface UGCPlaybackViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, kDropDownListViewDelegate>

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *btnUpload;
@property (strong, nonatomic) IBOutlet UITextView *textDescription;
@property (strong, nonatomic) UILabel* placeholderLabel;
@property (strong, nonatomic) IBOutlet UITextField *textMediaFileName;

@property (strong, nonatomic) NSMutableArray* channelNameList;
@property (strong, nonatomic) NSMutableDictionary * channelListNameAndIdDict;
@property (strong, nonatomic) DropDownListView * channelDropListView;
@property (strong, nonatomic) NSMutableArray* channelSelected;

@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) UploadMediaFiles* uploadMediaFilesHandle;
@property (strong, nonatomic) ArchiveData* ugcArchiveData;
@property (strong, nonatomic) IBOutlet UILabel *seperator_1;
@property (strong, nonatomic) IBOutlet UILabel *seperator_2;
@property (strong, nonatomic) IBOutlet UIButton *btnChannelList;

@property CGFloat original_y_center;

@property (strong, nonatomic) AppDelegate* appDelegate;

- (IBAction)DropDownPressed:(id)sender;
//- (IBAction)DropDownSingle:(id)sender;

- (IBAction)uploadMediaFile:(id)sender;
@end
