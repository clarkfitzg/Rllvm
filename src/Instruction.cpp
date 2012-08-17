#include "Rllvm.h"



MAKE_R_eraseFromParent(Instruction)
MAKE_R_getParent(Instruction, BasicBlock)


extern "C"
SEXP
R_Instruction_getOpcode(SEXP r_inst)
{
    llvm::Instruction *inst = GET_REF(r_inst, Instruction);
    SEXP ans;
    PROTECT(ans = ScalarInteger(inst->getOpcode()));
    SET_NAMES(ans, ScalarString(mkChar(inst->getOpcodeName())));
    UNPROTECT(1);
    return(ans);
}



/***************************/
extern "C"
SEXP
R_Instruction_isTerminator(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isTerminator()));
}
extern "C"
SEXP
R_Instruction_isBinaryOp(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isBinaryOp()));
}
extern "C"
SEXP
R_Instruction_isShift(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isShift()));
}
extern "C"
SEXP
R_Instruction_isCast(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isCast()));
}
extern "C"
SEXP
R_Instruction_isLogicalShift(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isLogicalShift()));
}
extern "C"
SEXP
R_Instruction_isArithmeticShift(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isArithmeticShift()));
}
extern "C"
SEXP
R_Instruction_hasMetadata(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->hasMetadata()));
}
extern "C"
SEXP
R_Instruction_hasMetadataOtherThanDebugLoc(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->hasMetadataOtherThanDebugLoc()));
}
extern "C"
SEXP
R_Instruction_isAssociative(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isAssociative()));
}
extern "C"
SEXP
R_Instruction_isCommutative(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->isCommutative()));
}
extern "C"
SEXP
R_Instruction_mayWriteToMemory(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->mayWriteToMemory()));
}
extern "C"
SEXP
R_Instruction_mayReadFromMemory(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->mayReadFromMemory()));
}
extern "C"
SEXP
R_Instruction_mayThrow(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->mayThrow()));
}
extern "C"
SEXP
R_Instruction_mayHaveSideEffects(SEXP r_inst)
{
	llvm::Instruction *inst = GET_REF(r_inst, Instruction);
	if(!inst) return(ScalarLogical(NA_LOGICAL));
	return(ScalarLogical(inst->mayHaveSideEffects()));
}
