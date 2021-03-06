IRBuilder =
function(block = getGlobalContext())
{
    # if no block, use the context
   if(is(block, "LLVMContext"))
      .Call("R_new_IRBuilder_LLVMContext", block)     
   else
     .Call("R_new_IRBuilder", block)
}

setInsertBlock = 
function(builder, block)
{
  .Call("R_IRBuilder_SetInsertPoint", builder, block)
}

setInsertPoint =
function(builder, instruction)
{
  if(is(instruction, "BasicBlock"))
     setInsertBlock(builder, instruction)
  else
     .Call("R_IRBuilder_SetInsertPointInstruction", builder, as(instruction, "Instruction") )
}
         




binOp = 
function(builder, op, x, y, id = character())
{
   fun = deparse(substitute(op))
   if(is.function(op))  {
            # incomplete. The idea is to recognize symbols in R such as + or - and
            # map those to the corresponding enum values. However, it is not clear
            # whether to use the integer or numeric values.
      op = fun
   } else if(is.character(op)) {
       i = match(op, names(BinaryOps))
       if(is.na(i))
          stop(op, " is not a valid Binary Operator name. See BinaryOps")
       op = BinaryOps[i]
   }

   if(! (op %in% BinaryOps) ) {
      if(fun %in% c("Add", "Sub") || fun %in% Opcode)
          msg = paste(" You seem to have used", fun, "which is an Opcode with the same name as a BinaryOp")
      else
          msg = character()
      stop(op, " is not a valid Binary Operator value. See the vector BinaryOps.", msg)
   }
   
   if(isBasicType(x))
     x = makeConstant(builder, x)
   if(isBasicType(y))
     y = makeConstant(builder, y)

   .Call("R_IRBuilder_CreateBinOp", builder, as.integer(op), x, y, as.character(id))
}

createReturn = createRet =
function(builder, value = NULL)
{
   if(missing( value ))
      createReturnVoid(builder)
   else
      .Call("R_IRBuilder_CreateRet", builder, value)
}

createReturnVoid = createRetVoid =
function(builder)
{
  .Call("R_IRBuilder_CreateRetVoid", builder)
}


createCall =
function(builder, fun, ..., .args = list(...), id = character())
{
  .Call("R_IRBuilder_CreateCall", builder, fun, .args, as.character(id))
}    


createBr = createBranch =
function(builder, block, check = TRUE)
{
  if(identical(block, getInsertBlock(builder)))
      warning("setting a branch to the same block. This often results in  an infinite loop!")
  
  .Call("R_IRBuilder_CreateBr", builder, block)
}

createCondBr = createCondBranch =
function(builder, cond, true, false)
{
  .Call("R_IRBuilder_CreateCondBr", builder, cond, true, false)
}


createNeg =
function(builder, val, id = character())
{
  .Call("R_IRBuilder_CreateNeg", builder, val)
}


createFNeg =
function(builder, val, id = character())
{
  .Call("R_IRBuilder_CreateFNeg", builder, val)
}


createNot =
function(builder, val, id = character())
{
  .Call("R_IRBuilder_CreateNot", builder, val)
}


createUIToFP =
function(builder, val, type, id = character())
{
  .Call("R_IRBuilder_CreateUIToFP", builder, val, type)
}


createFPToSI =
function(builder, val, type, id = character())
{
  .Call("R_IRBuilder_CreateFPToSI", builder, val, type)
}

createFPToUI =
function(builder, val, type, id = character())
{
  .Call("R_IRBuilder_CreateFPToUI", builder, val, type)
}

createSIToFP =
function(builder, val, type, id = character())
{
  .Call("R_IRBuilder_CreateSIToFP", builder, val, type)
}

createICmp =
function(builder, op, lhs, rhs, id = character())
{
  .Call("R_IRBuilder_CreateICmp", builder, as(op, "integer"), lhs, rhs)
}

createFCmp =
function(builder, op, lhs, rhs, id = character())
{
  .Call("R_IRBuilder_CreateFCmp", builder, as(op, "integer"), lhs, rhs)
}

isBasicType =
function(val)
{
  typeof(val) %in% c("integer", "logical", "character", "double")
}

createStore =
function(builder, val, ptr, volatile = FALSE)
{
  if(isBasicType(val))  # make a constant.
      val = makeConstant(builder, val)

  .Call("R_IRBuilder_CreateStore", builder, val, ptr, as.logical(volatile))
}

createLoad =
function(builder, val, isVolatile = FALSE, id = character())
{
  .Call("R_IRBuilder_CreateLoad", builder, val, as.logical(isVolatile), as.character(id))
}


createGEP =
function(builder, val, index, id = character())
{
  if (isBasicType(index)) index = as.list(index)
  else if (!is.list(index)) index = list(index)

  index =
    lapply(index, function(idx) {
      if (isBasicType(idx)) makeConstant(builder, idx)
      else idx
    })

  .Call("R_IRBuilder_CreateGEP", builder, val, index, as.character(id))
}

