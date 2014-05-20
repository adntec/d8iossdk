//
//  DrupalEntityDeserializer.m
//  DrupalLib
//
//  Created by Oleg Stasula on 19.05.14.
//  Copyright (c) 2014 ls. All rights reserved.
//

#import "DrupalEntityDeserializer.h"
#import "DrupalEntity.h"
#import "DrupalEntity+Properties.h"


@implementation DrupalEntityDeserializer

+ (id)deserializeEntity:(DrupalEntity *)entity fromData:(NSDictionary *)data {
    NSArray *properties = [entity allProperties];
    for (NSString *prop in data.allKeys) {
        if ([properties indexOfObject:prop] == NSNotFound)
            continue;
        
        NSString *setterName = [NSString stringWithFormat:@"set%@:", [prop stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[prop substringToIndex:1] capitalizedString]]];
        SEL setterSelector = NSSelectorFromString(setterName);
        if (![entity respondsToSelector:setterSelector])
            continue;
        
        Class propClass = [entity classOfProperty:prop];
        Class itemClass = [entity classByPropertyName:prop];
        id value = [data objectForKey:prop];
        if ([value isKindOfClass:[NSDictionary class]] && [propClass isSubclassOfClass:[DrupalEntity class]]) {
            value = [DrupalEntityDeserializer deserializeEntityClass:propClass fromData:value];
        } else if ([value isKindOfClass:[NSArray class]] && [itemClass isSubclassOfClass:[DrupalEntity class]]) {
            NSMutableArray *obj = [NSMutableArray array];
            for (NSDictionary *d in value)
                [obj addObject:[DrupalEntityDeserializer deserializeEntityClass:itemClass fromData:d]];
            value = obj;
        }
        [entity performSelector:setterSelector withObject:value];
    }
    return entity;
}


+ (id)deserializeEntities:(DrupalEntity *)entity fromData:(NSArray *)data {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *d in data)
        [array addObject:[DrupalEntityDeserializer deserializeEntity:entity fromData:d]];
    return array;
}


+ (id)deserializeEntityClass:(Class)entityClass fromData:(NSDictionary *)data {
    return [DrupalEntityDeserializer deserializeEntity:[entityClass new] fromData:data];
}


+ (id)deserializeEntitiesClass:(Class)entityClass fromData:(NSArray *)data {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *d in data)
        [array addObject:[DrupalEntityDeserializer deserializeEntity:[entityClass new] fromData:d]];
    return array;
}

@end
