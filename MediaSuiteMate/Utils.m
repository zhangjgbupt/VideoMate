//
//  Utils.m
//  MediaSuiteMate
//
//  Created by derek on 16/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#import "Utils.h"

@implementation Utils

static Utils *instance = nil;

+ (id)getInstance {
    
    @synchronized(self) {//To safeguard threading issues
        
        if (instance == nil)
            instance = [[self alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void) invokeAlert:(NSString*)title message:(NSString*) msg delegate:(UIViewController*) controller {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    //    UIAlertAction* cancel = [UIAlertAction
    //                             actionWithTitle:@"Cancel"
    //                             style:UIAlertActionStyleDefault
    //                             handler:^(UIAlertAction * action)
    //                             {
    //                                 [alert dismissViewControllerAnimated:YES completion:nil];
    //
    //                             }];
    
    [alert addAction:ok];
    //    [alert addAction:cancel];
    
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
