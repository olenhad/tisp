//
//  OIContext.h
//  tisp
//
//  Created by Omer Iqbal on 31/3/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <llvm/IR/LLVMContext.h>
#import <llvm/IR/IRBuilder.h>
#import <llvm/IR/Module.h>

#import <memory.h>
#import <map>

static llvm::IRBuilder<> Builder(llvm::getGlobalContext());

@interface OIContext : NSObject {
    @public
    std::map<std::string, llvm::Value *> namedValues;
    llvm::Module *module;
}

@end
