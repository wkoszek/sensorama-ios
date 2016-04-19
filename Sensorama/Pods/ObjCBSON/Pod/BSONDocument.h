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
#import "BSONTypes.h"

/**
 Encapsulates a BSON document. Provides a low-level interface.
 
 To construct a BSON document, it's probably simpler to use
 BSONSerialization instead.
 */
@interface BSONDocument : NSObject

/**
 Creates an empty BSON document.
 */
+ (instancetype) document;


/**
 Creates an empty BSON document with the given capacity, which must be
 smaller than INT_MAX.
 */
+ (instancetype) documentWithCapacity:(NSUInteger) bytes;


/**
 Returns a BSON document created using the given data block. If the data
 is mutable, it retains a copy of the block. If it's immutable, the
 document retains and accesses it directly.
 
 @param data An instance of <code>NSData</code> with the binary data for the new
 document.
 */
+ (instancetype) documentWithData:(NSData *) data;

/**
 Returns a BSON document created using the given data block. If the data
 is mutable, it retains a copy of the block. If it's immutable -- or if
 noCopy is YES -- the document retains and accesses it directly.
 
 @param data An instance of <code>NSData</code> with the binary data for the new
 document.
 */
+ (instancetype) documentWithData:(NSData *) data noCopy:(BOOL) noCopy;

/**
 Returns a JSON-like string representation of the document.
 */
- (NSString *) description;

/**
 Returns an immutable <code>NSData</code> object with a copy of the document's
 BSON data buffer.
 
 The NSData object is guaranteed to remain valid even if the receiver is deallocated.
 
 Invoking -dataValue finalizes the document. You can no longer change it.
 
 @returns An immutable <code>NSData</code> object pointing to the BSON data buffer.
 */
- (NSData *) dataValue;

/**
 Returns a deserialized dictionary for this document.
 */
- (NSDictionary *) dictionaryValueWithError:(NSError **) error;

/**
 Copies the BSON document and its underlying data.
 */
- (instancetype) copy;

/**
 Returns YES if the BSON document has no values.
 */
- (BOOL) isEmpty;

/**
 Returns YES if the BSON document has the given field.
 */
- (BOOL) hasField:(NSString *) key;

/**
 Returns NSOrderedSame if the two BSON documents are the same.
 */
- (NSComparisonResult) compare:(BSONDocument *) other;

/**
 Returns YES if the two BSON documents are the same.
 */
- (BOOL) isEqual:(BSONDocument *) document;

/**
 Append an NSData value with the given key.
 */
- (BOOL) appendData:(NSData *) value forKey:(NSString *) key;

/**
 Append a boolean value with the given key.
 */
- (BOOL) appendBool:(BOOL) value forKey:(NSString *) key;

/**
 Append a BSON code value with the given key.
 */
- (BOOL) appendCode:(BSONCode *) value forKey:(NSString *) key;

/**
 Append a BSON codewithscope value with the given key.
 */
- (BOOL) appendCodeWithScope:(BSONCodeWithScope *) value forKey:(NSString *) key;

/**
 Append a BSON dbref value with the given key.
 */
- (BOOL) appendDatabasePointer:(BSONDatabasePointer *) value forKey:(NSString *) key;

/**
 Append a double value with the given key.
 */
- (BOOL) appendDouble:(double) value forKey:(NSString *) key;

/**
 Append an embedded document value with the given key.
 */
- (BOOL) appendEmbeddedDocument:(BSONDocument *) value forKey:(NSString *) key;

/**
 Append a 32-bit integer value with the given key.
 */
- (BOOL) appendInt32:(int32_t) value forKey:(NSString *) key;

/**
 Append a 64-bit integer value with the given key.
 */
- (BOOL) appendInt64:(int64_t) value forKey:(NSString *) key;

/**
 Append a BSON minkey value with the given key.
 */
- (BOOL) appendMinKeyForKey:(NSString *) key;

/**
 Append a BSON maxkey value with the given key.
 */
- (BOOL) appendMaxKeyForKey:(NSString *) key;

/**
 Append a BSON null value with the given key.
 */
- (BOOL) appendNullForKey:(NSString *) key;

/**
 Append a BSON object ID value with the given key.
 */
- (BOOL) appendObjectID:(BSONObjectID *) value forKey:(NSString *) key;

/**
 Append a BSON regex value with the given key.
 */
- (BOOL) appendRegularExpression:(BSONRegularExpression *) value forKey:(NSString *) key;

/**
 Append a string value with the given key.
 */
- (BOOL) appendString:(NSString *) value forKey:(NSString *) key;

/**
 Append a BSON symbol value with the given key.
 */
- (BOOL) appendSymbol:(BSONSymbol *) value forKey:(NSString *) key;

/**
 Append a date value with the given key.
 */
- (BOOL) appendDate:(NSDate *) value forKey:(NSString *) key;

/**
 Append a BSON timestamp value with the given key.
 */
- (BOOL) appendTimestamp:(BSONTimestamp *) value forKey:(NSString *) key;

/**
 Append a BSON undefined value with the given key.
 */
- (BOOL) appendUndefinedForKey:(NSString *) key;

/**
 Return the maximum size of a BSON document, in bytes.
 */
+ (NSUInteger) maximumCapacity;

@end
