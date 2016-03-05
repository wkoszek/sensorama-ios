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
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{4})(\\d{2})(\\d{2})_(\\d{2})(\\d{2})(\\d{2})-(\\d{2})(\\d{2})(\\d{2}).json"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSNumberFormatter *numFmt = [[NSNumberFormatter alloc] init];

        NSArray *matches = [regex matchesInString:fileName
                                              options:0
                                                range:NSMakeRange(0, [fileName length])];
        if (matches == nil) {
            return nil;
        }

        NSMutableArray *nums = [NSMutableArray new];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match rangeAtIndex:1];
            NSString *tmpString = [fileName substringWithRange:matchRange];


            numFmt.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *myNumber = [numFmt numberFromString:tmpString];

            [nums addObject:myNumber];
        }

    }
    return self;
}



- (NSString *)printableLabel {
    return nil;
}


@end
