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

#import "BSONSerializer.h"
#import "ObjCBSON.h"
#import "BSONDocument.h"
#import "ObjCBSON-private.h"

@interface BSONDocument (Module)
- (const bson_t *) nativeValue;
- (id) initWithNativeValue:(bson_t *) bson;
@end

@implementation BSONSerializer

- (id) initWithDocument:(BSONDocument *) document {
    if (self = [super init]) {
        self.document = document;
    }
    return self;
}

+ (instancetype) serializer {
    return [[self alloc] initWithDocument:[BSONDocument document]];
}

+ (instancetype) serializerWithNativeDocument:(bson_t *) nativeDocument {
    BSONDocument *document = [[BSONDocument alloc] initWithNativeValue:nativeDocument];
    return [[self alloc] initWithDocument:document];
}

- (bson_t *) nativeValue {
    return (bson_t *)self.document.nativeValue;
}

#pragma mark - Generalized serialization methods

+ (Class) _booleanClass {
    // The boolean class is private, so we acesss it this way.
    static Class singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[NSNumber numberWithBool:YES] class];
    });
    return singleton;
}

- (BOOL) _appendNumber:(NSNumber *) number forKey:(NSString *) key error:(NSError **) error {
    // Booleans are a special case. NSNumber stores them as signed chars.
    // CFNumberGetType((CFNumberRef) [NSNumber numberWithBool:YES]) returns kCFNumberCharType
    // [[NSNumber numberWithBool:YES] objCType] returns "c"
    // These are the same values as for [NSNumber numberWithChar:'a']
    // So instead, we check its class.
    if ([number isKindOfClass:[self.class _booleanClass]]) {
        return [self.document appendBool:number.boolValue forKey:key];
    }
    
    switch (*(number.objCType)) {
        case 'f': // float
        case 'd': // double
            return [self.document appendDouble:number.doubleValue forKey:key];
        case 'l': // long
            if (number.longValue > INT64_MAX) {
                if (error) {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Signed integer value overflows BSON integer capacity" };
                    *error = [NSError errorWithDomain:BSONErrorDomain code:BSONIntegerOverflow userInfo:userInfo];
                }
                return NO;
            }
            return [self.document appendInt64:number.longValue forKey:key];
        case 'L': // unsigned long
            if (number.unsignedLongValue > INT64_MAX) {
                if (error) {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Unsigned integer value overflows BSON signed integer capacity" };
                    *error = [NSError errorWithDomain:BSONErrorDomain code:BSONIntegerOverflow userInfo:userInfo];
                }
                return NO;
            }
            return [self.document appendInt64:number.unsignedLongValue forKey:key];
        case 'q': // long long
            if (number.longLongValue > INT64_MAX) {
                if (error) {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Signed integer value overflows BSON integer capacity" };
                    *error = [NSError errorWithDomain:BSONErrorDomain code:BSONIntegerOverflow userInfo:userInfo];
                }
                return NO;
            }
            return [self.document appendInt64:number.longLongValue forKey:key];
        case 'Q': // unsigned long long
            if (number.unsignedLongLongValue > INT64_MAX) {
                if (error) {
                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Unsigned integer value overflows BSON signed integer capacity" };
                    *error = [NSError errorWithDomain:BSONErrorDomain code:BSONIntegerOverflow userInfo:userInfo];
                }
                return NO;
            }
            return [self.document appendInt64:number.unsignedLongLongValue forKey:key];
        case 'B': // C++ bool / C99 _Bool
            return [self.document appendBool:number.boolValue forKey:key];
        case 'c': // char. Used for ObjC numberWithChar:, and also for numberWithBool: which we handle above
            return [self.document appendInt32:number.charValue forKey:key];
        case 'C': // unsigned char
            return [self.document appendInt32:number.unsignedCharValue forKey:key];
        case 's': // short
            return [self.document appendInt32:number.shortValue forKey:key];
        case 'S': // unsigned short
            return [self.document appendInt32:number.unsignedShortValue forKey:key];
        case 'i': // int
            return [self.document appendInt32:number.intValue forKey:key];
        case 'I': // unsigned int
            return [self.document appendInt64:number.unsignedIntValue forKey:key];
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unexpected objCType: %s", number.objCType];
            return NO;
    }
}

