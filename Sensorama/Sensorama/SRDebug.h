// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDebug.h
//  Sensorama

#ifndef SRDebug_h
#define SRDebug_h

#define SRPROBE0() do {                     \
    NSLog(@"%s", __func__);                 \
} while (0)

#define SRPROBE1(x1) do {                    \
    NSLog(@"%s %s=%@", __func__, #x1, (x1));    \
} while (0)

#define SRPROBE2(x1, x2) do {                                  \
    NSLog(@"%s %s=%@ %s=%@", __func__, #x1, (x1), #x2, (x2));    \
} while (0)

#define SRPROBE3(x1, x2, x3) do {                                  \
    NSLog(@"%s %s=%@ %s=%@ %s=%@", __func__, #x1, (x1), #x2, (x2), #x3, (x3));    \
} while (0)

#define SRDEBUG if (1) NSLog

#endif /* SRDebug_h */
