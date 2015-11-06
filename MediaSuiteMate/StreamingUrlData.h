//
//  StreamingUrlData.h
//  MediaSuiteMate
//
//  Created by derek on 21/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamingUrlData : NSObject
@property (nonatomic, retain) NSString* streamingServerPort;
@property (nonatomic, retain) NSString* streamingServerAddress;
@property (nonatomic, retain) NSString* streamingUrl;
@property (nonatomic, retain) NSString* streamingProtocol;
@property (nonatomic, retain) NSString* isExternalServer;
@property (nonatomic, retain) NSString* addressType;
@property (nonatomic, retain) NSString* serverType;
@property (nonatomic, retain) NSString* serverName;
@property (nonatomic, retain) NSString* eTag;
@property (nonatomic, retain) NSString* steamingAlias;
@property (nonatomic, retain) NSString* type;
@end
