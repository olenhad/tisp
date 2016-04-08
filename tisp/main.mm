//
//  main.m
//  tisp
//
//  Created by Omer Iqbal on 31/3/16.
//  Copyright © 2016 Garena. All rights reserved.
//

//#import "TispJIT.hpp"


#import "JITHelper.h"

#import "OIContext.h"

#import "OITokenizer.h"

#import "OIParser.h"
#import "OIExpr.h"

#import <iostream>


#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...

        llvm::InitializeNativeTarget();
        llvm::InitializeNativeTargetAsmPrinter();
        llvm::InitializeNativeTargetAsmParser();
        
        OIContext *context = [OIContext new];

        context->JITHelper = new MCJITHelper(llvm::getGlobalContext());
        
        while (YES) {
            std::cout << "tisp>";
            std::string line;
            std::getline(std::cin, line);
            
            NSString *nsLine = [NSString stringWithUTF8String:line.c_str()];
            if ([nsLine isEqualToString:@";;"]) {
                return 0;
            }
            
            NSArray *tokens = [OITokenizer tokenize:nsLine];
            
            OIParserResult *parseResult = [OIParser parseFromTokens:tokens];
            NSLog(@"Parse Result: %@", parseResult);
            
            if (parseResult && ![parseResult.expr isTopLevel]) {
                
                OIExpr *expr = (OIExpr *)parseResult.expr;
                llvm::Value *value = [expr codegenWithContext:context];
                
                value->dump();
                

            
            } else if (parseResult && [parseResult.expr isTopLevel]) {
                
                NSLog(@"Top Level:...");
                
                OIExpr *expr = (OIExpr *)parseResult.expr;
                llvm::Value *value = [expr codegenWithContext:context];
                
                value->dump();
//                // Make an anon proto
//                OIPrototypeExpr *proto = [OIPrototypeExpr name:@"" args:@[]];
//                OIFunctionExpr *topLevel = [OIFunctionExpr proto:proto body:parseResult.expr];
//                
//                llvm::Function *function = [topLevel codegenWithContext:context];
//                
//                function->dump();
//                
//                // JIT the function, returning a function pointer.
//                void *FPtr = context->JITHelper->getPointerToFunction(function);
//                
//                // Cast it to the right type (takes no arguments, returns a double) so we
//                // can call it as a native function.
//                double (*FP)() = (double (*)())(intptr_t)FPtr;
//                fprintf(stderr, "Evaluated to %f\n", FP());
            }

        }
        
    }
    return 0;
}

