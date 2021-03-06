; ModuleID = 'globalString.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.0"

@.str = private unnamed_addr constant [17 x i8] c"This is a string\00", align 1
@str1_p = global i8* getelementptr inbounds ([17 x i8]* @.str, i32 0, i32 0), align 8
@str2_a = global [11 x i8] c"So is this\00", align 1
@pi = global double 3.141593e+00, align 8
@i = global i32 97, align 4
@f = global float 3.450000e+01, align 4
@.str1 = private unnamed_addr constant [21 x i8] c"A replacement string\00", align 1
@str3_a_noinit = common global [99 x i8] zeroinitializer, align 16

define i32 @getLen1()  {
entry:
  %0 = load i8** @str1_p, align 8
  %call = call i64 @strlen(i8* %0)
  %conv = trunc i64 %call to i32
  ret i32 %conv
}

declare i64 @strlen(i8*)

define i32 @getLen2()  {
entry:
  %call = call i64 @strlen(i8* getelementptr inbounds ([11 x i8]* @str2_a, i32 0, i32 0))
  %conv = trunc i64 %call to i32
  ret i32 %conv
}

define i8* @getStr2()  {
entry:
  ret i8* getelementptr inbounds ([11 x i8]* @str2_a, i32 0, i32 0)
}

define i8* @getStr1()  {
entry:
  %0 = load i8** @str1_p, align 8
  ret i8* %0
}

define void @setStr1() {
entry:
  %call = call i8* @strdup(i8* getelementptr inbounds ([21 x i8]* @.str1, i32 0, i32 0))
  store i8* %call, i8** @str1_p, align 8
  ret void
}

declare i8* @strdup(i8*) 

attributes { nounwind ssp uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
