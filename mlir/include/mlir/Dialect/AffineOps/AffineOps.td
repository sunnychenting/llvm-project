//===- AffineOps.td - Affine operation definitions ---------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Defines MLIR affine operations.
//
//===----------------------------------------------------------------------===//

#ifndef AFFINE_OPS
#define AFFINE_OPS

include "mlir/Dialect/AffineOps/AffineOpsBase.td"
include "mlir/IR/OpBase.td"
include "mlir/Transforms/LoopLikeInterface.td"

def Affine_Dialect : Dialect {
  let name = "affine";
  let cppNamespace = "";
}

// Base class for Affine dialect ops.
class Affine_Op<string mnemonic, list<OpTrait> traits = []> :
    Op<Affine_Dialect, mnemonic, traits> {
  // For every affine op, there needs to be a:
  //   * void print(OpAsmPrinter &p, ${C++ class of Op} op)
  //   * LogicalResult verify(${C++ class of Op} op)
  //   * ParseResult parse${C++ class of Op}(OpAsmParser &parser,
  //                                         OperationState &result)
  // functions.
  let printer = [{ return ::print(p, *this); }];
  let verifier = [{ return ::verify(*this); }];
  let parser = [{ return ::parse$cppClass(parser, result); }];
}

// Require regions to have affine terminator.
def ImplicitAffineTerminator
    : SingleBlockImplicitTerminator<"AffineTerminatorOp">;

def AffineForOp : Affine_Op<"for",
    [ImplicitAffineTerminator,
     DeclareOpInterfaceMethods<LoopLikeOpInterface>]> {
  let summary = "for operation";
  let description = [{
    The "affine.for" operation represents an affine loop nest, defining an SSA
    value for its induction variable. It has one region capturing the loop body.
    The induction variable is represented as a argument of this region. This SSA
    value always has type index, which is the size of the machine word. The
    stride, represented by step, is a positive constant integer which defaults
    to "1" if not present. The lower and upper bounds specify a half-open range:
    the range includes the lower bound but does not include the upper bound.

    The body region must contain exactly one block that terminates with
    "affine.terminator".  Calling AffineForOp::build will create such region
    and insert the terminator, so will the parsing even in cases if it is absent
    from the custom format.

    The lower and upper bounds of a for operation are represented as an
    application of an affine mapping to a list of SSA values passed to the map.
    The same restrictions hold for these SSA values as for all bindings of SSA
    values to dimensions and symbols. The affine mappings for the bounds may
    return multiple results, in which case the max/min keywords are required
    (for the lower/upper bound respectively), and the bound is the
    maximum/minimum of the returned values.

    Example:

      affine.for %i = 1 to 10 {
        ...
      }

  }];
  let arguments = (ins Variadic<AnyType>);
  let regions = (region SizedRegion<1>:$region);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<"Builder *builder, OperationState &result, "
              "int64_t lowerBound, int64_t upperBound, int64_t step = 1">,
    OpBuilder<"Builder *builder, OperationState &result, "
              "ValueRange lbOperands, AffineMap lbMap, "
              "ValueRange ubOperands, AffineMap ubMap, "
              "int64_t step = 1">
  ];

  let extraClassDeclaration = [{
    static StringRef getStepAttrName() { return "step"; }
    static StringRef getLowerBoundAttrName() { return "lower_bound"; }
    static StringRef getUpperBoundAttrName() { return "upper_bound"; }

    Block *getBody() { return &region().front(); }
    Value getInductionVar() { return getBody()->getArgument(0); }
    OpBuilder getBodyBuilder() {
      return OpBuilder(getBody(), std::prev(getBody()->end()));
    }

    // TODO: provide iterators for the lower and upper bound operands
    // if the current access via getLowerBound(), getUpperBound() is too slow.

    /// Returns operands for the lower bound map.
    operand_range getLowerBoundOperands();

    /// Returns operands for the upper bound map.
    operand_range getUpperBoundOperands();

    /// Returns information about the lower bound as a single object.
    AffineBound getLowerBound();

    /// Returns information about the upper bound as a single object.
    AffineBound getUpperBound();

    /// Returns loop step.
    int64_t getStep() {
      return getAttr(getStepAttrName()).cast<IntegerAttr>().getInt();
    }

    /// Returns affine map for the lower bound.
    AffineMap getLowerBoundMap() { return getLowerBoundMapAttr().getValue(); }
    AffineMapAttr getLowerBoundMapAttr() {
      return getAttr(getLowerBoundAttrName()).cast<AffineMapAttr>();
    }
    /// Returns affine map for the upper bound. The upper bound is exclusive.
    AffineMap getUpperBoundMap() { return getUpperBoundMapAttr().getValue(); }
    AffineMapAttr getUpperBoundMapAttr() {
      return getAttr(getUpperBoundAttrName()).cast<AffineMapAttr>();
    }

    /// Set lower bound. The new bound must have the same number of operands as
    /// the current bound map. Otherwise, 'replaceForLowerBound' should be used.
    void setLowerBound(ValueRange operands, AffineMap map);
    /// Set upper bound. The new bound must not have more operands than the
    /// current bound map. Otherwise, 'replaceForUpperBound' should be used.
    void setUpperBound(ValueRange operands, AffineMap map);

    /// Set the lower bound map without changing operands.
    void setLowerBoundMap(AffineMap map);

    /// Set the upper bound map without changing operands.
    void setUpperBoundMap(AffineMap map);

    /// Set loop step.
    void setStep(int64_t step) {
      assert(step > 0 && "step has to be a positive integer constant");
      auto *context = getLowerBoundMap().getContext();
      setAttr(Identifier::get(getStepAttrName(), context),
              IntegerAttr::get(IndexType::get(context), step));
    }

    /// Returns true if the lower bound is constant.
    bool hasConstantLowerBound();
    /// Returns true if the upper bound is constant.
    bool hasConstantUpperBound();
    /// Returns true if both bounds are constant.
    bool hasConstantBounds() {
      return hasConstantLowerBound() && hasConstantUpperBound();
    }
    /// Returns the value of the constant lower bound.
    /// Fails assertion if the bound is non-constant.
    int64_t getConstantLowerBound();
    /// Returns the value of the constant upper bound. The upper bound is
    /// exclusive. Fails assertion if the bound is non-constant.
    int64_t getConstantUpperBound();
    /// Sets the lower bound to the given constant value.
    void setConstantLowerBound(int64_t value);
    /// Sets the upper bound to the given constant value.
    void setConstantUpperBound(int64_t value);

    /// Returns true if both the lower and upper bound have the same operand
    /// lists (same operands in the same order).
    bool matchingBoundOperandList();
  }];

  let hasCanonicalizer = 1;
  let hasFolder = 1;
}

