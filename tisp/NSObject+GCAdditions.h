//
//  NSObject+GCAdditions.h
//  Garena
//
//  Created by Omer Iqbal on 9/3/16.
//  Copyright © 2016 Lee Sing Jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GCAdditions)

- (NSDictionary *)gc_propertiesDescription;
- (NSString *)gc_recursiveDescription;

@end
