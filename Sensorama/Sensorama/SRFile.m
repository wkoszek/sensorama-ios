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
            regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{4})(\\d{2})(\\d{2})_(\\d{2})(\\d{2})(\\d{2})-(\\d{2})(\\d{2})(\\d{2}).json"
                                                              options:0
                                                                error:&error];
        });

        NSLog(@"fileName=>%@< regex=%@ error=%@", fileName, regex, error);

        NSArray *matches = [regex matchesInString:fileName
                                          options:0
                                            range:NSMakeRange(0, [fileName length])];
        if (matches == nil || ([matches count] != 1)) {
            return nil;
        }

        NSMutableArray *nums = [NSMutableArray new];
        for (NSTextCheckingResult *match in matches) {
            for (int i = 1; i < 10; i++) {
                NSRange matchRange = [match rangeAtIndex:i];
                NSString *tmpString = [fileName substringWithRange:matchRange];
                [nums addObject:tmpString];
            }
        }

        NSLog(@"AR: %@", nums);

        int idx = 0;
        self.year = [[nums objectAtIndex:idx++] intValue];
        self.month = [[nums objectAtIndex:idx++] intValue];
        self.day = [[nums objectAtIndex:idx++] intValue];
        self.fromHour = [[nums objectAtIndex:idx++] intValue];
        self.fromMin = [[nums objectAtIndex:idx++] intValue];
        self.fromSec = [[nums objectAtIndex:idx++] intValue];
        self.toHour = [[nums objectAtIndex:idx++] intValue];
        self.toMin = [[nums objectAtIndex:idx++] intValue];
        self.toSec = [[nums objectAtIndex:idx++] intValue];
    }
    return self;
}

- (NSString *) printableLabelDetails {
    return [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d-%02d:%02d:%02d",
            self.year, self.month, self.day, self.fromHour, self.fromMin, self.fromSec, self.toHour, self.toMin, self.toSec];
}

- (NSString *) printableLabel {
    NSUInteger fromS = (self.fromHour * 3600) + (self.fromMin * 60) + self.fromSec;
    NSUInteger toS = (self.toHour * 3600) + (self.toMin * 60) + self.toSec;
    NSUInteger lengthS = toS - fromS;

    return [NSString stringWithFormat:@"%ds", lengthS];
}


@end
