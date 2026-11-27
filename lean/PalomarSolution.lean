module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

public import Challenge
public import Solution

/-!
# Palomar Verified Solution (`PalomarSolution.lean`)

Discharges every theorem obligation declared in `PalomarChallenge.lean` with identical
namespace, theorem names, and definitional types for 6-kernel comparator verification.
-/

namespace WeylMagic.Palomar

@[expose] public section

theorem prove_t1a : WeylMagic.Spec.stmt_t1a := WeylMagic.Solution.prove_t1a
theorem prove_t1b : WeylMagic.Spec.stmt_t1b := WeylMagic.Solution.prove_t1b
theorem prove_t1c : WeylMagic.Spec.stmt_t1c := WeylMagic.Solution.prove_t1c
theorem prove_t1d : WeylMagic.Spec.stmt_t1d := WeylMagic.Solution.prove_t1d
theorem prove_t2a : WeylMagic.Spec.stmt_t2a := WeylMagic.Solution.prove_t2a
theorem prove_t2b : WeylMagic.Spec.stmt_t2b := WeylMagic.Solution.prove_t2b
theorem prove_t2c : WeylMagic.Spec.stmt_t2c := WeylMagic.Solution.prove_t2c
theorem prove_t2d : WeylMagic.Spec.stmt_t2d := WeylMagic.Solution.prove_t2d
theorem prove_t2e : WeylMagic.Spec.stmt_t2e := WeylMagic.Solution.prove_t2e
theorem prove_t3a : WeylMagic.Spec.stmt_t3a := WeylMagic.Solution.prove_t3a
theorem prove_t3b : WeylMagic.Spec.stmt_t3b := WeylMagic.Solution.prove_t3b
theorem prove_t3c : WeylMagic.Spec.stmt_t3c := WeylMagic.Solution.prove_t3c
theorem prove_t3d : WeylMagic.Spec.stmt_t3d := WeylMagic.Solution.prove_t3d
theorem prove_t3e : WeylMagic.Spec.stmt_t3e := WeylMagic.Solution.prove_t3e
theorem prove_t4a : WeylMagic.Spec.stmt_t4a := WeylMagic.Solution.prove_t4a
theorem prove_t4b : WeylMagic.Spec.stmt_t4b := WeylMagic.Solution.prove_t4b
theorem prove_t4c : WeylMagic.Spec.stmt_t4c := WeylMagic.Solution.prove_t4c
theorem prove_t4d : WeylMagic.Spec.stmt_t4d := WeylMagic.Solution.prove_t4d
theorem prove_t5a : WeylMagic.Spec.stmt_t5a := WeylMagic.Solution.prove_t5a
theorem prove_t5b : WeylMagic.Spec.stmt_t5b := WeylMagic.Solution.prove_t5b
theorem prove_t5c : WeylMagic.Spec.stmt_t5c := WeylMagic.Solution.prove_t5c
theorem prove_t5d : WeylMagic.Spec.stmt_t5d := WeylMagic.Solution.prove_t5d
theorem prove_all_weyl_magic_theorems : WeylMagic.Spec.stmt_all_weyl_magic_theorems :=
  WeylMagic.Solution.prove_all_weyl_magic_theorems

end

end WeylMagic.Palomar
