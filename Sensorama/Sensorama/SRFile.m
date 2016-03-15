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
        NSLog(@"fileName=%@", fileName);
        NSError *error = NULL;
//#_(\\d{2})(\\d{2})(\\d{2})-(\\d{2})(\\d{2})(\\d{2}).json"

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d{4})(\\d{2})"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSNumberFormatter *numFmt = [[NSNumberFormatter alloc] init];



        NSArray *matches = [regex matchesInString:fileName
                                          options:0
                                            range:NSMakeRange(0, [fileName length])];
        if (matches == nil) {
            return nil;
        }

        NSLog(@"Got matches: %d", [matches count]);

        NSMutableArray *nums = [NSMutableArray new];
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match rangeAtIndex:1];
            NSString *tmpString = [fileName substringWithRange:matchRange];
            NSLog(@"tmpString: %@", tmpString);

            numFmt.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *myNumber = [numFmt numberFromString:tmpString];

            [nums addObject:myNumber];
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
