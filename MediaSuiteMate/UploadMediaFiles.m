//
//  UploadMediaFiles.m
//  RSSMate
//
//  Created by Zhang Derek on 10/26/15.
//  Copyright (c) 2014 Polycom. All rights reserved.
//

#import "UploadMediaFiles.h"
#import "AppDelegate.h"

@implementation UploadMediaFiles

@synthesize progressValue;
@synthesize desUploadFilePathData;
@synthesize fileName;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.desUploadFilePathData = [[MediaPathData alloc]init];
    }
    return self;
}

- (void) doUpLoadMediaFiles: (NSString*)desFileName From:(NSString*)srcFileUrl ;
{
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@:8888/DownUploadServer/upload/ugcUpload", self.desUploadFilePathData.ipAddr];
    NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:srcFileUrl]];
    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    
    NSDictionary *params = @{
                             @"path" : self.desUploadFilePathData.fileSavePath,
                            };
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:requestStr parameters:params
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:videoData name:@"file" fileName:desFileName mimeType:@"video/mp4"];
                     }];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_SUCCESSFUL" object:nil];
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_FAIL" object:nil];
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        progressValue = totalBytesWritten*1.0/totalBytesExpectedToWrite;
        NSLog(@"Wrote %f",progressValue);
    }];
    
    // 5. Begin!
    [operation start];
}

- (void)upLoadMediaFiles: (NSString*)desFileName From:(NSString*)srcFileUrl
{
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSString* requestUrl = [NSString stringWithFormat:@"http://%@/userportal/api/rest/upload/ugc/mediafile/path", appDelegate.svrAddr];

    NSString* auth = [NSString stringWithFormat:@"Bearer %@", appDelegate.accessToken];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.plcm.plcm-csc+json"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/vnd.plcm.plcm-csc+json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:appDelegate.accessToken forHTTPHeaderField:@"token"];
    [manager.requestSerializer setValue:auth forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *body = @{ @"ipAddr" : @"",
                            @"ipType" : @"IPV4",
                            @"targetFileName" : desFileName };
    
    [manager PUT:requestUrl parameters:body
                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       self.desUploadFilePathData.ipAddr = responseObject[@"ipAddr"];
                       self.desUploadFilePathData.port = responseObject[@"port"];
                       self.desUploadFilePathData.fileSavePath = responseObject[@"fileSavePath"];
                       self.desUploadFilePathData.owner = responseObject[@"owner"];
                       self.desUploadFilePathData.arcDisplayName = responseObject[@"arcDisplayName"];
                       [self doUpLoadMediaFiles:desFileName From:srcFileUrl];
                   }
                   failure:^(AFHTTPRequestOperation* task, NSError* error){
                       NSLog(@"Get upload path error: %@", error);
                   }];
}



@end
