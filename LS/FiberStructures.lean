/-
Copyright (c) 2023 Calle Sönne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Calle Sönne, Paul Lezeau
-/

import LS.FiberedCategories

universe u₁ v₁ u₂ v₂ u₃ w

open CategoryTheory Functor Category

variable {𝒮 : Type u₁} {𝒳 : Type u₂} [Category 𝒳] [Category 𝒮]

namespace Fibered


-- MISSING MATHLIB LEMMA

/-- If the two inner squares below commute, then so does the outer square.
```
  W ---f---> X ---f'--> X'
  |          |          |
  g          h          h'
  |          |          |
  v          v          v
  Y ---i---> Z ---i'--> Z'

```
-/
lemma CommSqComp {W X X' Y Z Z' : 𝒮} {f : W ⟶ X} {f' : X ⟶ X'} {g : W ⟶ Y} {h : X ⟶ Z} {h' : X' ⟶ Z'}
  {i : Y ⟶ Z} {i' : Z ⟶ Z'} (hsq₁ : CommSq f g h i) (hsq₂ : CommSq f' h h' i') : CommSq (f ≫ f') g h' (i ≫ i') :=
  ⟨by rw [←assoc, assoc, ←hsq₁.w, hsq₂.w, assoc]⟩

/-- Fiber p S is the type of elements of 𝒳 mapping to S via p  -/
def Fiber (p : 𝒳 ⥤ 𝒮) (S : 𝒮) := {a : 𝒳 // p.obj a = S}

/-- We can turn Fiber p S into a category by taking the morphisms to be those lying over 𝟙 S -/
instance FiberCategory (p : 𝒳 ⥤ 𝒮) (S : 𝒮) : Category (Fiber p S) where
  -- TODO: Is this the best implementation? IsHomLift allows us to use the api,
  -- but then we need to "reprove" p.obj a = S and p.obj b = S...
  -- Maybe just CommSq directly?
  Hom a b := {φ : a.1 ⟶ b.1 // IsHomLift p (𝟙 S) φ}
  id a := ⟨𝟙 a.1, IsHomLift_id a.2⟩
  comp φ ψ := ⟨φ.val ≫ ψ.val, by apply (comp_id (𝟙 S)) ▸ IsHomLift_comp φ.2 ψ.2⟩

-- TODO MIGHT NOT NEED THIS
def Fiber.mk_obj {p : 𝒳 ⥤ 𝒮} {S : 𝒮} {a : 𝒳} (ha : p.obj a = S) : Fiber p S := ⟨a, ha⟩

def Fiber.mk_map {p :𝒳 ⥤ 𝒮} {S : 𝒮} {a b : 𝒳} (ha : p.obj a = S) (hb : p.obj b = S) (φ : a ⟶ b) (hφ : IsHomLift p (𝟙 S) φ := by aesop_cat) : Fiber.mk_obj ha ⟶ Fiber.mk_obj hb := ⟨φ, hφ⟩

@[simp]
lemma Fiber.mk_map_id {p :𝒳 ⥤ 𝒮} {S : 𝒮} {a : 𝒳} (ha : p.obj a = S) : Fiber.mk_map ha ha (𝟙 a) = 𝟙 (Fiber.mk_obj ha) := rfl

-- TODO DO I EVEN NEED?
@[simp]
lemma Fiber.mk_obj_coe (p : 𝒳 ⥤ 𝒮) (a : 𝒳) : (Fiber.mk_obj (p:=p) (a:=a) rfl).1 = a := rfl

/-- The functor including Fiber p S into 𝒳 -/
def FiberInclusion (p : 𝒳 ⥤ 𝒮) (S : 𝒮) : (Fiber p S) ⥤ 𝒳 where
  obj a := a.1
  map φ := φ.1

instance FiberInclusionFaithful (p : 𝒳 ⥤ 𝒮) (S : 𝒮) : Faithful (FiberInclusion p S) where
  map_injective := Subtype.val_inj.1

/-- Given a functor F : C ⥤ 𝒳 mapping constantly to some S in the base,
  we get an induced functor C ⥤ Fiber p S -/
def FiberInducedFunctor {p : 𝒳 ⥤ 𝒮} {S : 𝒮} {C : Type _} [Category C]
  {F : C ⥤ 𝒳} (hF : F ⋙ p = (const C).obj S) : C ⥤ Fiber p S where
    obj := fun x => ⟨F.obj x, by simp only [←comp_obj, hF, const_obj_obj]⟩
    map := fun φ => ⟨F.map φ, {
      ObjLiftDomain := by simp only [←comp_obj, hF, const_obj_obj]
      ObjLiftCodomain := by simp only [←comp_obj, hF, const_obj_obj]
      HomLift := ⟨by simpa using (eqToIso hF).hom.naturality φ⟩
    }⟩

/-- The natural transformation between F : C ⥤ 𝒳 and .... -/
def FiberInducedFunctorNat {p : 𝒳 ⥤ 𝒮} {S : 𝒮} {C : Type _} [Category C] {F : C ⥤ 𝒳}
  (hF : F ⋙ p = (const C).obj S) : F ≅ (FiberInducedFunctor hF) ⋙ (FiberInclusion p S) where
    hom := { app := fun a => 𝟙 (F.obj a) }
    inv := { app := fun a => 𝟙 ((FiberInducedFunctor hF ⋙ FiberInclusion p S).obj a) }

-- TODO UPDATE MATHLIB + USE EXT OF ISO
lemma FiberInducedFunctorComp {p : 𝒳 ⥤ 𝒮} {S : 𝒮} {C : Type _} [Category C] {F : C ⥤ 𝒳}
  (hF : F ⋙ p = (const C).obj S) : F = (FiberInducedFunctor hF) ⋙ (FiberInclusion p S) := sorry

def FiberInducedFunctorUnique {p : 𝒳 ⥤ 𝒮} {S : 𝒮} {C : Type _} [Category C]
  {F : C ⥤ 𝒳} (hF : F ⋙ p = (const C).obj S) {Φ : C ⥤ Fiber p S}
  (hΦ : F = Φ ⋙ (FiberInclusion p S)) : Φ ≅ FiberInducedFunctor hF where
    hom := {
      app := fun x => sorry
      naturality := sorry
    }
    inv := sorry
    hom_inv_id := sorry
    inv_hom_id := sorry

-- TODO MAKE INTO A CLASS?
/-- FiberStruct is an exttrinsic notion of fibers on a functor p : 𝒳 ⥤ 𝒮. It is given by a collection
of categories Fib S for every S in 𝒮 (the fiber categories), equiped with functors ι : Fib S ⥤ 𝒳
which map constantly to S on the base such that the induced functor Fib S ⥤ Fiber p S is an equivalence. -/
structure FiberStruct (p : 𝒳 ⥤ 𝒮) where
  Fib (S : 𝒮) : Type _
  [isCategory (S : 𝒮) : Category (Fib S)]
  (ι (S : 𝒮) : (Fib S) ⥤ 𝒳)
  (comp_const (S : 𝒮) : (ι S) ⋙ p = (const (Fib S)).obj S)
  [equiv (S : 𝒮) : IsEquivalence (FiberInducedFunctor (comp_const S))]

instance {p : 𝒳 ⥤ 𝒮} (hp : FiberStruct p) {S : 𝒮} : Category (hp.Fib S) := hp.isCategory S

instance {p : 𝒳 ⥤ 𝒮} (hp : FiberStruct p) {S : 𝒮} : IsEquivalence (FiberInducedFunctor (hp.comp_const S)) := hp.equiv S

instance {p : 𝒳 ⥤ 𝒮} (hp : FiberStruct p) {S : 𝒮} : EssSurj (FiberInducedFunctor (hp.comp_const S)) :=
  Equivalence.essSurj_of_equivalence (FiberInducedFunctor (hp.comp_const S))

instance {p : 𝒳 ⥤ 𝒮} (hp : FiberStruct p) {S : 𝒮} : Faithful (hp.ι S) :=
  Faithful.of_iso (FiberInducedFunctorNat (hp.comp_const S)).symm

/- Now we define the standard/canonical fiber associated to a fibered category.
When the user does not wish to supply specific fiber categories, this will be the default choice. -/

def Fiber.comp_const_nat (p : 𝒳 ⥤ 𝒮) (S : 𝒮) : (FiberInclusion p S) ⋙ p ≅ (const (Fiber p S)).obj S where
  hom := {
    app := fun x => eqToHom x.prop
    naturality := fun x y φ => by simpa using φ.prop.3.1}
  inv := {
    app := fun x => eqToHom (x.prop).symm
    naturality := fun x y φ => by sorry
      }

lemma Fiber.comp_const (p : 𝒳 ⥤ 𝒮) (S : 𝒮) : (FiberInclusion p S) ⋙ p = (const (Fiber p S)).obj S := by
  sorry

instance FiberStruct.canonical (p : 𝒳 ⥤ 𝒮) : FiberStruct p where
  Fib := Fiber p
  ι := FiberInclusion p
  comp_const := Fiber.comp_const p
  equiv := sorry -- NEED IsInducedFunctor id!!

-- BASIC API CONSTRUCTIONS
def FiberStructProj {p : 𝒳 ⥤ 𝒮} {hp : FiberStruct p} {S R : 𝒮} {a : hp.Fib S} {b : hp.Fib R}
  (φ : (hp.ι S).obj a ⟶ (hp.ι R).obj b) : S ⟶ R := sorry

@[simp]
lemma FiberStructObjLift {p : 𝒳 ⥤ 𝒮} {hp : FiberStruct p} {S : 𝒮} (a : hp.Fib S) : p.obj ((hp.ι S).obj a) = S :=
  by simp only [←comp_obj, hp.comp_const, const_obj_obj]

/-- For any homomorphism φ in a fiber Fib S, its image under ι S lies over 𝟙 S -/
lemma FiberStructHomLift {p : 𝒳 ⥤ 𝒮} {hp : FiberStruct p} {S : 𝒮} {a b : hp.Fib S}
  (φ : a ⟶ b) : IsHomLift p (𝟙 S) ((hp.ι S).map φ) where
  ObjLiftDomain := FiberStructObjLift a
  ObjLiftCodomain := FiberStructObjLift b
  HomLift := ⟨by
    rw [←Functor.comp_map, Functor.congr_hom (hp.comp_const S)] -- Can easily be replaced if we decide to work up to iso
    simp only [comp_obj, const_obj_obj, const_obj_map, id_comp, eqToHom_trans, comp_id]⟩

/-- A version of fullness of the functor Fib S ⥤ Fiber p S that can be used inside the category 𝒳 -/
lemma FiberStructFull {p : 𝒳 ⥤ 𝒮} {hp : FiberStruct p} {S : 𝒮} {a b : hp.Fib S} {φ : (hp.ι S).obj a ⟶ (hp.ι S).obj b}
  (hφ : IsHomLift p (𝟙 S) φ) : ∃ (ψ : a ⟶ b), (hp.ι S).map ψ = φ := by
  -- TODO IMPROVE PROOF... Only 5 last lines should be necessary
  let a' : Fiber p S := ⟨(hp.ι S).obj a, FiberStructObjLift a⟩
  let b' : Fiber p S := ⟨(hp.ι S).obj b, FiberStructObjLift b⟩
  let φ' : a' ⟶ b' := ⟨φ, hφ⟩ -- TODO TURN INTO API ABOVE

  let c : Fiber p S := (FiberInducedFunctor (hp.comp_const S)).obj a
  let d : Fiber p S := (FiberInducedFunctor (hp.comp_const S)).obj b
  let ψ : c ⟶ d := φ'

  use (Full.preimage ψ)

  rw [←NatIso.naturality_2 (FiberInducedFunctorNat (hp.comp_const S))]
  unfold FiberInducedFunctorNat
  simp only [comp_obj, Functor.comp_map, Full.witness, comp_id, id_comp]
  rfl

/-- A version of essential surjectivity of the functor Fib S ⥤ Fiber p S that can be used inside the category 𝒳 -/
lemma FiberStructEssSurj {p : 𝒳 ⥤ 𝒮} (hp : FiberStruct p) {S : 𝒮} {a : 𝒳} (ha : p.obj a = S) :
  ∃ (b : hp.Fib S) (φ : (hp.ι S).obj b ⟶ a), IsIso φ ∧ IsHomLift p (𝟙 S) φ := by
  -- This will be easy to inline
  use Functor.objPreimage (FiberInducedFunctor (hp.comp_const S)) (Fiber.mk_obj ha)
  let Φ := Functor.objObjPreimageIso (FiberInducedFunctor (hp.comp_const S)) (Fiber.mk_obj ha)
  use (FiberInclusion p S).map Φ.hom
  refine ⟨inferInstance, Φ.hom.2⟩

lemma FiberStructEssSurj' {p : 𝒳 ⥤ 𝒮} (hp : FiberStruct p) {S : 𝒮} {a : 𝒳} (ha : p.obj a = S) :
  ∃ (b : hp.Fib S) (φ : (hp.ι S).obj b ≅ a), IsHomLift p (𝟙 S) φ.hom := by
  -- This will be easy to inline
  use Functor.objPreimage (FiberInducedFunctor (hp.comp_const S)) (Fiber.mk_obj ha)
  let Φ := Functor.objObjPreimageIso (FiberInducedFunctor (hp.comp_const S)) (Fiber.mk_obj ha)
  refine ⟨(FiberInclusion p S).mapIso Φ, Φ.hom.2⟩

-- MIGHT NOT NEED....
def FiberStructMap {p : 𝒳 ⥤ 𝒮} {hp : FiberStruct p} {R S : 𝒮} {a : hp.Fib S}
  {b : hp.Fib R} (φ : (hp.ι R).obj b ⟶ (hp.ι S).obj a) : R ⟶ S :=
    eqToHom (FiberStructObjLift b).symm ≫ (p.map φ) ≫ eqToHom (FiberStructObjLift a)

/-- A Fibered structure is a FiberStruct such that the underlying functor p : 𝒳 ⥤ 𝒮 is a fibered category -/
structure FiberedStruct (p : 𝒳 ⥤ 𝒮) extends FiberStruct p where
  [isFibered : IsFibered p]

/-- Given a FiberStruct and a diagram
```
           a
           -
           |
           v
  R --f--> S
```
with a in Fib S, we can take a pullback b = `R ×_S a` in Fib R -/
lemma FiberStructPullback {p : 𝒳 ⥤ 𝒮} {hp : FiberedStruct p} {R S : 𝒮} (a : hp.Fib S)
  (f : R ⟶ S) : ∃ (b : hp.Fib R) (φ : (hp.ι R).obj b ⟶ (hp.ι S).obj a), IsPullback p f φ := by
    rcases hp.isFibered.has_pullbacks (FiberStructObjLift a) f with ⟨b, φ, hφ⟩
    rcases FiberStructEssSurj hp.1 hφ.ObjLiftDomain with ⟨b', ψ, hψ⟩
    use b', ψ ≫ φ
    rw [←id_comp f]
    exact IsPullback_comp (IsPullbackofIso hψ.2 hψ.1) hφ

-- TODO MAYBE REPLACE THE ABOVE WITH THIS LEMMA
lemma FiberStructPullback' {p : 𝒳 ⥤ 𝒮} (hp : FiberedStruct p) {R S : 𝒮} {a : 𝒳}
  (ha : p.obj a = S) (f : R ⟶ S) : ∃ (b : hp.Fib R) (φ : (hp.ι R).obj b ⟶ a),
    IsPullback p f φ := by
  rcases hp.isFibered.has_pullbacks ha f with ⟨b, φ, hφ⟩
  rcases FiberStructEssSurj hp.1 hφ.ObjLiftDomain with ⟨b', ψ, hψ⟩
  use b', ψ ≫ φ
  rw [←id_comp f]
  exact IsPullback_comp (IsPullbackofIso hψ.2 hψ.1) hφ

/-- Given a FiberedStruct, b' b in Fib R, an a pullback ψ : b ⟶ a in 𝒳, i.e.
```
b'       b --ψ--> a
|        |        |
v        v        v
R ====== R --f--> S
```
Then the induced map τ : b' ⟶ b to lies in the fiber over R -/
lemma FiberStructFactorization {p : 𝒳 ⥤ 𝒮} {hp : FiberedStruct p} {R S : 𝒮}
  {a : 𝒳} {b b' : hp.Fib R} {f : R ⟶ S} {φ : (hp.ι R).obj b ⟶ a}
  (hφ : IsHomLift p f φ) {ψ : (hp.ι R).obj b' ⟶ a} (hψ : IsPullback p f ψ) :
    ∃ (τ : b ⟶ b'), (hp.ι R).map τ ≫ ψ = φ := by
  -- By fullness, we can pull back τ to the fiber over R
  rcases FiberStructFull (IsPullbackInducedMap_IsHomLift hψ (id_comp f).symm hφ) with ⟨τ, hτ⟩
  use τ
  rw [hτ]
  exact (IsPullbackInducedMap_Diagram hψ (id_comp f).symm hφ)

noncomputable def FiberStructInducedMap {p : 𝒳 ⥤ 𝒮} {hp : FiberedStruct p} {R S : 𝒮}
  {a : 𝒳} {b b' : hp.Fib R} {f : R ⟶ S} {φ : (hp.ι R).obj b ⟶ a}
  (hφ : IsHomLift p f φ) {ψ : (hp.ι R).obj b' ⟶ a} (hψ : IsPullback p f ψ) : b ⟶ b' :=
  Classical.choose (FiberStructFactorization hφ hψ)

-- TODO FORMULATE...

/- lemma FiberStructFactorizationUnique {p : 𝒳 ⥤ 𝒮} {hp : FiberedStruct p} {R S : 𝒮}
  {a : 𝒳} {b b' : hp.Fib R} {f : R ⟶ S} {φ : (hp.ι R).obj b ⟶ a}
  (hφ : IsHomLift p f φ) {ψ : (hp.ι R).obj b' ⟶ a} (hψ : IsPullback p f ψ) : -/


-- TODO INDUCEDMAP IN FIBER API


-- TODO: In this lemma, should maybe just require that a lies over S (not necc in the fiber)
/-- Given a in Fib S, b in Fib R, and a diagram
```
  b --φ--> a
  -        -
  |        |
  v        v
  R --f--> S
```
It can be factorized as
```
  b --τ--> b'--ψ--> a
  -        -        -
  |        |        |
  v        v        v
  R ====== R --f--> S
```
with ψ a pullback of f and τ a map in Fib R -/
lemma fiber_factorization {p : 𝒳 ⥤ 𝒮} (hp : FiberedStruct p) {R S : 𝒮}
  {a : hp.Fib S} {b : hp.Fib R} {f : R ⟶ S} {φ : (hp.ι R).obj b ⟶ (hp.ι S).obj a}
  (hφ : IsHomLift p f φ) : ∃ (b' : hp.Fib R)
  (τ : b ⟶ b') (ψ : (hp.ι R).obj b' ⟶ (hp.ι S).obj a), IsPullback p f ψ ∧ (((hp.ι R).map τ) ≫ ψ = φ) := by
    rcases (FiberStructPullback a f) with ⟨b', ψ, hψ⟩
    rcases FiberStructFactorization hφ hψ with ⟨τ, hτ⟩
    use b', τ, ψ, hψ

end Fibered
