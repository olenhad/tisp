//
//  OITokenizer.h
//  tisp
//
//  Created by Omer Iqbal on 1/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int32_t, OITokenType) {
    OITokenTypeParen,
    OITokenTypeNumber,
    OITokenTypeName,
    OITokenTypeOp
};

@interface OIToken : NSObject

@property (nonatomic, assign) OITokenType type;
@property (nonatomic, copy) NSString *val;

+ (OIToken *)type:(OITokenType)type val:(NSString *)val;

@end

@interface OITokenizer : NSObject

+ (NSArray<OIToken *> *)tokenize:(NSString *)input;

@end
