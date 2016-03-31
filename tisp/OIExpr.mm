//
//  OIExpr.m
//  tisp
//
//  Created by Omer Iqbal on 31/3/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import "OIExpr.h"
#import <llvm/IR/LLVMContext.h>
#import <llvm/IR/Constants.h>
#import <llvm/ADT/APFloat.h>
#import <llvm/IR/BasicBlock.h>
#import <llvm/IR/Verifier.h>
#import "NSObject+GCAdditions.h"

@implementation OIExpr

- (llvm::Value *)codegenWithContext:(OIContext *)ctx {
    NSParameterAssert(NO);
    return nil;
}

//- (NSString *)description {
//    return [self gc_recursiveDescription];
//}

@end

@implementation OINumberExpr

- (instancetype)initWithVal:(double)val {
    self = [super init];
    if (self) {
        _val = val;
    }
    return self;
}

+ (instancetype)val:(double)val {
    return [[self alloc] initWithVal:val];
}

- (llvm::Value *)codegenWithContext:(OIContext *)ctx {
    return llvm::ConstantFP::get(llvm::getGlobalContext(), llvm::APFloat(self.val));
}

@end


@implementation OIVarExpr

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

+ (instancetype)name:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (llvm::Value *)codegenWithContext:(OIContext *)ctx {
    llvm::Value *v = ctx->namedValues[std::string([self.name UTF8String])];
    if (!v) {
        NSLog(@"Error! Unknown variable name %@", self.name);
    }
    return v;
}

@end

@interface OIBinExpr ()
@property (nonatomic, copy) NSString *op;
@property (nonatomic, strong) OIExpr *lhs;
@property (nonatomic, strong) OIExpr *rhs;
@end

@implementation OIBinExpr

+ (instancetype)op:(NSString *)op lhs:(OIExpr *)lhs rhs:(OIExpr *)rhs {
    OIBinExpr *expr = [[OIBinExpr alloc] init];
    expr.op = op;
    expr.lhs = lhs;
    expr.rhs = rhs;
    return expr;
}

- (llvm::Value *)codegenWithContext:(OIContext *)ctx {
    llvm::Value *l = [self.lhs codegenWithContext:ctx];
    llvm::Value *r = [self.rhs codegenWithContext:ctx];
    
    if (!l || ! r) {
        NSLog(@"Couldn't generate bin expr");
        return nil;
    }
    
    if ([self.op isEqualToString:@"+"]) {
        return Builder.CreateFAdd(l, r, "addtmp");
    }
    if ([self.op isEqualToString:@"-"]) {
        return Builder.CreateFSub(l, r, "subtmp");
    }
    if ([self.op isEqualToString:@"*"]) {
        return Builder.CreateFMul(l, r, "multmp");
    }
    if ([self.op isEqualToString:@"<"]) {
        llvm::Value *intcmp = Builder.CreateFCmpULT(l, r, "cmptmp");
        return Builder.CreateUIToFP(intcmp, llvm::Type::getDoubleTy(llvm::getGlobalContext()), "booltmp");
    }
    NSLog(@"Unsupported Binary operator");
    return nil;
}

@end

@interface OICallExpr ()

@property (nonatomic, copy) NSString *callee;
@property (nonatomic, copy) NSArray<OIExpr *> *args;

@end

@implementation OICallExpr

+ (instancetype)name:(NSString *)name args:(NSArray<OIExpr *> *)args {
    OICallExpr *expr = [[OICallExpr alloc] init];
    expr.callee = name;
    expr.args = args;
    return expr;
}

- (llvm::Value *)codegenWithContext:(OIContext *)ctx {
    llvm::Function *calleeF = ctx->module->getFunction(std::string([self.callee UTF8String]));
    if (!calleeF) {
        NSLog(@"Unknown Function Referenced");
        return nil;
    }
    
    if (calleeF->arg_size() != self.args.count) {
        NSLog(@"Incorrect #arguments passed to %@", self.callee);
        return nil;
    }
    
    std::vector<llvm::Value *> generatedArgs;
    for (OIExpr *arg in self.args) {
        llvm::Value *generated = [arg codegenWithContext:ctx];
        if (!generated) {
            return nil;
        }
        generatedArgs.push_back(generated);
    }
    
    return Builder.CreateCall(calleeF, generatedArgs, "calltmp");
}

@end

@interface OIPrototypeExpr ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<NSString *> *args;

@end

@implementation OIPrototypeExpr

+ (instancetype)name:(NSString *)name args:(NSArray<NSString *> *)args {
    OIPrototypeExpr *expr = [[OIPrototypeExpr alloc] init];
    expr.name = name;
    expr.args = args;
    return expr;
}

- (llvm::Function *)codegenWithContext:(OIContext *)ctx {
    // Make the function type:  double(double,double) etc.
    std::vector<llvm::Type*> doubles(self.args.count,
                                     llvm::Type::getDoubleTy(llvm::getGlobalContext()));
    
    llvm::FunctionType *functionType = 
    llvm::FunctionType::get(llvm::Type::getDoubleTy(llvm::getGlobalContext()), doubles, false);
    
    llvm::Function *function =
    llvm::Function::Create(functionType, 
                           llvm::Function::ExternalLinkage, 
                           std::string([self.name UTF8String]),
                           ctx->module);
    
    // Set names for all arguments.
    unsigned idx = 0;
    for (auto &arg : function->args()) {
        arg.setName(std::string([self.args[idx] UTF8String]));
        idx++;
    }
    
    return function;
}

//- (NSString *)description {
//    return [self gc_recursiveDescription];
//}

@end

@interface OIFunctionExpr ()
@property (nonatomic, strong) OIPrototypeExpr *proto;
@property (nonatomic, strong) OIExpr *body;
@end

@implementation OIFunctionExpr

+ (instancetype)proto:(OIPrototypeExpr *)proto body:(OIExpr *)body {
    OIFunctionExpr *expr = [[OIFunctionExpr alloc] init];
    expr.proto = proto;
    expr.body = body;
    return expr;
}

- (llvm::Value *)codegenWithContext:(OIContext *)ctx {
    // First, check for an existing function from a previous 'extern' declaration.
    llvm::Function *function = ctx->module->getFunction(std::string([self.proto.name UTF8String]));
    
    if (!function) {
        function = [self.proto codegenWithContext:ctx];
    }
    
    if (!function) {
        return nil;
    }
    
    if (!function->empty()) {
        NSLog(@"Function cannot be redefined");
        return nil;
    }
    
    llvm::BasicBlock *basicBlock = llvm::BasicBlock::Create(llvm::getGlobalContext(), "entry", function);
    Builder.SetInsertPoint(basicBlock);
    
    ctx->namedValues.clear();
    
    for (auto &arg : function->args()) {
        ctx->namedValues[arg.getName()] = &arg;
    }
    
    llvm::Value *retVal = [self.body codegenWithContext:ctx];
    if (retVal) {
        Builder.CreateRet(retVal);
        llvm::verifyFunction(*function);
        return function;
    }
    
    function->eraseFromParent();
    return nil;
}

@end



