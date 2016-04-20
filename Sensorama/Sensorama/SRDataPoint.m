//
//  SRDataPoint.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 19/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRDataPoint.h"

@implementation SRDataPoint

+ (NSString *)primaryKey
{
    return @"index";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"index": @(0) };
}

@end

@implementation SRDataFile

+ (NSString *)primaryKey
{
    return @"fileId";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"fileId": @(0) };
}

@end
