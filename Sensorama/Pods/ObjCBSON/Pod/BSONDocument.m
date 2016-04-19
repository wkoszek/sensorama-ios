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

#import "BSONDocument.h"
#import "ObjCBSON-private.h"
#import "BSONSerialization.h"
#import "ObjCBSON.h"
#import <bson.h>


@interface BSONDocument ()
@property (strong) NSData *inData;
@end

@interface BSONDocument (Module)
- (const bson_t *) nativeValue;
- (id) initWithNativeValue:(bson_t *) bson;
@end

@interface BSONObjectID (Module)
- (bson_oid_t) nativeValue;
@end

@interface BSONSerialization (Module)
+ (NSDictionary *) dictionaryWithDocument:(BSONDocument *) document error:(NSError **) error;
+ (BSONDocument *) BSONDocumentWithDictionary:(NSDictionary *) dictionary error:(NSError **) error;
@end

@interface BSONDocument ()
@property (assign) bson_t *_bson;
@property (assign) BOOL finalized;
@end

@implementation BSONDocument {
    const uint8_t *_bytes;
    size_t _length;
}

- (id) init {
    if (self = [super init]) {
        self._bson = bson_new();
    }
    return self;
}

- (id) initWithCapacity:(NSUInteger) bytes {
    if (bytes > UINT32_MAX)
        return self = nil;
    if (self = [super init]) {
        self._bson = bson_sized_new(bytes);
    }
    return self;
}

- (id) initWithData:(NSData *) data noCopy:(BOOL) noCopy {
    if (self = [super init]) {
        if (data.length > UINT32_MAX)
            return self = nil;
        if (noCopy)
            self.inData = data;
        else
            self.inData = [data isKindOfClass:[NSMutableData class]] ? [NSData dataWithData:data] : data;
        _bytes = self.inData.bytes;
        _length = self.inData.length;
        self._bson = bson_new_from_buffer((uint8_t **)&_bytes, &_length, NULL, NULL);
        if (!self._bson) {
            return self = nil;
        }
    }
    return self;
}

- (id) initWithNativeValue:(bson_t *) bson {
    if (bson == NULL) return self = nil;
    if (self = [super init]) {
        self._bson = bson;
    }
    return self;
}

+ (instancetype) document {
    return [[self alloc] init];
}

+ (instancetype) documentWithCapacity:(NSUInteger) bytes {
    return [[self alloc] initWithCapacity:bytes];
}

+ (instancetype) documentWithData:(NSData *) data {
    return [[self alloc] initWithData:data noCopy:NO];
}

+ (instancetype) documentWithData:(NSData *) data noCopy:(BOOL) noCopy {
    return [[self alloc] initWithData:data noCopy:noCopy];
}

- (void) dealloc {
    if (self._bson != NULL) {
        bson_destroy(self._bson);
        self._bson = NULL;
    }
}

#pragma mark -

- (instancetype) copy {
    bson_t *bson = bson_copy(self.nativeValue);
    return [[self.class alloc] initWithNativeValue:bson];
}

#pragma mark -

- (const bson_t *) nativeValue {
    return self._bson;
}

- (NSData *) dataValue {
    if (self.inData) return self.inData;
    uint32_t length;
    uint8_t * bytes = bson_destroy_with_steal(self._bson, true, &length);
    self._bson = NULL;
    self.finalized = YES;
    return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:YES];
}

- (NSString *) description {
    return NSStringWithJSONFromBSON(self._bson);
}

- (NSDictionary *) dictionaryValueWithError:(NSError **) error {
    return [BSONSerialization dictionaryWithDocument:self error:error];
}

#pragma mark -

+ (NSUInteger) maximumCapacity {
    return BSON_MAX_SIZE;
}

- (BOOL) isEmpty {
    return bson_empty(self._bson);
}

- (BOOL) hasField:(NSString *) key {
    return bson_has_field(self._bson, key.UTF8String);
}

- (NSComparisonResult) compare:(BSONDocument *) other {
    if (![other isKindOfClass:[self class]]) return NSOrderedDescending;
    
    int result = bson_compare(self._bson, other.nativeValue);
    return bson_NSComparisonResultFromQsort(result);
}

- (BOOL) isEqual:(BSONDocument *) document {
    if (![document isKindOfClass:[self class]]) return NO;
    
    return bson_equal(self._bson, document.nativeValue);
}

