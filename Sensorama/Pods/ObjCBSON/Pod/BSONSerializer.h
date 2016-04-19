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
#import "bson.h"

@class BSONDocument;

/**
 Private class to handle document serialization. Offers a simpler,
 higher level interface compared to using BSONDocument directly.
 */
@interface BSONSerializer : NSObject

/**
 Create a new serializer with an empty document.
 */
+ (instancetype) serializer;

/**
 Create a new serializer with a new document, taking ownership of
 the given bson_t.
 
 Note the bson_t should be heap-allocated.
 */
+ (instancetype) serializerWithNativeDocument:(bson_t *) nativeDocument;

/**
 Access the underlying bson_t, which remains owned by the receiver.
 */
- (bson_t *) nativeValue;

/**
 Append the given value to the receiver's document.
 */
- (BOOL) appendObject:(id) value forKey:(NSString *) key error:(NSError **) error;

/**
 Append all the values from the given dictionary to the receiver's
 document. Stops serializing on the first error.
 */
- (BOOL) serializeDictionary:(NSDictionary *) dictionary error:(NSError **) error;

/**
 Access the receiver's document.
 */
@property (strong) BSONDocument *document;

@end
