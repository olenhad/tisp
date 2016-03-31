//
//  main.m
//  tisp
//
//  Created by Omer Iqbal on 31/3/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OIContext.h"

#import "OITokenizer.h"

#import "OIParser.h"
#import "OIExpr.h"

#import <iostream>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        NSString *func = @"(defn add (a b) (+ a b))";
        NSArray *t1 = [OITokenizer tokenize:func];
        NSLog(@"Tokens: %@", t1);

        OIParserResult *p1 = [OIParser parseFromTokens:t1];
        NSLog(@"%@", p1);
        
        OIContext *context = [OIContext new];
        context->module = new llvm::Module ("tisp", llvm::getGlobalContext());
        
        while (YES) {
            std::cout << "tisp>";
            std::string line;
            std::getline(std::cin, line);
            
            NSString *nsLine = [NSString stringWithUTF8String:line.c_str()];
            if ([nsLine isEqualToString:@";;"]) {
                return 0;
            }
            
            NSArray *tokens = [OITokenizer tokenize:nsLine];
            NSLog(@"Tokens: %@", tokens);
            
            OIParserResult *parseResult = [OIParser parseFromTokens:tokens];
            NSLog(@"Parse Result: %@", parseResult);
            
            if (parseResult) {
                OIExpr *expr = (OIExpr *)parseResult.expr;
                
                llvm::Value *IR = [expr codegenWithContext:context];
                
                IR->dump();
            }

        }
        
    }
    return 0;
}