def AffineIfOp : Affine_Op<"if", [ImplicitAffineTerminator]> {
  let summary = "if-then-else operation";
  let description = [{
    The "if" operation represents an if-then-else construct for conditionally
    executing two regions of code. The operands to an if operation are an
    IntegerSet condition and a set of symbol/dimension operands to the
    condition set. The operation produces no results. For example:

       affine.if #set(%i)  {
         ...
       } else {
         ...
       }

    The 'else' blocks to the if operation are optional, and may be omitted. For
    example:

       affine.if #set(%i)  {
         ...
       }
  }];
  let arguments = (ins Variadic<AnyType>);
  let regions = (region SizedRegion<1>:$thenRegion, AnyRegion:$elseRegion);

  let skipDefaultBuilders = 1;

  let builders = [
    OpBuilder<"Builder *builder, OperationState &result, "
              "IntegerSet set, ValueRange args, bool withElseRegion">
  ];

  let extraClassDeclaration = [{
    static StringRef getConditionAttrName() { return "condition"; }

    IntegerSet getIntegerSet();
    void setIntegerSet(IntegerSet newSet);

    /// Sets the integer set with its operands. The size of 'operands' must not
    /// exceed the current number of operands for this instance, as the operands
    /// list of AffineIf is not resizable.
    void setConditional(IntegerSet set, ValueRange operands);

    OpBuilder getThenBodyBuilder() {
      assert(!thenRegion().empty() && "Unexpected empty 'then' region.");
      Block &body = thenRegion().front();
      return OpBuilder(&body, std::prev(body.end()));
    }
    OpBuilder getElseBodyBuilder() {
      assert(!elseRegion().empty() && "Unexpected empty 'else' region.");
      Block &body = elseRegion().front();
      return OpBuilder(&body, std::prev(body.end()));
    }
  }];

  let hasFolder = 1;
}

