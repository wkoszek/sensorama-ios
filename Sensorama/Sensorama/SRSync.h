//
//  SRSync.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRSync : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (void)syncStart;

@property NSString *pathToSync;

@end
