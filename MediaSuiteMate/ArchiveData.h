//
//  ArchiveData.h
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiveData : NSObject
@property (nonatomic, retain) NSString* achiveId;
@property (nonatomic, retain) NSString* displayName;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* creatTime;
@property (nonatomic, retain) NSString* viewCount;
@property (nonatomic, retain) NSString* contentCount;
@property (nonatomic, retain) NSString* updateTime;
@property (nonatomic, retain) NSString* duration;
@property (nonatomic, retain) NSString* owner;
@property (nonatomic, retain) NSString* archiveCoverURL;
@property (nonatomic, retain) NSString* thumbnail;
@property (nonatomic, retain) NSString* deviceAddress;
@property (nonatomic, retain) NSString* mediaPath;
@property (nonatomic, retain) NSString* deviceId;
@property (nonatomic, retain) NSString* likeCount;
@property (nonatomic, retain) NSMutableArray* channelList;
@property (nonatomic, retain) NSMutableArray* archiveFiles;
@end
