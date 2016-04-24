//
//  SRUnitTestLoop.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#ifndef SRUnitTestLoop_h
#define SRUnitTestLoop_h

#define WAIT_INIT()     __block BOOL __waitIsDone = NO
#define WAIT_DONE()     __waitIsDone = YES
#define WAIT_LOOP()    do {                                                    \
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];           \
    while (__waitIsDone == NO && [loopUntil timeIntervalSinceNow] > 0) {   \
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode  beforeDate:loopUntil];                     \
    }                                                                       \
    if (!__waitIsDone) { \
        XCTFail(@"I know this will fail, thanks");                          \
    }                                                                       \
} while (0)

#endif /* SRUnitTestLoop_h */