setGeneric("isInBounds", function(x, ...) standardGeneric("isInBounds"))
setMethod("isInBounds", "Value",
           function(x, ...) {
              if(isa(x, "GetElementPtrInst"))
                  .Call("R_GetElementPtrInst_isInBounds", x)
              else
                  stop("isInBounds applicable only for GetElementPtrInst")               
           })

setGeneric("isInBounds<-", function(x, ..., value) standardGeneric("isInBounds<-"))
setMethod("isInBounds<-", "Value",
           function(x, ..., value) {
              if(isa(x, "GetElementPtrInst"))
                 .Call("R_GetElementPtrInst_setIsInBounds", x, as.logical(value))
              else
                  stop("isInBounds applicable only for GetElementPtrInst")
             x
         })


createAlloc = createLocalVariable =
  #XXX doesn't match method in IRBuilder.  Building myself. Be suspicious
function(builder, type, id, beforeTerminator = FALSE)
{
  .Call("R_IRBuilder_createLocalVariable", builder, type, integer(), as.character(id), as.logical(beforeTerminator))
}

createLocalArrayVariable =
  #XXX doesn't match method in IRBuilder.  Building myself. Be suspicious
  # size is a Value.  If a constant, we should create the value.
function(builder, type, id, size = NULL)
{
#   if(size <= 0)
#     stop("Must be positive value for size of array")
   
  .Call("R_IRBuilder_createLocalVariable", builder, type, size, as.character(id))
}

##############
#  syntactic sugar to allow calls such as irbuilder$createGEP(...)
#    bldr$binOp(...)
# rather than having the builder as the first argument.
# This makes it easier to follow along with C++ code examples.
#

setMethod("$", "IRBuilder",
           function(x, name) {
              fun = get(name)
              
              # formals(fun)$builder = x
              function(...)
                 fun(builder = x, ...)
           })

createSExt =
function(builder, val, type, id = character())
  createZExt(builder, val, type, id, FALSE)

createZExt =
function(builder, val, type, id = character(), Z = TRUE)
{
   if(is(type, "numeric"))
      type =  switch(as.character(type),
                     "32" = Int32Type,
                     "64" = Int64Type)
   .Call("R_IRBuilder_CreateSExt", builder, val, type, as.character(id), as.logical(Z))
}



createBitCast =
function(builder, val, type, id = character())
{
   .Call("R_IRBuilder_CreateBitCastInst", builder, val, type, as.character(id))
}

createIntCast =
function(builder, val, type, isSigned = TRUE, id = character())
{
   .Call("R_IRBuilder_CreateIntCastInst", builder, val, type, as.logical(isSigned), as.character(id))
}


createGlobalString =
function(builder, val, id = character())
{
  .Call("R_IRBuilder_CreateGlobalString", builder, as.character(val), as.character(id))
}

createIsNull =
function(builder, val, id = character())
{
  .Call("R_IRBuilder_CreateIsNull", builder, val, as.character(id))
}


createIsNotNull =
function(builder, val, id = character())
{
  .Call("R_IRBuilder_CreateIsNull", builder, val, as.character(id))
}

createUnwind  =
function(builder, id = character())
{
  .Call("R_IRBuilder_CreateUnwind", builder,  as.character(id))
}

createUnreachable  =
function(builder, id = character())
{
  .Call("R_IRBuilder_CreateUnreachable", builder,  as.character(id))
}


createSelect  =
function(builder, cond, true, false, id = character())
{
  .Call("R_IRBuilder_CreateSelect", builder, cond, true, false, as.character(id))
}

createPtrDiff  =
function(builder, a, b, id = character())
{
  .Call("R_IRBuilder_CreatePtrDiff", builder, a, b, as.character(id))
}

createSwitch  =
  #
  # Should create the block first so that you can connect it to other blocks.
  # Method to query the destination block?
  #
function(builder, value, dest = Block(as(builder, "Function")), ..., numCases = max(length(cases), 3L), branchWeights = 0L, id = character())
{
  cases = list(...)
  inst = .Call("R_IRBuilder_CreateSwitch", builder, value, dest, as.integer(numCases), as.character(id))
  if(length(cases))
     addCases(inst, .cases = cases)
  
  inst
}

addCases =
function(sw, ..., .cases = list(...), .values = integer(), .ctx = getGlobalContext())
{
  if(missing(.values)) {
    if(length(names(.cases)) > 0)
       .values = as.integer( names(.cases) )
    else
       .values = seq(along = .cases)
  } else if(is.atomic(.values)) 
       .values = as.integer(.values)

  if(!is.recursive(.values)) 
     .values = lapply(.values, function(i) createIntegerConstant(i, .ctx))
  
  .Call("R_SwitchInst_addCases", sw, .values, .cases)
}



setAs("IRBuilder", "Function",
       function(from) {
          getParent(getInsertBlock(from))
       })


getInsertBlock =
function(builder)
{
   if(!is(builder, "IRBuilder"))
      stop("getInsertBlock needs to be called with an IRBuilder object")
  .Call("R_IRBuilder_GetInsertBlock", builder)
}

