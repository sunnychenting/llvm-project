; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main -mattr=+mve.fp -verify-machineinstrs -o - %s | FileCheck %s

define arm_aapcs_vfpcc <8 x half> @test_vrndaq_m_f16(<8 x half> %inactive, <8 x half> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndaq_m_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintat.f16 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32 %0)
  %2 = tail call <8 x half> @llvm.arm.mve.vrinta.predicated.v8f16.v8i1(<8 x half> %a, <8 x i1> %1, <8 x half> %inactive)
  ret <8 x half> %2
}

define arm_aapcs_vfpcc <4 x float> @test_vrndaq_m_f32(<4 x float> %inactive, <4 x float> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndaq_m_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintat.f32 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %0)
  %2 = tail call <4 x float> @llvm.arm.mve.vrinta.predicated.v4f32.v4i1(<4 x float> %a, <4 x i1> %1, <4 x float> %inactive)
  ret <4 x float> %2
}

define arm_aapcs_vfpcc <8 x half> @test_vrndmq_m_f16(<8 x half> %inactive, <8 x half> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndmq_m_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintmt.f16 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32 %0)
  %2 = tail call <8 x half> @llvm.arm.mve.vrintm.predicated.v8f16.v8i1(<8 x half> %a, <8 x i1> %1, <8 x half> %inactive)
  ret <8 x half> %2
}

define arm_aapcs_vfpcc <4 x float> @test_vrndmq_m_f32(<4 x float> %inactive, <4 x float> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndmq_m_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintmt.f32 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %0)
  %2 = tail call <4 x float> @llvm.arm.mve.vrintm.predicated.v4f32.v4i1(<4 x float> %a, <4 x i1> %1, <4 x float> %inactive)
  ret <4 x float> %2
}

define arm_aapcs_vfpcc <8 x half> @test_vrndnq_m_f16(<8 x half> %inactive, <8 x half> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndnq_m_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintnt.f16 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32 %0)
  %2 = tail call <8 x half> @llvm.arm.mve.vrintn.predicated.v8f16.v8i1(<8 x half> %a, <8 x i1> %1, <8 x half> %inactive)
  ret <8 x half> %2
}

define arm_aapcs_vfpcc <4 x float> @test_vrndnq_m_f32(<4 x float> %inactive, <4 x float> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndnq_m_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintnt.f32 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %0)
  %2 = tail call <4 x float> @llvm.arm.mve.vrintn.predicated.v4f32.v4i1(<4 x float> %a, <4 x i1> %1, <4 x float> %inactive)
  ret <4 x float> %2
}

define arm_aapcs_vfpcc <8 x half> @test_vrndpq_m_f16(<8 x half> %inactive, <8 x half> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndpq_m_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintpt.f16 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32 %0)
  %2 = tail call <8 x half> @llvm.arm.mve.vrintp.predicated.v8f16.v8i1(<8 x half> %a, <8 x i1> %1, <8 x half> %inactive)
  ret <8 x half> %2
}

define arm_aapcs_vfpcc <4 x float> @test_vrndpq_m_f32(<4 x float> %inactive, <4 x float> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndpq_m_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintpt.f32 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %0)
  %2 = tail call <4 x float> @llvm.arm.mve.vrintp.predicated.v4f32.v4i1(<4 x float> %a, <4 x i1> %1, <4 x float> %inactive)
  ret <4 x float> %2
}

define arm_aapcs_vfpcc <8 x half> @test_vrndq_m_f16(<8 x half> %inactive, <8 x half> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndq_m_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintzt.f16 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32 %0)
  %2 = tail call <8 x half> @llvm.arm.mve.vrintz.predicated.v8f16.v8i1(<8 x half> %a, <8 x i1> %1, <8 x half> %inactive)
  ret <8 x half> %2
}

define arm_aapcs_vfpcc <4 x float> @test_vrndq_m_f32(<4 x float> %inactive, <4 x float> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndq_m_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintzt.f32 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %0)
  %2 = tail call <4 x float> @llvm.arm.mve.vrintz.predicated.v4f32.v4i1(<4 x float> %a, <4 x i1> %1, <4 x float> %inactive)
  ret <4 x float> %2
}

define arm_aapcs_vfpcc <8 x half> @test_vrndxq_m_f16(<8 x half> %inactive, <8 x half> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndxq_m_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintxt.f16 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32 %0)
  %2 = tail call <8 x half> @llvm.arm.mve.vrintx.predicated.v8f16.v8i1(<8 x half> %a, <8 x i1> %1, <8 x half> %inactive)
  ret <8 x half> %2
}

define arm_aapcs_vfpcc <4 x float> @test_vrndxq_m_f32(<4 x float> %inactive, <4 x float> %a, i16 zeroext %p) {
; CHECK-LABEL: test_vrndxq_m_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vrintxt.f32 q0, q1
; CHECK-NEXT:    bx lr
entry:
  %0 = zext i16 %p to i32
  %1 = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %0)
  %2 = tail call <4 x float> @llvm.arm.mve.vrintx.predicated.v4f32.v4i1(<4 x float> %a, <4 x i1> %1, <4 x float> %inactive)
  ret <4 x float> %2
}

declare <8 x i1> @llvm.arm.mve.pred.i2v.v8i1(i32)
declare <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32)
declare <8 x half> @llvm.arm.mve.vrinta.predicated.v8f16.v8i1(<8 x half>, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.arm.mve.vrinta.predicated.v4f32.v4i1(<4 x float>, <4 x i1>, <4 x float>)
declare <8 x half> @llvm.arm.mve.vrintm.predicated.v8f16.v8i1(<8 x half>, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.arm.mve.vrintm.predicated.v4f32.v4i1(<4 x float>, <4 x i1>, <4 x float>)
declare <8 x half> @llvm.arm.mve.vrintn.predicated.v8f16.v8i1(<8 x half>, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.arm.mve.vrintn.predicated.v4f32.v4i1(<4 x float>, <4 x i1>, <4 x float>)
declare <8 x half> @llvm.arm.mve.vrintp.predicated.v8f16.v8i1(<8 x half>, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.arm.mve.vrintp.predicated.v4f32.v4i1(<4 x float>, <4 x i1>, <4 x float>)
declare <8 x half> @llvm.arm.mve.vrintz.predicated.v8f16.v8i1(<8 x half>, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.arm.mve.vrintz.predicated.v4f32.v4i1(<4 x float>, <4 x i1>, <4 x float>)
declare <8 x half> @llvm.arm.mve.vrintx.predicated.v8f16.v8i1(<8 x half>, <8 x i1>, <8 x half>)
declare <4 x float> @llvm.arm.mve.vrintx.predicated.v4f32.v4i1(<4 x float>, <4 x i1>, <4 x float>)
