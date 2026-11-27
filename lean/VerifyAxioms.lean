module
-- SPDX-License-Identifier: Apache-2.0
-- Copyright (c) 2026 Alexander Stephen Donahue

import PalomarSolution
import WeylMagic.NonVacuity
import WeylMagic.AdversarialTests

/-!
# Strict Kernel Axiom Audit (`VerifyAxioms.lean`)

Prints exact transitive axiom footprints for all 23 Palomar headline targets
(`T1a`–`T5d` + `ALL`), the kernel-closed arbitrary-bent `n = 4` rupture bridge,
all 6 pillar non-vacuity witnesses (including nontrivial `n = 2` Pauli idempotence),
and all 8 adversarial boundary refutations (38 declarations total). Every declaration
must depend ONLY on a subset of `{propext, Classical.choice, Quot.sound}` (zero
`sorryAx`, zero `Lean.ofReduceBool`, zero custom axioms).
-/

#print axioms WeylMagic.Palomar.prove_t1a
#print axioms WeylMagic.Palomar.prove_t1b
#print axioms WeylMagic.Palomar.prove_t1c
#print axioms WeylMagic.Palomar.prove_t1d
#print axioms WeylMagic.Palomar.prove_t2a
#print axioms WeylMagic.Palomar.prove_t2b
#print axioms WeylMagic.Palomar.prove_t2c
#print axioms WeylMagic.Palomar.prove_t2d
#print axioms WeylMagic.Palomar.prove_t2e
#print axioms WeylMagic.Palomar.prove_t3a
#print axioms WeylMagic.Palomar.prove_t3b
#print axioms WeylMagic.Palomar.prove_t3c
#print axioms WeylMagic.Palomar.prove_t3d
#print axioms WeylMagic.Palomar.prove_t3e
#print axioms WeylMagic.Palomar.prove_t4a
#print axioms WeylMagic.Palomar.prove_t4b
#print axioms WeylMagic.Palomar.prove_t4c
#print axioms WeylMagic.Palomar.prove_t4d
#print axioms WeylMagic.Palomar.prove_t5a
#print axioms WeylMagic.Palomar.prove_t5b
#print axioms WeylMagic.Palomar.prove_t5c
#print axioms WeylMagic.Palomar.prove_t5d
#print axioms WeylMagic.Palomar.prove_all_weyl_magic_theorems

#print axioms WeylMagic.n4_z4_bent_hyperplane_rupture_arbitrary_bent

#print axioms WeylMagic.nonvacuity_pillar1_odd_obstruction
#print axioms WeylMagic.nonvacuity_pillar1_n2_mub_spectrum
#print axioms WeylMagic.nonvacuity_pillar2_symplectic_and_bent
#print axioms WeylMagic.nonvacuity_pillar3_dual_witnesses
#print axioms WeylMagic.nonvacuity_pillar4_tower_and_ame
#print axioms WeylMagic.nonvacuity_pillar5_gauss_and_qgt

#print axioms WeylMagic.refute_two_adic_obstruction_at_n1_and_n2
#print axioms WeylMagic.refute_rothaus_at_m1
#print axioms WeylMagic.refute_fermat_axis_locking_for_odd_pow2
#print axioms WeylMagic.refute_w42_super_mub_at_alpha4
#print axioms WeylMagic.refute_w44_super_mub_at_alpha4
#print axioms WeylMagic.refute_two_stab_optimal_at_n5
#print axioms WeylMagic.refute_n4_tower_reaches_mub
#print axioms WeylMagic.refute_reducible_char3_poly
