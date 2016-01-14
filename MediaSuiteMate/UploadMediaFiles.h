//
//  UploadMediaFiles.h
//  RSSMate
//
//  Created by Zhang Derek on 8/22/14.
//  Copyright (c) 2014 Polycom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "MediaPathData.h"

@interface UploadMediaFiles : NSObject

@property (nonatomic) float progressValue;
@property (nonatomic, retain) MediaPathData* desUploadFilePathData;
@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, retain) NSString* progressValueSize;


- (void) upLoadMediaFiles: (NSString*) desFileName From: (NSString*)srcFileUrl;
@end