class AffineMinMaxOpBase<string mnemonic, list<OpTrait> traits = []> :
    Op<Affine_Dialect, mnemonic, traits> {
  let arguments = (ins AffineMapAttr:$map, Variadic<Index>:$operands);
  let results = (outs Index);

  let builders = [
    OpBuilder<"Builder *builder, OperationState &result, AffineMap affineMap, "
              "ValueRange mapOperands",
    [{
      build(builder, result, builder->getIndexType(), affineMap, mapOperands);
    }]>
  ];

  let extraClassDeclaration = [{
    static StringRef getMapAttrName() { return "map"; }
    AffineMap getAffineMap() { return map(); }
    ValueRange getMapOperands() { return operands(); }
  }];
  let verifier = [{ return ::verifyAffineMinMaxOp(*this); }];
  let printer = [{ return ::printAffineMinMaxOp(p, *this); }];
  let parser = [{ return ::parseAffineMinMaxOp<$cppClass>(parser, result); }];
  let hasFolder = 1;
  let hasCanonicalizer = 1;
}

def AffineMinOp : AffineMinMaxOpBase<"min", [NoSideEffect]> {
  let summary = "min operation";
  let description = [{
    The "min" operation computes the minimum value result from a multi-result
    affine map.

    Example:

       %0 = affine.min (d0) -> (1000, d0 + 512) (%i0) : index
  }];
}

def AffineMaxOp : AffineMinMaxOpBase<"max", [NoSideEffect]> {
  let summary = "max operation";
  let description = [{
    The "max" operation computes the maximum value result from a multi-result
    affine map.

    Example:

       %0 = affine.max (d0) -> (1000, d0 + 512) (%i0) : index
  }];
}

def AffineParallelOp : Affine_Op<"parallel", [ImplicitAffineTerminator]> {
  let summary = "multi-index parallel band operation";
  let description = [{
    The "affine.parallel" operation represents a hyper-rectangular affine
    parallel band, defining multiple SSA values for its induction variables. It
    has one region capturing the parallel band body. The induction variables are
    represented as arguments of this region. These SSA values always have type
    index, which is the size of the machine word. The strides, represented by
    steps, are positive constant integers which defaults to "1" if not present.
    The lower and upper bounds specify a half-open range: the range includes the
    lower bound but does not include the upper bound. The body region must
    contain exactly one block that terminates with "affine.terminator".

    The lower and upper bounds of a parallel operation are represented as an
    application of an affine mapping to a list of SSA values passed to the map.
    The same restrictions hold for these SSA values as for all bindings of SSA
    values to dimensions and symbols.

    Note: Calling AffineParallelOp::build will create the required region and
    block, and insert the required terminator. Parsing will also create the
    required region, block, and terminator, even when they are missing from the
    textual representation.

    Example:

    ```mlir
      affine.parallel (%i, %j) = (0, 0) to (10, 10) step (1, 1) {
        ...
      }
    ```
  }];

  let arguments = (ins
     AffineMapAttr:$lowerBoundsMap,
     AffineMapAttr:$upperBoundsMap,
     I64ArrayAttr:$steps,
     Variadic<Index>:$mapOperands);
  let regions = (region SizedRegion<1>:$region);

  let builders = [
    OpBuilder<"Builder* builder, OperationState& result,"
              "ArrayRef<int64_t> ranges">,
    OpBuilder<"Builder* builder, OperationState& result, AffineMap lbMap,"
              "ValueRange lbArgs, AffineMap ubMap, ValueRange ubArgs">,
    OpBuilder<"Builder* builder, OperationState& result, AffineMap lbMap,"
              "ValueRange lbArgs, AffineMap ubMap, ValueRange ubArgs,"
              "ArrayRef<int64_t> steps">
  ];

  let extraClassDeclaration = [{
    /// Get the number of dimensions.
    unsigned getNumDims();

    operand_range getLowerBoundsOperands();
    operand_range getUpperBoundsOperands();

    AffineValueMap getLowerBoundsValueMap();
    AffineValueMap getUpperBoundsValueMap();
    AffineValueMap getRangesValueMap();

    /// Get ranges as constants, may fail in dynamic case.
    Optional<SmallVector<int64_t, 8>> getConstantRanges();
    
    Block *getBody();
    OpBuilder getBodyBuilder();
    void setSteps(ArrayRef<int64_t> newSteps);

    static StringRef getLowerBoundsMapAttrName() { return "lowerBoundsMap"; }
    static StringRef getUpperBoundsMapAttrName() { return "upperBoundsMap"; }
    static StringRef getStepsAttrName() { return "steps"; }
  }];
}