+ (const void *) saferBytesForData:(NSData *) data {
    // Objective-C's zero data ([NSData data]) has bytes == NULL, which
    // libbson doesn't like. So we swap in this alternate pointer instead.
    static char emptyData[0];
    
    return data.bytes ? data.bytes : emptyData;
}

- (BOOL) appendData:(NSData *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(NSData);
    if (value.length > UINT32_MAX) [NSException raise:NSInvalidArgumentException format:@"Data is too long"];
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_BINARY(self._bson, key.UTF8String, 0, [self.class saferBytesForData:value], (uint32_t)value.length);
}

- (BOOL) appendBool:(BOOL) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_BOOL(self._bson, key.UTF8String, value);
}

- (BOOL) appendCode:(BSONCode *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONCode);
    bson_raise_if_nil(value.code)
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_CODE(self._bson, key.UTF8String, value.code.UTF8String);
}

- (BOOL) appendCodeWithScope:(BSONCodeWithScope *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONCodeWithScope);
    bson_raise_if_nil(value.code);
    bson_raise_if_nil(value.scope);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_CODE_WITH_SCOPE(self._bson, key.UTF8String, value.code.UTF8String, value.scope.nativeValue);
}

- (BOOL) appendDatabasePointer:(BSONDatabasePointer *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONDatabasePointer);
    bson_raise_if_nil(value.collection);
    bson_raise_if_nil(value.objectID);
    bson_raise_if_string_too_long(value.collection, @"Collection name is too long");
    bson_raise_if_key_nil_or_too_long();
    const char * utf8 = key.UTF8String;
    bson_oid_t objectIdNative = value.objectID.nativeValue;
    return bson_append_dbpointer(self._bson, utf8, (int)strlen(utf8), value.collection.UTF8String, &objectIdNative);
}

- (BOOL) appendDouble:(double) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_DOUBLE(self._bson, key.UTF8String, value);
}

- (BOOL) appendEmbeddedDocument:(BSONDocument *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONDocument);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_DOCUMENT(self._bson, key.UTF8String, value.nativeValue);
}

- (BOOL) appendInt32:(int32_t) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_INT32(self._bson, key.UTF8String, value);
}

- (BOOL) appendInt64:(int64_t) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_INT64(self._bson, key.UTF8String, value);
}

- (BOOL) appendMinKeyForKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_MINKEY(self._bson, key.UTF8String);
}

- (BOOL) appendMaxKeyForKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_MAXKEY(self._bson, key.UTF8String);
}

- (BOOL) appendNullForKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_NULL(self._bson, key.UTF8String);
}

- (BOOL) appendObjectID:(BSONObjectID *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONObjectID);
    bson_raise_if_key_nil_or_too_long();
    bson_oid_t objectIDNative = value.nativeValue;
    return BSON_APPEND_OID(self._bson, key.UTF8String, &objectIDNative);
}

- (BOOL) appendRegularExpression:(BSONRegularExpression *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONRegularExpression);
    bson_raise_if_nil(value.pattern);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_REGEX(self._bson, key.UTF8String, value.pattern.UTF8String, [value.options ?: @"" UTF8String]);
}

- (BOOL) appendString:(NSString *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(NSString);
    bson_raise_if_string_too_long(value, @"Value is too long");
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_UTF8(self._bson, key.UTF8String, value.UTF8String);
}

- (BOOL) appendSymbol:(BSONSymbol *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONSymbol);
    bson_raise_if_nil(value.symbol);
    bson_raise_if_string_too_long(value.symbol, @"Value is too long");
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_SYMBOL(self._bson, key.UTF8String, value.symbol.UTF8String);
}

- (BOOL) appendDate:(NSDate *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(NSDate);
    bson_raise_if_key_nil_or_too_long();
    int64_t millis = 1000.f * [value timeIntervalSince1970];
    return BSON_APPEND_DATE_TIME(self._bson, key.UTF8String, millis);
}

- (BOOL) appendTimestamp:(BSONTimestamp *) value forKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_value_is_not_instance_of_class(BSONTimestamp);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_TIMESTAMP(self._bson, key.UTF8String, value.timeInSeconds, value.increment);
}

- (BOOL) appendUndefinedForKey:(NSString *) key {
    bson_raise_if_finalized(self);
    bson_raise_if_key_nil_or_too_long();
    return BSON_APPEND_UNDEFINED(self._bson, key.UTF8String);
}

@end
