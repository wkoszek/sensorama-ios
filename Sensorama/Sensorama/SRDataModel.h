//
//  SRDataModel.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 19/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm/Realm.h"

@interface SRDataPoint : RLMObject

@property NSNumber<RLMInt> *accX;
@property NSNumber<RLMInt> *accY;
@property NSNumber<RLMInt> *accZ;

@property NSNumber<RLMInt> *magX;
@property NSNumber<RLMInt> *magY;
@property NSNumber<RLMInt> *magZ;

@property NSNumber<RLMInt> *gyroX;
@property NSNumber<RLMInt> *gyroY;
@property NSNumber<RLMInt> *gyroZ;

@property NSInteger fileId;
@property NSInteger curTime;

- (NSDictionary *)toDict;

@end
RLM_ARRAY_TYPE(SRDataPoint)


@interface SRDataFile : RLMObject

@property NSString *username;
@property NSString *desc;
@property NSString *timezone;
/* need to do something about device_info */

@property NSInteger sampleInterval;
@property BOOL accEnabled;
@property BOOL magEnabled;
@property BOOL gyroEnabled;

@property NSDate *dateStart;
@property NSDate *dateEnd;
@property NSInteger fileId;

@property RLMArray<SRDataPoint> *dataPoints;

- (NSDictionary *)toDict;

@end
RLM_ARRAY_TYPE(SRDataFile)


@interface SRDataStore : NSObject

@property (readonly) RLMRealm *realm;

+ (SRDataStore *)sharedInstance;
- (void) insertDataFile:(SRDataFile *)dataFile;
- (void) insertDataPoints:(NSArray<SRDataPoint *> *) points;


@end