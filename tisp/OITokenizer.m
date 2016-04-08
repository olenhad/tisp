//
//  OITokenizer.m
//  tisp
//
//  Created by Omer Iqbal on 1/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import "OITokenizer.h"
#import "NSObject+GCAdditions.h"

@implementation OIToken

+ (OIToken *)type:(OITokenType)type val:(NSString *)val {
    OIToken *token = [[OIToken alloc] init];
    token.type = type;
    token.val = val;
    return token;
}

- (NSString *)description {
    return [self gc_recursiveDescription];
}

@end

@implementation OITokenizer

+ (NSArray<OIToken *> *)tokenize:(NSString *)input {
    NSUInteger current = 0;
    
    NSMutableArray<OIToken *> *tokens = [NSMutableArray array];
    
    while (current < input.length) {
        
        unichar currentChar = [input characterAtIndex:current];
        
        if (currentChar == '(') {
            [tokens addObject:[OIToken type:OITokenTypeParen val:@"("]];
            
            current++;
            continue;
        }
        
        
        if (currentChar == ')') {
            [tokens addObject:[OIToken type:OITokenTypeParen val:@")"]];
            
            current++;
            continue;
        }
        
        if (currentChar == '+' || 
            currentChar == '*' || 
            currentChar == '-' || 
            currentChar == '<' || 
            currentChar == '>' || 
            currentChar == '=') {
            [tokens addObject:[OIToken type:OITokenTypeOp val:[NSString stringWithFormat:@"%C", currentChar]]];
            
            current++;
            continue;
        }
        
        NSString *whitespace = @"\\s";
        if ([self testRegex:whitespace character:currentChar]) {
            current++;
            continue;
        }
        
        NSString *digit = @"[0-9]";
        if ([self testRegex:digit character:currentChar]) {
            
            NSMutableString *val = [NSMutableString string];
            BOOL usedDecimal = NO;
            while ([self testRegex:digit character:currentChar] || (!usedDecimal && currentChar == '.')) {
                [val appendFormat:@"%C", currentChar];
                if (currentChar == '.') {
                    usedDecimal = YES;
                }
                
                if (current + 1 == input.length) {
                    [tokens addObject:[OIToken type:OITokenTypeNumber val:val]];
                    return tokens;
                }
                currentChar = [input characterAtIndex:++current];
            }
            
            [tokens addObject:[OIToken type:OITokenTypeNumber val:val]];
            
            continue;
        }
        
        NSString *letter = @"[a-zA-Z]";
        if ([self testRegex:letter character:currentChar]) {
            NSMutableString *val = [NSMutableString string];
            while ([self testRegex:letter character:currentChar]) {
                [val appendFormat:@"%C", currentChar];
  
                if (current + 1 == input.length) {
                    [tokens addObject:[OIToken type:OITokenTypeName val:val]];
                    return tokens;
                }
                currentChar = [input characterAtIndex:++current];
            }
            
            [tokens addObject:[OIToken type:OITokenTypeName val:val]];
            
            continue;
        }
        
        NSLog(@"I can't tokenise this shit: %C", currentChar);
        return nil;
    }
    
    return tokens;
}

+ (BOOL)testRegex:(NSString *)regex character:(unichar)c {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex] evaluateWithObject:[NSString stringWithFormat:@"%C", c]];
}

@end
