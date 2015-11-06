//
//  StreamingData.h
//  MediaSuiteMate
//
//  Created by derek on 21/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamingData : NSObject
@property (nonatomic, retain) NSString* bitRate;
@property (nonatomic, retain) NSString* videoWidth;
@property (nonatomic, retain) NSString* videoHeigt;
@property (nonatomic, retain) NSString* mediaType;
@property (nonatomic, retain) NSString* videoFramerate;
@property (nonatomic, retain) NSString* contentFramerate;
@property (nonatomic, retain) NSString* contentWidth;
@property (nonatomic, retain) NSString* contentHeight;
@property (nonatomic, retain) NSString* layoutType;
@property (nonatomic, retain) NSMutableArray* streamingUrlList;
@property (nonatomic, retain) NSString* bitRateInTemplate;
@end
