//
//  JITHelper.hpp
//  tisp
//
//  Created by Omer Iqbal on 8/4/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#ifndef JITHelper_hpp
#define JITHelper_hpp

#include "llvm/Analysis/Passes.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Transforms/Scalar.h"

using namespace llvm;

std::string MakeLegalFunctionName(std::string Name);

//===----------------------------------------------------------------------===//
// MCJIT helper class
//===----------------------------------------------------------------------===//

class MCJITHelper {
public:
    MCJITHelper(LLVMContext &C) : Context(C), OpenModule(NULL) {}
    ~MCJITHelper();
    
    Function *getFunction(const std::string FnName);
    Module *getModuleForNewFunction();
    void *getPointerToFunction(Function *F);
    void *getSymbolAddress(const std::string &Name);
    void dump();
    
private:
    typedef std::vector<Module *> ModuleVector;
    typedef std::vector<ExecutionEngine *> EngineVector;
    
    LLVMContext &Context;
    Module *OpenModule;
    ModuleVector Modules;
    EngineVector Engines;
};

class HelpingMemoryManager : public SectionMemoryManager {
    HelpingMemoryManager(const HelpingMemoryManager &) = delete;
    void operator=(const HelpingMemoryManager &) = delete;
    
public:
    HelpingMemoryManager(MCJITHelper *Helper) : MasterHelper(Helper) {}
    ~HelpingMemoryManager() override {}
    
    /// This method returns the address of the specified symbol.
    /// Our implementation will attempt to find symbols in other
    /// modules associated with the MCJITHelper to cross link symbols
    /// from one generated module to another.
    uint64_t getSymbolAddress(const std::string &Name) override;
    
private:
    MCJITHelper *MasterHelper;
};


#endif /* JITHelper_hpp */
