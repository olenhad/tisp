//
//  OIContext.h
//  tisp
//
//  Created by Omer Iqbal on 31/3/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#include <llvm/ADT/STLExtras.h>
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include <cctype>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
#import <memory.h>
#import <map>
#import <Foundation/Foundation.h>

class MCJITHelper;

static llvm::IRBuilder<> Builder(llvm::getGlobalContext());

@interface OIContext : NSObject {
    @public
    std::map<std::string, llvm::Value *> namedValues;
    MCJITHelper *JITHelper;
}

@end
