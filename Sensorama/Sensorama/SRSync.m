//
//  SRSync.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRSync.h"

@implementation SRSync

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.pathToSync = path;
    }
    return self;
}

- (void)syncStart
{
    NSFileHandle *fp = [NSFileHandle fileHandleForReadingAtPath:self.pathToSync];
    NSData *fileData = [fp readDataToEndOfFile];
    NSURL *url = [NSURL URLWithString:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:fileData];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *putDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Success: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            NSLog(@"Failure: code=%ld", (long)[resp statusCode]);
        }
    }];
    [putDataTask resume];
}

@end
