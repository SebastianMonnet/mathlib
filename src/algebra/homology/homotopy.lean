/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import algebra.homology.additive

/-!
# Chain homotopies

We define chain homotopies, and prove that homotopic chain maps induce the same map on homology.
-/

universes v u

open_locale classical
noncomputable theory

open category_theory category_theory.limits homological_complex

variables {ι : Type*}
variables {V : Type u} [category.{v} V] [preadditive V]

variables {c : complex_shape ι} {C D E : homological_complex V c}
variables (f g : C ⟶ D) (h k : D ⟶ E) (i : ι)

section

def d_next (f : Π i j, C.X i ⟶ D.X j) (i : ι) : C.X i ⟶ D.X i :=
match c.next i with
| none := 0
| some ⟨i',w⟩ := C.d _ _ ≫ f i' i
end

lemma d_next_eq (f : Π i j, C.X i ⟶ D.X j) {i i' : ι} (w : c.rel i i') :
  d_next f i = C.d _ _ ≫ f i' i :=
begin
  dsimp [d_next],
  rw c.next_eq_some w,
  refl,
end

@[simp] lemma d_next_zero (i : ι) : d_next (λ i j, (0 : C.X i ⟶ D.X j)) i = 0 :=
begin
  dsimp [d_next],
  rcases c.next i with ⟨⟩|⟨⟨i', w⟩⟩;
  { dsimp [d_next], simp },
end

@[simp] lemma d_next_add (f g : Π i j, C.X i ⟶ D.X j) (i : ι) :
  d_next (λ i j, f i j + g i j) i = d_next f i + d_next g i :=
begin
  dsimp [d_next],
  rcases c.next i with _|⟨i',w⟩,
  exact (zero_add _).symm,
  exact preadditive.comp_add _ _ _ _ _ _,
end

@[simp] lemma d_next_neg (f : Π i j, C.X i ⟶ D.X j) (i : ι) :
  d_next (λ i j, -(f i j)) i = - d_next f i :=
begin
  dsimp [d_next],
  rcases c.next i with _|⟨i',w⟩,
  exact neg_zero.symm,
  exact preadditive.comp_neg _ _,
end

@[simp] lemma d_next_comp_left (f : C ⟶ D) (g : Π i j, D.X i ⟶ E.X j) (i : ι) :
  d_next (λ i j, f.f i ≫ g i j) i = f.f i ≫ d_next g i :=
begin
  dsimp [d_next],
  rcases c.next i with _|⟨i',w⟩,
  { exact comp_zero.symm, },
  { dsimp [d_next],
    simp, },
end

@[simp] lemma d_next_comp_right (f : Π i j, C.X i ⟶ D.X j) (g : D ⟶ E) (i : ι) :
  d_next (λ i j, f i j ≫ g.f j) i = d_next f i ≫ g.f i :=
begin
  dsimp [d_next],
  rcases c.next i with _|⟨i',w⟩,
  { exact zero_comp.symm, },
  { dsimp [d_next],
    simp, },
end

def prev_d (f : Π i j, C.X i ⟶ D.X j) (j : ι) : C.X j ⟶ D.X j :=
match c.prev j with
| none := 0
| some ⟨j',w⟩ := f j j' ≫ D.d _ _
end

lemma prev_d_eq (f : Π i j, C.X i ⟶ D.X j) {j j' : ι} (w : c.rel j' j) :
  prev_d f j = f j j' ≫ D.d _ _ :=
begin
  dsimp [prev_d],
  rw c.prev_eq_some w,
  refl,
end

@[simp] lemma prev_d_zero (j : ι) : prev_d (λ i j, (0 : C.X i ⟶ D.X j)) j = 0 :=
begin
  dsimp [prev_d],
  rcases c.prev j with ⟨⟩|⟨⟨j', w⟩⟩;
  { dsimp [prev_d], simp, },
end

@[simp] lemma prev_d_add (f g : Π i j, C.X i ⟶ D.X j) (j : ι) :
  prev_d (λ i j, f i j + g i j) j = prev_d f j + prev_d g j :=
begin
  dsimp [prev_d],
  rcases c.prev j with _|⟨j',w⟩,
  exact (zero_add _).symm,
  exact preadditive.add_comp _ _ _ _ _ _,
end

