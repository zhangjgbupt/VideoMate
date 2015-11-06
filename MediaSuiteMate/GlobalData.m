//
//  GlobalData.m
//  MediaSuiteMate
//
//  Created by derek on 16/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData
@synthesize SERVER_ADDRESS_KEY,USER_NAME_KEY,PASSWORD_KEY;

static GlobalData *instance = nil;

+ (id)getInstance {
    
    @synchronized(self) {//To safeguard threading issues
        
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        SERVER_ADDRESS_KEY = @"MediaSuiteAddress";
        USER_NAME_KEY = @"UserName";
        PASSWORD_KEY = @"Password";
        
        
    }
    return self;
}

@end
