//
//  Copyright 2014 Paul Melnikow
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

@class BSONDocument;

/**
 Convenience class to serialize and deserialize BSON.
 */
@interface BSONSerialization : NSObject

/**
 Deserialize BSON data to native Objective-C types and various types
 defined in BSONTypes.h.
 */
+ (NSDictionary *) dictionaryWithBSONData:(NSData *) data error:(NSError **) error;

/**
 Serialize an Objective-C dictionary to BSON. Supports NSString,
 NSNumber, NSDate, NSNull, and various types defined in BSONTypes.h.
 */
+ (NSData *) BSONDataWithDictionary:(NSDictionary *) dictionary error:(NSError **) error;

@end
