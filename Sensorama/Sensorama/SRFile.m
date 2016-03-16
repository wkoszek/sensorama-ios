//
//  SRFile.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/5/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRFile.h"

@implementation SRFile

- (instancetype) initWithFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        static NSRegularExpression *regex = nil;
        __block NSError *error = nil;

        dispatch_once(&onceToken, ^{
            regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{8})_(\\d{6})-(\\d{6}).json"
                                                              options:0
                                                                error:&error];
        });

        NSLog(@"fileName=>%@< regex=%@ error=%@", fileName, regex, error);

        NSArray *matches = [regex matchesInString:fileName
                                          options:0
                                            range:NSMakeRange(0, [fileName length])];
        if (matches == nil) {
            return nil;
        }

        NSMutableArray *nums = [NSMutableArray new];
        for (NSTextCheckingResult *match in matches) {
            for (int i = 0; i < 3; i++) {
                NSRange matchRange = [match rangeAtIndex:i];
                NSString *tmpString = [fileName substringWithRange:matchRange];
                [nums addObject:tmpString];
            }
        }

        NSLog(@"Got matches: %d", [nums count]);
        int idx = 0;
#if 0
        self.year = [nums objectAtIndex:idx++];
        self.month = [nums objectAtIndex:idx++];
        self.day = [nums objectAtIndex:idx++];
        self.fromHour = [nums objectAtIndex:idx++];
        self.fromMin = [nums objectAtIndex:idx++];
        self.fromSec = [nums objectAtIndex:idx++];
        self.toHour = [nums objectAtIndex:idx++];
        self.toMin = [nums objectAtIndex:idx++];
        self.toSec = [nums objectAtIndex:idx++];
#endif

        NSLog(@"File=%@", nums);
    }
    return self;
}

- (NSString *)printableLabel {
    return [NSString stringWithFormat:@"%04d", [self.year intValue]];
}


@end