setGeneric("createNot",
           function(val, id = character(), block = NULL, builder = NULL)
             standardGeneric("createNot"))

if(FALSE) {
setMethod("createNot", c("Value", block = "missing"),
           function(val, id = character(), block = NULL)
              .Call("R_BinaryOperator_CreateNot", val, as.character(id), VoidType, block))

setMethod("createNot", c("Value", block = "BasicBlock"),
           function(val, id = character(), block = NULL) {
              if(length(id) == 0)
                  id = ""
              .Call("R_BinaryOperator_CreateNot", val, as.character(id), VoidType, block)
            })
}

setMethod("createNot", c("Value", block = "missing", builder = "IRBuilder"),
           function(val, id = character(), block = NULL, builder = NULL)
              .Call("R_IRBuilder_CreateNot", builder, val))

setMethod("createNot", c("Value", block = "BasicBlock", builder = "IRBuilder"),
           function(val, id = character(), block = NULL, builder = NULL) {
              if(length(id) == 0)
                  id = ""
              .Call("R_BinaryOperator_CreateNot", builder, val)
            })


setGeneric("createNeg",
           function(val, id = character(), block = NULL)
             standardGeneric("createNeg"))

setMethod("createNeg", c("Value", block = "missing"),
           function(val, id = character(), block = NULL)
              .Call("R_BinaryOperator_CreateNeg", val, as.character(id), getType(val), NULL))

setMethod("createNeg", c("Value", block = "BasicBlock"),
           function(val, id = character(), block = NULL) {
              if(length(id) == 0)
                  id = ""
                 
              .Call("R_BinaryOperator_CreateNeg", val, as.character(id), getType(val), block)
            })




getFalse =
function(ir)
{
  .Call("R_IRBuilder_getFalse", ir)
}

getTrue =
function(ir)
{
  .Call("R_IRBuilder_getTrue", ir)
}


parseIR =
function(content, context = NULL, asText = is(content, "AsIs") || !file.exists(content))
{
    if(!asText)
      content = path.expand(content)
    else
      content = paste(as.character(content), collapse = "\n")

   if(asText && content == "")
      stop("no content")
   if(!asText && !file.exists(content))
      stop(paste("no such file ", content))

    
   .Call("R_llvm_ParseIRFile", content, as.logical(asText), context)
}

parseIRError =
function(line, col, msg)
{
   e = simpleError(msg)
   e$lineNum = line
   e$colNum = col
   stop( structure(e, class = c("ParseIRError", "LLVMError", class(e))))
}


createExtractElement =
function(builder, vec, idx)
{
   .Call("R_IRBuilder_CreateExtractElement", builder, vec, idx)
}

createInsertElement =
function(builder, vec, elt, idx)
{
   .Call("R_IRBuilder_CreateInsertElement", builder, vec, elt, idx)
}



if(FALSE) {
# Old version < 3.4
CastOps = structure(33:44, .Names = c("Trunc", "ZExt", "SExt", "FPToUI",
                    "FPToSI", "UIToFP", "SIToFP", "FPTrunc", "FPExt", "PtrToInt",
                    "IntToPtr", "BitCast"))
# 3.4.
CastOps = structure(0:14, .Names = c("CastOpsBegin", "Trunc", "ZExt", "SExt", 
"FPToUI", "FPToSI", "UIToFP", "SIToFP", "FPTrunc", "FPExt", "PtrToInt", 
"IntToPtr", "BitCast", "AddrSpaceCast", "CastOpsEnd"))
}

createCast =
function(builder, op, from, to, id = character())
{
   if(is(op, "character"))
     op = CastOps[match(op, names(CastOps))]
      
   if(is(op, "numeric"))
      stopifnot(is.na(op) || op %in% CastOps)
  
  .Call("R_IRBuilder_CreateCast", builder, as.integer(op), from, to, as.character(id))
}


createStructGEP =
function(builder, value, field)
{
  if(!is(value, "Value"))
    stop("need a value")
  
  if(is.character(field))
     field = getStructFieldIndex(field, getType(value))

  field = as.integer(field)
  if(length(field) != 1 || is.na(field))
     stop("not a field index")

  .Call("R_IRBuilder_CreateStructGEP",  builder, value, as.integer(field))
}


getStructFieldIndex =
function(field, type)
{
  stop("cannot get struct field by name")
}


createFPTrunc = 
function(builder, value, type, id = "")
{
  .Call("R_IRBuilder_CreateFPTrunc", as(builder, "IRBuilder"), as(value, "Value"), as(type, "Type"), as.character(id))
}

createTrunc = 
function(builder, value, type, id = "")
{
  .Call("R_IRBuilder_CreateTrunc", as(builder, "IRBuilder"), as(value, "Value"), as(type, "Type"), as.character(id))
}



createPhi = createPHI =
function(build, type, numReservedValues, id = character())
{
  .Call("R_IRBuilder_CreatePHI", as(builder, "IRBuilder"), as(type, "Type"), as.integer(numReservedValues), as.character(id))
}
