//
//  NSObject+GCAdditions.m
//  Garena
//
//  Created by Omer Iqbal on 9/3/16.
//  Copyright © 2016 Lee Sing Jie. All rights reserved.
//

#import "NSObject+GCAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (GCAdditions)

- (NSDictionary *)gc_propertiesDescription {

    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);

    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);

        if (propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];

            id propertyValue = [self valueForKey:propertyName];

            if (!propertyValue) {
                continue;
            }

            if ([propertyValue isKindOfClass:[NSNumber class]] ||
                [propertyValue isKindOfClass:[NSString class]] ||
                [propertyValue isKindOfClass:[NSData class]]) {
                results[propertyName] = propertyValue;
            }
            else if ([propertyValue isKindOfClass:[NSArray class]]) {
                NSMutableArray *properties = [NSMutableArray array];

                [propertyValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        [properties addObject:obj];
                    }
                    else {
                        NSDictionary *description = [obj gc_propertiesDescription];

                        [properties addObject:description];
                    }
                }];

                results[propertyName] = properties;
            }
            else {
                results[propertyName] = [propertyValue gc_propertiesDescription];
            }
        }
    }

    free(properties);

    // returning a copy here to make sure the dictionary is immutable
    return [results copy];
}

- (NSString *)gc_recursiveDescription {
    return [NSString stringWithFormat:@"[%@: %p] %@", self.class, self, [self gc_propertiesDescription]];
}

@end