def AffinePrefetchOp : Affine_Op<"prefetch"> {
  let summary = "affine prefetch operation";
  let description = [{
    The "affine.prefetch" op prefetches data from a memref location described
    with an affine subscript similar to affine.load, and has three attributes:
    a read/write specifier, a locality hint, and a cache type specifier as shown
    below:

      affine.prefetch %0[%i, %j + 5], read, locality<3>, data
                          : memref<400x400xi32>

    The read/write specifier is either 'read' or 'write', the locality hint
    specifier ranges from locality<0> (no locality) to locality<3> (extremely
    local keep in cache). The cache type specifier is either 'data' or 'instr'
    and specifies whether the prefetch is performed on data cache or on
    instruction cache.
  }];

  let arguments = (ins AnyMemRef:$memref, Variadic<Index>:$indices,
                   BoolAttr:$isWrite,
                   Confined<I32Attr, [IntMinValue<0>,
                     IntMaxValue<3>]>:$localityHint,
                   BoolAttr:$isDataCache);

  let builders = [OpBuilder<
    "Builder *builder, OperationState &result, Value memref,"
    "AffineMap map, ArrayRef<Value> mapOperands, bool isWrite,"
    "unsigned localityHint, bool isDataCache",
    [{
      assert(map.getNumInputs() == mapOperands.size()
             && "inconsistent index info");
      auto localityHintAttr = builder->getI32IntegerAttr(localityHint);
      auto isWriteAttr = builder->getBoolAttr(isWrite);
      auto isDataCacheAttr = builder->getBoolAttr(isDataCache);
      result.addOperands(memref);
      result.addAttribute(getMapAttrName(), AffineMapAttr::get(map));
      result.addOperands(mapOperands);
      result.addAttribute(getLocalityHintAttrName(), localityHintAttr);
      result.addAttribute(getIsWriteAttrName(), isWriteAttr);
      result.addAttribute(getIsDataCacheAttrName(), isDataCacheAttr);
    }]>];

  let extraClassDeclaration = [{
    MemRefType getMemRefType() {
      return memref().getType().cast<MemRefType>();
    }

    /// Returns the affine map used to index the memref for this operation.
    AffineMap getAffineMap() { return getAffineMapAttr().getValue(); }
    AffineMapAttr getAffineMapAttr() {
      return getAttr(getMapAttrName()).cast<AffineMapAttr>();
    }

    /// Returns the AffineMapAttr associated with 'memref'.
    NamedAttribute getAffineMapAttrForMemRef(Value mref) {
      assert(mref == memref());
      return {Identifier::get(getMapAttrName(), getContext()),
        getAffineMapAttr()};
    }

    /// Get affine map operands.
    operand_range getMapOperands() {
      return {operand_begin() + 1, operand_end()};
    }

    static StringRef getMapAttrName() { return "map"; }
    static StringRef getLocalityHintAttrName() { return "localityHint"; }
    static StringRef getIsWriteAttrName() { return "isWrite"; }
    static StringRef getIsDataCacheAttrName() { return "isDataCache"; }
  }];

  let hasCanonicalizer = 1;
  let hasFolder = 1;
}

def AffineTerminatorOp :
    Affine_Op<"terminator", [Terminator]> {
  let summary = "affine terminator operation";
  let description = [{
    Affine terminator is a special terminator operation for blocks inside affine
    loops and branches. It unconditionally transmits the control flow to the
    successor of the operation enclosing the region.

    This operation does _not_ have a custom syntax. However, affine control
    operations omit the terminator in their custom syntax for brevity.
  }];

  // No custom parsing/printing form.
  let parser = ?;
  let printer = ?;

  // Fully specified by traits.
  let verifier = ?;
}

#endif // AFFINE_OPS
