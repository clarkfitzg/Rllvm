library(Rllvm)

f = Function("foo", SEXPType, list(x = SEXPType))
b = Block(f)
ir = IRBuilder(b)
ir$createRet(getParameters(f)$x)
showModule(f)

#debug(Rllvm:::.llvmFFI)
.llvm(f, 1:3)
.llvm(f, as.numeric(1:3))
.llvm(f, letters)

