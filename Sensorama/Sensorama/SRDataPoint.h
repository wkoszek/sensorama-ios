//
//  SRDataPoint.h
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

@property NSNumber<RLMInt> *index;
@property NSInteger curTime;

@end