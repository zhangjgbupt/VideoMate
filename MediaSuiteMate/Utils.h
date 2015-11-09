//
//  Utils.h
//  MediaSuiteMate
//
//  Created by derek on 16/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+(Utils*)getInstance;
-(void) invokeAlert:(NSString*)title message:(NSString*) msg delegate:(UIViewController*) controller;


@end