@[simp] lemma prev_d_neg (f : Π i j, C.X i ⟶ D.X j) (j : ι) :
  prev_d (λ i j, -(f i j)) j = - prev_d f j :=
begin
  dsimp [prev_d],
  rcases c.prev j with _|⟨j',w⟩,
  exact neg_zero.symm,
  exact preadditive.neg_comp _ _,
end

@[simp] lemma prev_d_comp_left (f : C ⟶ D) (g : Π i j, D.X i ⟶ E.X j) (j : ι) :
  prev_d (λ i j, f.f i ≫ g i j) j = f.f j ≫ prev_d g j :=
begin
  dsimp [prev_d],
  rcases c.prev j with _|⟨j',w⟩,
  { exact comp_zero.symm, },
  { dsimp [prev_d, hom.prev],
    simp, },
end

@[simp] lemma to_prev'_comp_right (f : Π i j, C.X i ⟶ D.X j) (g : D ⟶ E) (j : ι) :
  prev_d (λ i j, f i j ≫ g.f j) j = prev_d f j ≫ g.f j :=
begin
  dsimp [prev_d],
  rcases c.prev j with _|⟨j',w⟩,
  { exact zero_comp.symm, },
  { dsimp [prev_d],
    simp, },
end

/--
A homotopy `h` between chain maps `f` and `g` consists of components `h i j : C.X i ⟶ D.X j`
which are zero unless `c.rel j i`, satisfying the homotopy condition.
-/
@[ext, nolint has_inhabited_instance]
structure homotopy (f g : C ⟶ D) :=
(hom : Π i j, C.X i ⟶ D.X j)
(zero' : ∀ i j, ¬ c.rel j i → hom i j = 0 . obviously)
(comm' : ∀ i, f.f i = d_next hom _ + prev_d hom _ + g.f i . obviously')

variables {f g}
namespace homotopy

restate_axiom homotopy.zero'
restate_axiom homotopy.comm'

/--
`f` is homotopic to `g` iff `f - g` is homotopic to `0`.
-/
def equiv_sub_zero : homotopy f g ≃ homotopy (f - g) 0 :=
{ to_fun := λ h,
  { hom := λ i j, h.hom i j,
    zero' := λ i j w, h.zero _ _ w,
    comm' := λ i, by simp [h.comm] },
  inv_fun := λ h,
  { hom := λ i j, h.hom i j,
    zero' := λ i j w, h.zero _ _ w,
    comm' := λ i, by simpa [sub_eq_iff_eq_add] using h.comm i },
  left_inv := by tidy,
  right_inv := by tidy, }

/-- Every chain map is homotopic to itself. -/
@[refl]
def refl (f : C ⟶ D) : homotopy f f :=
{ hom := λ i j, 0,
  zero' := λ i j w, rfl,
  comm' := λ i, by simp }

/-- `f` is homotopic to `g` iff `g` is homotopic to `f`. -/
@[symm]
def symm {f g : C ⟶ D} (h : homotopy f g) : homotopy g f :=
{ hom := λ i j, -h.hom i j,
  zero' := λ i j w, by rw [h.zero i j w, neg_zero],
  comm' := λ i, begin
    simp only [prev_d_neg, d_next_neg, h.comm],
    abel,
  end, }

/-- homotopy is a transitive relation. -/
@[trans]
def trans {e f g : C ⟶ D} (h : homotopy e f) (k : homotopy f g) : homotopy e g :=
{ hom := λ i j, h.hom i j + k.hom i j,
  zero' := λ i j w, by rw [h.zero i j w, k.zero i j w, zero_add],
  comm' := λ i, begin
    simp only [prev_d_add, d_next_add, h.comm, k.comm],
    abel,
  end, }

/-- homotopy is closed under composition (on the right) -/
def comp_right {e f : C ⟶ D} (h : homotopy e f) (g : D ⟶ E) : homotopy (e ≫ g) (f ≫ g) :=
{ hom := λ i j, h.hom i j ≫ g.f j,
  zero' := λ i j w, by rw [h.zero i j w, zero_comp],
  comm' := λ i, by simp [h.comm i], }

/-- homotopy is closed under composition (on the left) -/
def comp_left {f g : D ⟶ E} (h : homotopy f g) (e : C ⟶ D) : homotopy (e ≫ f) (e ≫ g) :=
{ hom := λ i j, e.f i ≫ h.hom i j,
  zero' := λ i j w, by rw [h.zero i j w, comp_zero],
  comm' := λ i, by simp [h.comm i], }

/-- a variant of `homotopy.comp_right` useful for dealing with homotopy equivalences. -/
def comp_right_id {f : C ⟶ C} (h : homotopy f (𝟙 C)) (g : C ⟶ D) : homotopy (f ≫ g) g :=
by { convert h.comp_right g, simp, }

/-- a variant of `homotopy.comp_left` useful for dealing with homotopy equivalences. -/
def comp_left_id {f : D ⟶ D} (h : homotopy f (𝟙 D)) (g : C ⟶ D) : homotopy (g ≫ f) g :=
by { convert h.comp_left g, simp, }

/-!
`homotopy.mk_inductive` allows us to build a homotopy inductively,
so that as we construct each component, we have available the previous two components,
and the fact that they satisfy the homotopy condition.

To simplify the situation, we only construct homotopies of the form `homotopy e 0`.
`homotopy.equiv_sub_zero` can provide the general case.

Notice however, that this construction does not have particularly good definitional properties:
we have to insert `eq_to_hom` in several places.
Hopefully this is okay in most applications, where we only need to have the existence of some
homotopy.
-/
section mk_inductive

variables {P Q : chain_complex V ℕ}

@[simp] lemma prev_d_chain_complex (f : Π i j, P.X i ⟶ Q.X j) (j : ℕ) :
  prev_d f j = f j (j+1) ≫ Q.d _ _ :=
begin
  dsimp [prev_d],
  simp only [chain_complex.prev],
  refl,
end

@[simp] lemma d_next_succ_chain_complex (f : Π i j, P.X i ⟶ Q.X j) (i : ℕ) :
  d_next f (i+1) = P.d _ _ ≫ f i (i+1) :=
begin
  dsimp [d_next],
  simp only [chain_complex.next_nat_succ],
  refl,
end

@[simp] lemma d_next_zero_chain_complex (f : Π i j, P.X i ⟶ Q.X j) :
  d_next f 0 = 0 :=
begin
  dsimp [d_next],
  simp only [chain_complex.next_nat_zero],
  refl,
end

variables (e : P ⟶ Q)
  (zero : P.X 0 ⟶ Q.X 1)
  (comm_zero : e.f 0 = zero ≫ Q.d 1 0)
  (one : P.X 1 ⟶ Q.X 2)
  (comm_one : e.f 1 = P.d 1 0 ≫ zero + one ≫ Q.d 2 1)
  (succ : ∀ (n : ℕ)
    (p : Σ' (f : P.X n ⟶ Q.X (n+1)) (f' : P.X (n+1) ⟶ Q.X (n+2)),
      e.f (n+1) = P.d (n+1) n ≫ f + f' ≫ Q.d (n+2) (n+1)),
    Σ' f'' : P.X (n+2) ⟶ Q.X (n+3), e.f (n+2) = P.d (n+2) (n+1) ≫ p.2.1 + f'' ≫ Q.d (n+3) (n+2))

include comm_one comm_zero

/--
An auxiliary construction for `mk_inductive`.

Here we build by induction a family of diagrams,
but don't require at the type level that these successive diagrams actually agree.
They do in fact agree, and we then capture that at the type level (i.e. by constructing a homotopy)
in `mk_inductive`.

At this stage, we don't check the homotopy condition in degree 0,
because it "falls off the end", and is easier to treat using `X_next` and `X_prev`,
which we do in `mk_inductive_aux₂`.
-/
@[simp, nolint unused_arguments]
def mk_inductive_aux₁ :
  Π n, Σ' (f : P.X n ⟶ Q.X (n+1)) (f' : P.X (n+1) ⟶ Q.X (n+2)),
    e.f (n+1) = P.d (n+1) n ≫ f + f' ≫ Q.d (n+2) (n+1)
| 0 := ⟨zero, one, comm_one⟩
| 1 := ⟨one, (succ 0 ⟨zero, one, comm_one⟩).1, (succ 0 ⟨zero, one, comm_one⟩).2⟩
| (n+2) :=
  ⟨(mk_inductive_aux₁ (n+1)).2.1,
    (succ (n+1) (mk_inductive_aux₁ (n+1))).1,
    (succ (n+1) (mk_inductive_aux₁ (n+1))).2⟩

section

variable [has_zero_object V]

/--
An auxiliary construction for `mk_inductive`.
-/
@[simp]
def mk_inductive_aux₂ :
  Π n, Σ' (f : P.X_next n ⟶ Q.X n) (f' : P.X n ⟶ Q.X_prev n), e.f n = P.d_from n ≫ f + f' ≫ Q.d_to n
| 0 := ⟨0, zero ≫ (Q.X_prev_iso rfl).inv, by simpa using comm_zero⟩
| (n+1) := let I := mk_inductive_aux₁ e zero comm_zero one comm_one succ n in
  ⟨(P.X_next_iso rfl).hom ≫ I.1, I.2.1 ≫ (Q.X_prev_iso rfl).inv, by simpa using I.2.2⟩

lemma mk_inductive_aux₃ (i : ℕ) :
  (mk_inductive_aux₂ e zero comm_zero one comm_one succ i).2.1 ≫ (Q.X_prev_iso rfl).hom
    = (P.X_next_iso rfl).inv ≫ (mk_inductive_aux₂ e zero comm_zero one comm_one succ (i+1)).1 :=
by rcases i with (_|_|i); { dsimp, simp, }

/--
A constructor for a `homotopy e 0`, for `e` a chain map between `ℕ`-indexed chain complexes,
working by induction.

You need to provide the components of the homotopy in degrees 0 and 1,
show that these satisfy the homotopy condition,
and then give a construction of each component,
and the fact that it satisfies the homotopy condition,
using as an inductive hypothesis the data and homotopy condition for the previous two components.
-/
def mk_inductive : homotopy e 0 :=
{ hom := λ i j, if h : i + 1 = j then
    (mk_inductive_aux₂ e zero comm_zero one comm_one succ i).2.1 ≫ (Q.X_prev_iso h).hom
  else
    0,
  zero' := λ i j w, by rwa dif_neg,
  comm' := λ i, begin
    dsimp, simp only [add_zero],
    convert (mk_inductive_aux₂ e zero comm_zero one comm_one succ i).2.2,
    { rcases i with (_|_|_|i),
      { dsimp,
        simp only [d_next_zero_chain_complex, d_from_eq_zero, limits.comp_zero], },
      all_goals
      { simp only [d_next_succ_chain_complex],
        dsimp,
        simp only [category.comp_id, category.assoc, iso.inv_hom_id, d_from_comp_X_next_iso_assoc,
          dite_eq_ite, if_true, eq_self_iff_true]}, },
    { cases i,
      all_goals
      { simp only [prev_d_chain_complex],
        dsimp,
        simp only [category.comp_id, category.assoc, iso.inv_hom_id, X_prev_iso_comp_d_to,
          dite_eq_ite, if_true, eq_self_iff_true], }, },
  end, }

end

end mk_inductive

end homotopy

/--
A homotopy equivalence between two chain complexes consists of a chain map each way,
and homotopies from the compositions to the identity chain maps.

Note that this contains data;
arguably it might be more useful for many applications if we truncated it to a Prop.
-/
structure homotopy_equiv (C D : homological_complex V c) :=
(hom : C ⟶ D)
(inv : D ⟶ C)
(homotopy_hom_inv_id : homotopy (hom ≫ inv) (𝟙 C))
(homotopy_inv_hom_id : homotopy (inv ≫ hom) (𝟙 D))

namespace homotopy_equiv

/-- Any complex is homotopy equivalent to itself. -/
@[refl] def refl (C : homological_complex V c) : homotopy_equiv C C :=
{ hom := 𝟙 C,
  inv := 𝟙 C,
  homotopy_hom_inv_id := by simp,
  homotopy_inv_hom_id := by simp, }

instance : inhabited (homotopy_equiv C C) := ⟨refl C⟩

/-- Being homotopy equivalent is a symmetric relation. -/
@[symm] def symm
  {C D : homological_complex V c} (f : homotopy_equiv C D) :
  homotopy_equiv D C :=
{ hom := f.inv,
  inv := f.hom,
  homotopy_hom_inv_id := f.homotopy_inv_hom_id,
  homotopy_inv_hom_id := f.homotopy_hom_inv_id, }

/-- Homotopy equivalence is a transitive relation. -/
@[trans] def trans
  {C D E : homological_complex V c} (f : homotopy_equiv C D) (g : homotopy_equiv D E) :
  homotopy_equiv C E :=
{ hom := f.hom ≫ g.hom,
  inv := g.inv ≫ f.inv,
  homotopy_hom_inv_id := by simpa using
    ((g.homotopy_hom_inv_id.comp_right_id f.inv).comp_left f.hom).trans f.homotopy_hom_inv_id,
  homotopy_inv_hom_id := by simpa using
    ((f.homotopy_inv_hom_id.comp_right_id g.hom).comp_left g.inv).trans g.homotopy_inv_hom_id, }

end homotopy_equiv

variables [has_equalizers V] [has_cokernels V] [has_images V] [has_image_maps V]

variable [has_zero_object V]

/--
Homotopic maps induce the same map on homology.
-/
theorem homology_map_eq_of_homotopy (h : homotopy f g) (i : ι) :
  (homology_functor V c i).map f = (homology_functor V c i).map g :=
begin
  dsimp [homology_functor],
  apply eq_of_sub_eq_zero,
  ext,
  simp only [homology.π_map, comp_zero, preadditive.comp_sub],
  dsimp [kernel_subobject_map],
  simp_rw [h.comm i],
  simp only [add_zero, zero_comp, kernel_subobject_arrow_comp_assoc,
    preadditive.comp_add],
  rw [←preadditive.sub_comp],
  simp only [category_theory.subobject.factor_thru_add_sub_factor_thru_right],
  erw [subobject.factor_thru_of_le (D.boundaries_le_cycles i)],
  { simp, },
  { --rw [←category.assoc],
    --apply image_subobject_factors_comp_self,
    sorry },
end

/-- Homotopy equivalent complexes have isomorphic homologies. -/
def homology_obj_iso_of_homotopy_equiv (f : homotopy_equiv C D) (i : ι) :
  (homology_functor V c i).obj C ≅ (homology_functor V c i).obj D :=
{ hom := (homology_functor V c i).map f.hom,
  inv := (homology_functor V c i).map f.inv,
  hom_inv_id' := begin
    rw [←functor.map_comp, homology_map_eq_of_homotopy f.homotopy_hom_inv_id,
      category_theory.functor.map_id],
  end,
  inv_hom_id' := begin
    rw [←functor.map_comp, homology_map_eq_of_homotopy f.homotopy_inv_hom_id,
      category_theory.functor.map_id],
  end, }

end

namespace category_theory

variables {W : Type*} [category W] [preadditive W]

/-- An additive functor takes homotopies to homotopies. -/
@[simps]
def functor.map_homotopy (F : V ⥤ W) [F.additive] {f g : C ⟶ D} (h : homotopy f g) :
  homotopy ((F.map_homological_complex c).map f) ((F.map_homological_complex c).map g) :=
{ hom := λ i j, F.map (h.hom i j),
  zero' := λ i j w, by { rw [h.zero i j w, F.map_zero], },
  comm' := λ i, begin
    have := h.comm i,
    dsimp [d_next, prev_d] at *,
    rcases c.next i with _|⟨inext,wn⟩;
    rcases c.prev i with _|⟨iprev,wp⟩;
    dsimp [d_next, prev_d] at *;
    { intro h,
      simp [h] },
  end, }

/-- An additive functor preserves homotopy equivalences. -/
@[simps]
def functor.map_homotopy_equiv (F : V ⥤ W) [F.additive] (h : homotopy_equiv C D) :
  homotopy_equiv ((F.map_homological_complex c).obj C) ((F.map_homological_complex c).obj D) :=
{ hom := (F.map_homological_complex c).map h.hom,
  inv := (F.map_homological_complex c).map h.inv,
  homotopy_hom_inv_id := begin
    rw [←(F.map_homological_complex c).map_comp, ←(F.map_homological_complex c).map_id],
    exact F.map_homotopy h.homotopy_hom_inv_id,
  end,
  homotopy_inv_hom_id := begin
    rw [←(F.map_homological_complex c).map_comp, ←(F.map_homological_complex c).map_id],
    exact F.map_homotopy h.homotopy_inv_hom_id,
  end }

end category_theory
