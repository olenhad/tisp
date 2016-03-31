//
//  NSArray+OIAdditions.h
//  tisp
//
//  Created by Omer Iqbal on 1/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^OIFilterBlock)(id obj);
typedef id (^OIMapBlock)(id obj);

@interface NSArray (OIAdditions)

- (NSArray *)takeUntil:(OIFilterBlock)block;
- (NSArray<NSArray *> *)splitBy:(OIFilterBlock)block;

- (NSArray *)rest;

- (NSArray *)map:(OIMapBlock)map;

@end
