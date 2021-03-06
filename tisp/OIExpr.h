//
//  OIExpr.h
//  tisp
//
//  Created by Omer Iqbal on 31/3/16.
//  Copyright © 2016 Garena. All rights reserved.
//

#import "OIContext.h"

#import <Foundation/Foundation.h>
#import <llvm/IR/Value.h>


@protocol OIParseable <NSObject>

- (BOOL)isTopLevel;

@end

@interface OIExpr : NSObject <OIParseable>

- (llvm::Value *)codegenWithContext:(OIContext *)ctx;

@end

@interface OINumberExpr : OIExpr

@property (nonatomic, assign, readonly) double val;

+ (instancetype)val:(double)val;

@end

@interface OIVarExpr : OIExpr

@property (nonatomic, copy, readonly) NSString *name;

+ (instancetype)name:(NSString *)name;

@end


@interface OIBinExpr : OIExpr

@property (nonatomic, copy, readonly) NSString *op;
@property (nonatomic, strong, readonly) OIExpr *lhs;
@property (nonatomic, strong, readonly) OIExpr *rhs;

+ (instancetype)op:(NSString *)op lhs:(OIExpr *)lhs rhs:(OIExpr *)rhs;

@end

@interface OICallExpr : OIExpr

@property (nonatomic, copy, readonly) NSString *callee;
@property (nonatomic, copy, readonly) NSArray<OIExpr *> *args;

+ (instancetype)name:(NSString *)name args:(NSArray<OIExpr *> *)args;

@end

@interface OIPrototypeExpr : NSObject <OIParseable>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray<NSString *> *args;

+ (instancetype)name:(NSString *)name args:(NSArray<NSString *> *)args;

- (llvm::Function *)codegenWithContext:(OIContext *)ctx;

@end

@interface OIFunctionExpr : NSObject <OIParseable>

@property (nonatomic, strong, readonly) OIPrototypeExpr *proto;
@property (nonatomic, strong, readonly) OIExpr *body;

+ (instancetype)proto:(OIPrototypeExpr *)proto body:(OIExpr *)body;

- (llvm::Function *)codegenWithContext:(OIContext *)ctx;

@end

@interface OIIfExpr : OIExpr
@property (nonatomic, strong, readonly) OIExpr *cond;
@property (nonatomic, strong, readonly) OIExpr *thenE;
@property (nonatomic, strong, readonly) OIExpr *elseE;

+ (instancetype)cond:(OIExpr *)cond then:(OIExpr *)then elseE:(OIExpr *)elseE;

@end