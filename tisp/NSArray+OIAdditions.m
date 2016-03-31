//
//  NSArray+OIAdditions.m
//  tisp
//
//  Created by Omer Iqbal on 1/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import "NSArray+OIAdditions.h"

@implementation NSArray (OIAdditions)

- (NSArray *)takeUntil:(OIFilterBlock)block {
    NSMutableArray *accum = [NSMutableArray array];
    for (id x in self) {
        if (block(x)) {
            return [accum copy];
        } else {
            [accum addObject:x];
        }
    }
    
    return [accum copy];
}

- (NSArray<NSArray *> *)splitBy:(OIFilterBlock)block {
    NSMutableArray *accum1 = [NSMutableArray array];
    NSMutableArray *accum2 = [NSMutableArray array];
    
    BOOL splitted = NO;
    
    for (id x in self) {
        if (!splitted) {
            splitted = block(x);
        }
        if (!splitted) {
            [accum1 addObject:x];
        } else {
            [accum2 addObject:x];
        }
    }
    
    return @[accum1, accum2];
}

- (NSArray *)rest {
    return [self subarrayWithRange:NSMakeRange(1, self.count - 1)];
}

- (NSArray *)map:(OIMapBlock)map {
    NSMutableArray *accum = [NSMutableArray array];
    for (id x in self) {
        id res = map(x);
        if (res) {
            [accum addObject:res];
        }
    }
    
    return [accum copy];
}

@end
