//
//  ChannelData.h
//  MediaSuiteMate
//
//  Created by derek on 19/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelData : NSObject

@property (nonatomic, retain) NSString* channelId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSNumber* creatTime;
@property (nonatomic, retain) NSString* viewCount;
@property (nonatomic, retain) NSString* contentCount;
@property (nonatomic, retain) NSString* updateTime;
@property (nonatomic, retain) NSString* ownerName;
@property (nonatomic, retain) NSString* owner;
@property (nonatomic, retain) NSString* firstArchiveId;
@property (nonatomic, retain) NSString* firstArchiveThumbnailURL;
@property  BOOL isFollowed;

@end
