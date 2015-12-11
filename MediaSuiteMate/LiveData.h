//
//  LiveData.h
//  VideoMate
//
//  Created by Chris Ling on 15/12/2.
//  Copyright © 2015年 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveData : NSObject
@property (nonatomic, retain) NSString* callId;
@property (nonatomic, retain) NSString* subject;
@property (nonatomic, retain) NSString* creatTime;
@property (nonatomic, retain) NSString* coverUrl;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) Boolean isEasyCapture;
@end
