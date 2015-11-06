//
//  ArchiveFileData.h
//  MediaSuiteMate
//
//  Created by derek on 20/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiveFileData : NSObject
@property (nonatomic, retain) NSString* fileId;
@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, retain) NSString* displayName;
@property (nonatomic, retain) NSString* fileType;
@property (nonatomic, retain) NSString* creatTime;
@property (nonatomic, retain) NSString* resolution;
@property (nonatomic, retain) NSString* flocate;
@property (nonatomic, retain) NSString* archiveId;
@property (nonatomic, retain) NSString* length;
@property (nonatomic, retain) NSString* duration;
@property (nonatomic, retain) NSString* episode;
@end
