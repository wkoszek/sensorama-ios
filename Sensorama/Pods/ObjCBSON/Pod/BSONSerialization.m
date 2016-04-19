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

#import "BSONSerialization.h"
#import "BSONSerializer.h"
#import "BSONDeserializer.h"
#import "BSONTypes.h"
#import "ObjCBSON-private.h"
#import "BSONDocument.h"
#import "ObjCBSON.h"
#import <bson.h>

#pragma mark - Module interfaces

@interface BSONDocument (Module)
- (const bson_t *) nativeValue;
- (id) initWithNativeValue:(bson_t *) bson;
@end

@interface BSONSerialization (Module)
+ (NSDictionary *) dictionaryWithDocument:(BSONDocument *) document error:(NSError **) error;
+ (BSONDocument *) BSONDocumentWithDictionary:(NSDictionary *) dictionary error:(NSError **) error;
@end

@implementation BSONSerialization

+ (NSDictionary *) dictionaryWithDocument:(BSONDocument *) document error:(NSError **) error {
    return [BSONDeserializer dictionaryWithNativeDocument:document.nativeValue error:error];
}

+ (NSDictionary *) dictionaryWithBSONData:(NSData *) data error:(NSError **) error {
    bson_raise_if_nil(data);
    BSONDocument *document = [BSONDocument documentWithData:data noCopy:YES];
    if (document == nil) {
        if (error) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Unable to create document" };
            *error = [NSError errorWithDomain:BSONErrorDomain code:-1 userInfo:userInfo];
        }
        return nil;
    }
    return [self dictionaryWithDocument:document error:error];
}

+ (BSONDocument *) BSONDocumentWithDictionary:(NSDictionary *) dictionary error:(NSError **) error {
    bson_raise_if_nil(dictionary);
    BSONSerializer *serializer = [BSONSerializer serializer];
    if ([serializer serializeDictionary:dictionary error:error])
        return serializer.document;
    else
        return nil;
}

+ (NSData *) BSONDataWithDictionary:(NSDictionary *) dictionary error:(NSError **) error {
    return [[self BSONDocumentWithDictionary:dictionary error:error] dataValue];
}

@end