- (BOOL) _appendDictionary:(NSDictionary *) dictionary forKey:(NSString *) key error:(NSError **) error {
    bson_raise_if_key_nil_or_too_long();
    const char *utf8 = [key UTF8String];

    bson_t child;
    bson_append_document_begin(self.nativeValue, utf8, (int)strlen(utf8), &child);
    BSONSerializer *childSerializer = [BSONSerializer serializerWithNativeDocument:&child];

    BOOL success = YES;
    for (NSString *key in dictionary.allKeys) {
        id obj = [dictionary objectForKey:key];
        if (![childSerializer appendObject:obj forKey:key error:error]) {
            success = NO;
            break;
        }
    }
    
    bson_append_document_end(self.nativeValue, &child);
    return success;
}

- (BOOL) _appendArray:(NSArray *) array forKey:(NSString *) key error:(NSError **) error {
    bson_raise_if_key_nil_or_too_long();
    const char *utf8 = [key UTF8String];

    bson_t *child = bson_new();
    bson_append_array_begin(self.nativeValue, utf8, (int)strlen(utf8), child);
    BSONSerializer *childSerializer = [BSONSerializer serializerWithNativeDocument:child];
    
    BOOL success = YES;
    for (NSUInteger i = 0; i < array.count; ++i) {
        id obj = [array objectAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)i];
        if (![childSerializer appendObject:obj forKey:key error:error]) {
            success = NO;
            break;
        }
    }
    
    bson_append_array_end(self.nativeValue, child);
    return success;
}

- (BOOL) appendObject:(id) value forKey:(NSString *) key error:(NSError **) error {
    bson_raise_if_nil(value);
    
    // Collection and NSNumber types have their own error handling
    
    if ([value isKindOfClass:[NSDictionary class]])
        return [self _appendDictionary:value forKey:key error:error];
    
    else if ([value isKindOfClass:[NSOrderedSet class]])
        return [self _appendArray:[value array] forKey:key error:error];
    
    else if ([value isKindOfClass:[NSArray class]])
        return [self _appendArray:value forKey:key error:error];
    
    else if ([value isKindOfClass:[NSNumber class]])
        return [self _appendNumber:value forKey:key error:error];
    
    // Other types
    
    BOOL result = NO;
    
    if ([NSNull null] == value)
        result = [self.document appendNullForKey:key];
    
    else if ([BSONUndefined undefined] == value)
        result = [self.document appendUndefinedForKey:key];
    
    else if ([value isKindOfClass:[BSONObjectID class]])
        result = [self.document appendObjectID:value forKey:key];
    
    else if ([value isKindOfClass:[BSONRegularExpression class]])
        result = [self.document appendRegularExpression:value forKey:key];
    
    else if ([value isKindOfClass:[BSONTimestamp class]])
        result = [self.document appendTimestamp:value forKey:key];
    
    else if ([value isMemberOfClass:[BSONCode class]])
        result = [self.document appendCode:value forKey:key];
    
    else if ([value isMemberOfClass:[BSONCodeWithScope class]])
        result = [self.document appendCodeWithScope:value forKey:key];
    
    else if ([value isKindOfClass:[BSONSymbol class]])
        result = [self.document appendSymbol:value forKey:key];
    
    else if ([value isKindOfClass:[NSString class]])
        result = [self.document appendString:value forKey:key];
    
    else if ([value isKindOfClass:[NSDate class]])
        result = [self.document appendDate:value forKey:key];
    
    else if ([value isKindOfClass:[NSData class]])
        result = [self.document appendData:value forKey:key];
    
    else if ([value isKindOfClass:[BSONDocument class]])
        result = [self.document appendEmbeddedDocument:value forKey:key];
    
    else {
        if (error) {
            id message =
            [NSString stringWithFormat:@"Unserializable class: %@", NSStringFromClass(([value class]))];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: message };
            *error = [NSError errorWithDomain:BSONErrorDomain code:BSONSerializationUnsupportedClass userInfo:userInfo];
        }
        return NO;
    }
    
    if (!result) {
        if (error) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"BSON object overflow" };
            *error = [NSError errorWithDomain:BSONErrorDomain code:BSONDocumentOverflow userInfo:userInfo];
        }
        return NO;
    }
    
    return result;
}

- (BOOL) serializeDictionary:(NSDictionary *) dictionary error:(NSError **) error {
    for (NSString *key in [dictionary allKeys]) {
        id obj = [dictionary objectForKey:key];
        if (![self appendObject:obj forKey:key error:error]) {
            return NO;
        }
    }
    return YES;
}

@end
