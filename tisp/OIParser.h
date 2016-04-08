//
//  OIParser.h
//  tisp
//
//  Created by Omer Iqbal on 1/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OITokenizer.h"

@protocol OIParseable;

@interface OIParserResult : NSObject

@property (nonatomic, copy) NSArray<OIToken *> *tokensRemaining;
@property (nonatomic, strong) id<OIParseable> expr;

@end

@interface OIParser : NSObject

+ (OIParserResult *)parseFromTokens:(NSArray<OIToken *> *)tokens;

+ (OIParserResult *)parseTopLevelFromTokens:(NSArray<OIToken *> *)tokens;

@end
