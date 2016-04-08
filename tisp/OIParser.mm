//
//  OIParser.m
//  tisp
//
//  Created by Omer Iqbal on 1/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import "OIParser.h"
#import "NSArray+OIAdditions.h"
#import "NSObject+GCAdditions.h"
#import "OIExpr.h"

@implementation OIParserResult

+ (instancetype)res:(id<OIParseable>)expr rem:(NSArray<OIToken *> *)rem {
    OIParserResult *res = [OIParserResult new];
    res.tokensRemaining = rem;
    res.expr = expr;
    return res;
}

//- (NSString *)description {
//    return [self gc_recursiveDescription];
//}

@end

@implementation OIParser

+ (OIParserResult *)parseTopLevelFromTokens:(NSArray<OIToken *> *)tokens {
    OIParserResult *result = [self parseFromTokens:tokens];
    if (!result) {
        return nil;
    }
    
    // Make an anon proto
    OIPrototypeExpr *proto = [OIPrototypeExpr name:@"" args:@[]];
    OIFunctionExpr *topLevel = [OIFunctionExpr proto:proto body:result.expr];
    
    return [OIParserResult res:topLevel rem:result.tokensRemaining];
}

+ (OIParserResult *)parseFromTokens:(NSArray<OIToken *> *)tokens {
    OIToken *first = [tokens firstObject];
    if (first == nil) {
        NSLog(@"Parsing failed");
        return nil;
    }
    
    if (first.type == OITokenTypeNumber) {
        return [OIParserResult res:[OINumberExpr val:first.val.doubleValue] rem:[tokens rest]];
    }
    
    if (first.type == OITokenTypeName) {
        return [OIParserResult res:[OIVarExpr name:first.val] rem:[tokens rest]];
    }
    
    if (first.type == OITokenTypeParen && [first.val isEqualToString:@"("]) {
        if (tokens.count == 1) {
            NSLog(@"Parsing failed");
            return nil;
        }
        OIToken *next = tokens[1];
        
        if (next.type == OITokenTypeOp) {
            return [self parseBinOpFromTokens:[tokens rest]];
        }
        
        if (next.type == OITokenTypeName) {
            if ([next.val isEqualToString:@"defn"]) {
                return [self parseFunctionFromTokens:[[tokens rest] rest]];
            }
            if ([next.val isEqualToString:@"if"]) {
                return [self parseIfFromTokens:[tokens rest]];
            }
            return [self parseCallFromTokens:[tokens rest]];
        }
    }
    
    NSLog(@"Parsing failed");
    return nil;
}

+ (OIParserResult *)parseBinOpFromTokens:(NSArray<OIToken *> *)tokens {
    OIToken *first = [tokens firstObject];
    
    OIParserResult *lhs = [self parseFromTokens:[tokens rest]];
    if (lhs.tokensRemaining.count < 2) {
        NSLog(@"Parsing failed for bin op");
        return nil;
    }
    
    OIParserResult *rhs = [self parseFromTokens:lhs.tokensRemaining];
    if (rhs.tokensRemaining.count == 0) {
        NSLog(@"Parsing failed for bin op");
        return nil;
    }
    
    OIToken *next = rhs.tokensRemaining.firstObject;
    if (!(next.type == OITokenTypeParen && [next.val isEqualToString:@")"])) {
        NSLog(@"Parsing failed. Expected ')'");
        return nil;
    }
    
    return [OIParserResult res:[OIBinExpr op:first.val lhs:lhs.expr rhs:rhs.expr] 
                           rem:[rhs.tokensRemaining rest]];
}

