//
//  GlobalData.h
//  MediaSuiteMate
//
//  Created by derek on 16/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalData : NSObject
@property(nonatomic,retain)NSString *SERVER_ADDRESS_KEY;
@property(nonatomic,retain)NSString *USER_NAME_KEY ;
@property(nonatomic,retain)NSString *PASSWORD_KEY ;
+(GlobalData*)getInstance;

@end