+ (OIParserResult *)parseFunctionFromTokens:(NSArray<OIToken *> *)tokens {
    OIToken *first = [tokens firstObject];
    if (first.type != OITokenTypeName) {
        NSLog(@"Parsing failed. Expected name");
        return nil;
    }
    
    OIParserResult *funcProto = [self parseArgListFromTokens:[tokens rest] funcName:first.val];
    if (!funcProto || funcProto.tokensRemaining.count == 0 || ![funcProto.expr isKindOfClass:[OIPrototypeExpr class]]) {
        NSLog(@"Parsing failed. Expected body, or valid def");
        return nil;
    }
    
    OIParserResult *funcBody = [self parseFromTokens:funcProto.tokensRemaining];
    if (!funcBody) {
        NSLog(@"Parsing failed. Expected func body");
        return nil;
    }
    return [OIParserResult res:[OIFunctionExpr proto:(OIPrototypeExpr *)funcProto.expr body:(OIExpr *)funcBody.expr] 
                           rem:funcBody.tokensRemaining];
}

+ (OIParserResult *)parseArgListFromTokens:(NSArray<OIToken *> *)tokens funcName:(NSString *)funcName {
    OIToken *first = [tokens firstObject];
    if (!(first.type == OITokenTypeParen && [first.val isEqualToString:@"("])) {
        NSLog(@"Parsing failed. Expected '('");
        return nil;
    }
    
    NSArray<OIToken *> *rest = [tokens rest];
    
    NSArray *tuple = [rest splitBy:^BOOL(OIToken *token) {
        return token.type != OITokenTypeName;
    }];
    
    NSArray<OIToken *> *args = [tuple firstObject];
    
    NSArray<NSString *> *names = [args map:^NSString *(OIToken *token) {
        return token.val;
    }];
    
    OIPrototypeExpr *expr = [OIPrototypeExpr name:funcName args:names];
 
    NSArray<OIToken *> *remainingAfterArgs = [tuple lastObject];
    if (!(remainingAfterArgs.firstObject.type == OITokenTypeParen && [remainingAfterArgs.firstObject.val isEqualToString:@")"])) {
        NSLog(@"Parsing failed. Expected ')'");
        return nil;
    }
    
    return [OIParserResult res:expr rem:[remainingAfterArgs rest]];
}

+ (OIParserResult *)parseCallFromTokens:(NSArray<OIToken *> *)tokens {
    OIToken *first = [tokens firstObject];
    NSParameterAssert(first.type == OITokenTypeName);
    
    NSArray<OIToken *> *remaining = [tokens rest];
    NSMutableArray<OIExpr *> *exprs = [NSMutableArray array];
    
    while (!(remaining.firstObject.type == OITokenTypeParen && [remaining.firstObject.val isEqualToString:@")"])) {
        OIParserResult *result = [self parseFromTokens:remaining];
        if (!result) {
            NSLog(@"Parsing failed. Expected expr");
            return nil;
        }
        remaining = result.tokensRemaining;
        [exprs addObject:result.expr];
    }
    
    return [OIParserResult res:[OICallExpr name:first.val args:exprs] rem:[remaining rest]];
}

+ (OIParserResult *)parseIfFromTokens:(NSArray<OIToken *> *)tokens {
    OIToken *first = [tokens firstObject];
    if (!(first.type == OITokenTypeName && [first.val isEqualToString:@"if"])) {
        NSLog(@"Expected if");
        return nil;
    }
    
    OIParserResult *cond = [self parseFromTokens:tokens.rest];
    if (!cond) {
        return nil;
    }
    
    OIParserResult *then = [self parseFromTokens:cond.tokensRemaining];
    if (!then) {
        return nil;
    }
    
    OIParserResult *elseE = [self parseFromTokens:then.tokensRemaining];
    if (!elseE) {
        return nil;
    }
    
    if (!(elseE.tokensRemaining.firstObject.type == OITokenTypeParen && [elseE.tokensRemaining.firstObject.val isEqualToString:@")"])) {
        return nil;
    }
    
    OIIfExpr *expr = [OIIfExpr cond:cond.expr then:then.expr elseE:elseE.expr];
    
    return [OIParserResult res:expr rem:elseE.tokensRemaining.rest];
}

@end
