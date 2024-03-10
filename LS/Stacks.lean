import LS.FiberedCategories
import Mathlib.CategoryTheory.Sites.Grothendieck
import Mathlib.CategoryTheory.Over
import Mathlib.CategoryTheory.NatIso


open CategoryTheory Functor Category Fibered

variable {𝒮 : Type u₁} {𝒳 : Type u₂} {𝒴 : Type u₃} [Category 𝒳] [Category 𝒮]
  [Category 𝒴]

class IsFiberedInGroupoids (p : 𝒳 ⥤ 𝒮) extends IsFibered p where
  (IsPullback {a b : 𝒳} (φ : b ⟶ a) :  IsPullback p (p.map φ) φ)

instance (S : 𝒮) : IsFiberedInGroupoids (Over.forget S) where
  has_pullbacks := fun h f => by
    let f' := f ≫ (eqToHom h.symm) ≫ (eqToHom (Functor.id_obj _)) ≫ (_ : Over S).hom ≫ (eqToHom (Functor.const_obj_obj _ _ _))
    use Over.mk f'
    let f'' := (eqToHom (Over.mk_left f')) ≫ f ≫ (eqToHom h.symm)
    let φ := Over.homMk f''
    use φ
    let pb : IsPullback (Over.forget S) f φ := {
      ObjLiftDomain := by simp
      ObjLiftCodomain := by simp only [←h, Over.forget_obj]
      HomLift := by
        constructor
        simp only [Over.forget_obj, eqToHom_refl, const_obj_obj, Over.mk_left, id_comp, Over.forget_map,
          Over.homMk_left]
        aesop
      UniversalProperty := by
        intro T a' g k hk ψ hψ
        sorry
    }
    exact pb
  IsPullback := by
    intro a b φ
    let pb : IsPullback (Over.forget S) ((Over.forget S).map φ) φ := {
      ObjLiftDomain := by simp
      ObjLiftCodomain := by simp
      HomLift := sorry
      UniversalProperty := sorry
    }
    exact pb

structure Fibered.Morphism (p : 𝒳 ⥤ 𝒮) (q : 𝒴 ⥤ 𝒮) extends CategoryTheory.Functor 𝒳 𝒴 where
  (w : toFunctor ⋙ q = p)

structure Fibered.TwoMorphism {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} (f g : Fibered.Morphism p q) extends
  CategoryTheory.NatTrans f.toFunctor g.toFunctor where
  (aboveId : ∀ (a : 𝒳), IsHomLift q  (𝟙 (p.obj a)) (toNatTrans.app a))

@[ext]
lemma Fibered.TwoMorphism.ext {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g : Fibered.Morphism p q} (α β : Fibered.TwoMorphism f g)
  (h : α.toNatTrans = β.toNatTrans) : α = β := by
  cases α
  cases β
  simp at h
  subst h
  rfl

def Fibered.TwoMorphism.id {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} (f : Fibered.Morphism p q) : Fibered.TwoMorphism f f := {
  toNatTrans := CategoryTheory.NatTrans.id f.toFunctor
  aboveId := by
    intro a
    constructor
    · constructor
      simp only [NatTrans.id_app', map_id, id_comp, comp_id]
    all_goals rw [←CategoryTheory.Functor.comp_obj, f.w] }

@[simp]
lemma Fibered.TwoMorphism.id_toNatTrans {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} (f : Fibered.Morphism p q) : (Fibered.TwoMorphism.id f).toNatTrans = CategoryTheory.NatTrans.id f.toFunctor := rfl

def Fibered.TwoMorphism.comp {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h : Fibered.Morphism p q} (α : Fibered.TwoMorphism f g) (β : Fibered.TwoMorphism g h) :
  Fibered.TwoMorphism f h := {
    toNatTrans := CategoryTheory.NatTrans.vcomp α.toNatTrans β.toNatTrans
    aboveId := by
      intro a
      rw [CategoryTheory.NatTrans.vcomp_app, show 𝟙 (p.obj a) = 𝟙 (p.obj a) ≫ 𝟙 (p.obj a) by simp only [comp_id]]
      apply IsHomLift_comp (α.aboveId _) (β.aboveId _)
  }

@[simp]
lemma Fibered.TwoMorphism.comp_app {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h : Fibered.Morphism p q} (α : Fibered.TwoMorphism f g) (β : Fibered.TwoMorphism g h) (x : 𝒳) : (comp α β).app x = (α.app x) ≫ β.app x:= rfl

@[simp]
lemma CategoryTheory.NatTrans.id_vcomp {C D : Type _} [Category C] [Category D] {F G : C ⥤ D} (f : NatTrans F G) :
  NatTrans.vcomp (NatTrans.id F) f = f := by
  ext x
  simp only [vcomp_eq_comp, comp_app, id_app', id_comp]

@[simp]
lemma CategoryTheory.NatTrans.vcomp_id {C D : Type _} [Category C] [Category D] {F G : C ⥤ D} (f : NatTrans F G) :
  NatTrans.vcomp f (NatTrans.id G) = f := by
  ext x
  simp only [vcomp_eq_comp, comp_app, id_app', comp_id]

@[simp]
lemma Fibered.TwoMorphism.comp_toNatTrans {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h : Fibered.Morphism p q} (α : Fibered.TwoMorphism f g) (β : Fibered.TwoMorphism g h) : (comp α β).toNatTrans = NatTrans.vcomp α.toNatTrans β.toNatTrans := rfl

@[simp]
lemma Fibered.TwoMorphism.id_comp {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g : Fibered.Morphism p q} (α : Fibered.TwoMorphism f g) :
  Fibered.TwoMorphism.comp (Fibered.TwoMorphism.id f) α = α := by
  apply Fibered.TwoMorphism.ext
  rw [Fibered.TwoMorphism.comp_toNatTrans, Fibered.TwoMorphism.id_toNatTrans, CategoryTheory.NatTrans.id_vcomp]

@[simp]
lemma Fibered.TwoMorphism.comp_id {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g : Fibered.Morphism p q} (α : Fibered.TwoMorphism f g) :
  Fibered.TwoMorphism.comp α (Fibered.TwoMorphism.id g) = α := by
  apply Fibered.TwoMorphism.ext
  rw [Fibered.TwoMorphism.comp_toNatTrans, Fibered.TwoMorphism.id_toNatTrans, CategoryTheory.NatTrans.vcomp_id]

lemma Fibered.TwoMorphism.comp_assoc {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h i : Fibered.Morphism p q} (α : Fibered.TwoMorphism f g) (β : Fibered.TwoMorphism g h) (γ : Fibered.TwoMorphism h i) :
  Fibered.TwoMorphism.comp (Fibered.TwoMorphism.comp α β) γ = Fibered.TwoMorphism.comp α (Fibered.TwoMorphism.comp β γ):= by
  apply Fibered.TwoMorphism.ext
  rw [Fibered.TwoMorphism.comp_toNatTrans, Fibered.TwoMorphism.comp_toNatTrans, Fibered.TwoMorphism.comp_toNatTrans, Fibered.TwoMorphism.comp_toNatTrans, NatTrans.vcomp_eq_comp, NatTrans.vcomp_eq_comp, NatTrans.vcomp_eq_comp, NatTrans.vcomp_eq_comp, assoc]

structure Fibered.TwoIsomorphism {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} (f g : Fibered.Morphism p q) extends
  f.toFunctor ≅ g.toFunctor where
  (aboveId : ∀ (a : 𝒳), IsHomLift q (𝟙 (p.obj a)) (toIso.hom.app a))

@[ext]
lemma Fibered.TwoIsomorphism.ext {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g : Fibered.Morphism p q} (α β : Fibered.TwoIsomorphism f g)
  (h : α.toIso = β.toIso) : α = β := by
  cases α
  cases β
  simp at h
  subst h
  rfl

def Fibered.TwoIsomorphism.id {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} (f : Fibered.Morphism p q) : Fibered.TwoIsomorphism f f := {
  toIso := CategoryTheory.Iso.refl f.toFunctor
  aboveId := by
    intro a
    constructor
    · constructor
      simp only [Iso.refl_hom, NatTrans.id_app, map_id, id_comp, comp_id]
    all_goals rw [←CategoryTheory.Functor.comp_obj, f.w] }

@[simp]
lemma Fibered.TwoIsomorphism.id_toNatIso {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} (f : Fibered.Morphism p q) : (Fibered.TwoIsomorphism.id f).toIso = CategoryTheory.Iso.refl f.toFunctor := rfl

def Fibered.TwoIsomorphism.comp {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h : Fibered.Morphism p q} (α : Fibered.TwoIsomorphism f g) (β : Fibered.TwoIsomorphism g h) :
  Fibered.TwoIsomorphism f h := {
    toIso := α.toIso.trans β.toIso
    aboveId := by
      intro a
      rw [Iso.trans_hom, NatTrans.comp_app, show 𝟙 (p.obj a) = 𝟙 (p.obj a) ≫ 𝟙 (p.obj a) by simp only [comp_id]]
      apply IsHomLift_comp (α.aboveId _) (β.aboveId _)
  }

@[simp]
lemma Fibered.TwoIsomorphism.comp_app {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h : Fibered.Morphism p q} (α : Fibered.TwoIsomorphism f g) (β : Fibered.TwoIsomorphism g h) (x : 𝒳) : (comp α β).hom.app x = (α.hom.app x) ≫ β.hom.app x:= rfl

@[simp]
lemma Fibered.TwoIsomorphism.comp_toIso {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h : Fibered.Morphism p q} (α : Fibered.TwoIsomorphism f g) (β : Fibered.TwoIsomorphism g h) : (comp α β).toIso = α.toIso.trans β.toIso := rfl

@[simp]
lemma Fibered.TwoIsomorphism.id_comp {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g : Fibered.Morphism p q} (α : Fibered.TwoIsomorphism f g) :
  Fibered.TwoIsomorphism.comp (Fibered.TwoIsomorphism.id f) α = α := by
  apply Fibered.TwoIsomorphism.ext
  rw [Fibered.TwoIsomorphism.comp_toIso, Fibered.TwoIsomorphism.id_toNatIso, Iso.refl_trans]

@[simp]
lemma Fibered.TwoIsomorphism.comp_id {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g : Fibered.Morphism p q} (α : Fibered.TwoIsomorphism f g) :
  Fibered.TwoIsomorphism.comp α (Fibered.TwoIsomorphism.id g) = α := by
  apply Fibered.TwoIsomorphism.ext
  rw [Fibered.TwoIsomorphism.comp_toIso, Fibered.TwoIsomorphism.id_toNatIso, Iso.trans_refl]

lemma Fibered.TwoIsomorphism.comp_assoc {p : 𝒳 ⥤ 𝒮} {q : 𝒴 ⥤ 𝒮} {f g h i : Fibered.Morphism p q} (α : Fibered.TwoIsomorphism f g) (β : Fibered.TwoIsomorphism g h) (γ : Fibered.TwoIsomorphism h i) :
  Fibered.TwoIsomorphism.comp (Fibered.TwoIsomorphism.comp α β) γ = Fibered.TwoIsomorphism.comp α (Fibered.TwoIsomorphism.comp β γ):= by
  apply Fibered.TwoIsomorphism.ext
  rw [Fibered.TwoIsomorphism.comp_toIso, Fibered.TwoIsomorphism.comp_toIso, Fibered.TwoIsomorphism.comp_toIso, Fibered.TwoIsomorphism.comp_toIso, Iso.trans_assoc]

instance (p : 𝒳 ⥤ 𝒮) (q : 𝒴 ⥤ 𝒮) [IsFiberedInGroupoids p] [IsFiberedInGroupoids q] : Category (Fibered.Morphism p q) where
  Hom f g := Fibered.TwoIsomorphism f g
  id f := Fibered.TwoIsomorphism.id f
  comp := Fibered.TwoIsomorphism.comp
  id_comp := Fibered.TwoIsomorphism.id_comp
  comp_id := Fibered.TwoIsomorphism.comp_id
  assoc := Fibered.TwoIsomorphism.comp_assoc

/- def TwoYoneda.toFun (p : 𝒳 ⥤ 𝒮) (S : 𝒮) [IsFiberedInGroupoids p] :
  Fibered.Morphism (Over.forget S) p ⥤  := {
    toFunctor := Over.mk
    w := by
      ext
      simp
  }
 -/
section Stack

noncomputable abbrev pb1 [Limits.HasPullbacks 𝒮] {S : 𝒮}
  {Y Y' : 𝒮} (f : Y ⟶ S) (f' : Y' ⟶ S)  :=
  (@Limits.pullback.fst _ _ _ _ _ f f' _)

noncomputable abbrev pb2 [Limits.HasPullbacks 𝒮] {S : 𝒮}
  {Y Y' : 𝒮} (f : Y ⟶ S) (f' : Y' ⟶ S) :=
  (@Limits.pullback.snd _ _ _ _ _ f f' _)

noncomputable abbrev dpb1 [Limits.HasPullbacks 𝒮] {S : 𝒮}
  {Y Y' Y'' : 𝒮} (f : Y ⟶ S) (f' : Y' ⟶ S) (f'' : Y'' ⟶ S)
 := (@Limits.pullback.fst _ _ _ _ _ (pb1 f f' ≫ f) f'' _)

noncomputable abbrev dpb2 [Limits.HasPullbacks 𝒮] {S : 𝒮}
  {Y Y' Y'' : 𝒮} (f : Y ⟶ S) (f' : Y' ⟶ S) (f'' : Y'' ⟶ S)
 := (@Limits.pullback.snd _ _ _ _ _ (pb1 f f' ≫ f) f'' _)

noncomputable abbrev dpb3 [Limits.HasPullbacks 𝒮] {S : 𝒮}
  {Y Y' Y'' : 𝒮} (f : Y ⟶ S) (f' : Y' ⟶ S) (f'' : Y'' ⟶ S) :=
(@Limits.pullback.snd _ _ _ _ _ (pb1 f f' ≫ f) f'' _)

variable (J : GrothendieckTopology 𝒮) (S Y : 𝒮) (I : Sieve S) (hI : I ∈ J.sieves S) (f : Y ⟶ S) (hf : I f)

/--  Say `S_i ⟶ S` is a cover in `𝒮`, `a b` elements of `𝒳` lying over `S`.
  The **morphism gluing condition**
  states that if we have a family of morphisms `φ_i : a|S_i ⟶ b` such that `φ_i|S_ij = φ_j|S_ij` then there exists a unique
  morphism `φ : a ⟶ b` such that the following triangle commutes

  a|S_i ⟶ a
    φ_i ↘  ↓ φ
           b

-/
def morphisms_glue [Limits.HasPullbacks 𝒮] {p : 𝒳 ⥤ 𝒮} (hp : IsFiberedInGroupoids p) : Prop :=
  ∀ (S : 𝒮) (I : Sieve S), I ∈ J.sieves S →
  ∀ (a b : 𝒳) (ha : p.obj a = S) (hb : p.obj b = S)
  (φ : ∀ (Y : 𝒮) (f : Y ⟶ S), I f → (PullbackObj hp.1 ha f ⟶ b))
  (Y Y' : 𝒮) (f : Y ⟶ S) (f' : Y' ⟶ S) (hf : I f) (hf' : I f'),
  (PullbackMap hp.1 (PullbackObjLiftDomain hp.1 ha f) (pb1 f f') ≫ (φ Y f hf)) = (pullback_iso_pullback' hp.1 ha f f').hom ≫
    (PullbackMap hp.1 (PullbackObjLiftDomain hp.1 ha f') (pb2 f f') ≫ (φ Y' f' hf')) →
  ∃! Φ : a ⟶ b, HomLift' (𝟙 S) Φ ha hb ∧ ∀ (Y : 𝒮) (f : Y ⟶ S) (hf : I f), φ Y f hf = PullbackMap hp.1 ha f ≫ Φ

/-- The canonical isomorphism `((a_j)|S_ij)|S_ijk ≅ ((a_j)|S_jk))|S_jki` where `S_ij = S_i ×_S S_j` and `S_ijk = S_ij ×_S S_k`, etc-/
noncomputable def dpbi {p : 𝒳 ⥤ 𝒮} (hp : IsFiberedInGroupoids p)
  {S : 𝒮} {I : Sieve S} (_ : I ∈ J.sieves S) [Limits.HasPullbacks 𝒮]
  {a : ∀ {Y : 𝒮} {f : Y ⟶ S} (_ : I f), 𝒳}
  {ha : ∀ {Y : 𝒮} {f : Y ⟶ S} (hf : I f), p.obj (a hf) = Y} {Y Y' Y'': 𝒮}
  {f : Y ⟶ S} {f' : Y' ⟶ S} {f'' : Y'' ⟶ S} (_ : I f) (hf' : I f') (_ : I f'') :
  PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb2 f f')) (dpb1 f f' f'') ≅
    PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb1 f' f'')) (dpb1 f' f'' f) := by
  have lem₁ : IsPullback p (dpb1 f f' f'' ≫ pb2 f f') (PullbackMap hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb2 f f')) (dpb1 f f' f'')
    ≫ PullbackMap hp.1 (ha hf') (pb2 f f'))
  · apply IsPullback_comp
    apply PullbackMapIsPullback
    apply PullbackMapIsPullback
  have lem₂ : IsPullback p (dpb1 f' f'' f ≫ pb1 f' f'') (PullbackMap hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb1 f' f'')) (dpb1 f' f'' f) ≫ (PullbackMap hp.1 (ha hf') (pb1 f' f'')))
  · apply IsPullback_comp
    apply PullbackMapIsPullback
    apply PullbackMapIsPullback
  apply IsPullbackInducedMapIsoofIso _ lem₂ lem₁
  · calc  Limits.pullback (pb1 f f' ≫ f) f'' ≅ Limits.pullback (pb2 f f' ≫ f') f'' := Limits.pullback.congrHom
            (Limits.pullback.condition) rfl
      _ ≅ Limits.pullback f (pb1 f' f'' ≫ f') := Limits.pullbackAssoc _ _ _ _
      _ ≅  Limits.pullback (pb1 f' f'' ≫ f') f := Limits.pullbackSymmetry _ _
  · aesop

/-- Given `φ : a ⟶ b` in `𝒳` lying above `𝟙 R` and morphisms `R ⟶ S ⟵ T`, `res_int` defines the
    restriction `φ|(R ×_S T)` to the "intersection" `a|(R ×_S T)` -/
noncomputable def res_int [Limits.HasPullbacks 𝒮] {p : 𝒳 ⥤ 𝒮} (hp : IsFiberedInGroupoids p)
  {R S T : 𝒮} {a b : 𝒳} {φ : a ⟶ b} (f : R ⟶ S) (g : T ⟶ S) (hφ : IsHomLift p (𝟙 R) φ) :
  PullbackObj hp.1 hφ.1 (pb1 f g) ⟶ PullbackObj hp.1 hφ.2 (pb1 f g) :=
IsPullbackNaturalityHom (PullbackMapIsPullback hp.1 hφ.1 (pb1 f g)) (PullbackMapIsPullback hp.1 hφ.2 (pb1 f g)) φ hφ

-- NOTE (From Calle): Might not need assunmptions ha anymore now that we are working with the IsHomLift class?
-- (Not sure though, havnt really thought about it, just did the minimum so that code compiles w new definitions)
/-- Say `S_i ⟶ S` is a cover in `𝒮` and `a_i` lies over `S_i`
  The **cocyle condition** for a family of isomorphisms `α_ij : a_i|S_ij ⟶ a_j|S_ij ` above the identity states that
  `α_jk|S_ijk ∘ α_ij|S_ijk = α_ik|S_ijk` -/
def CocyleCondition {p : 𝒳 ⥤ 𝒮} (hp : IsFiberedInGroupoids p)
  {S : 𝒮} {I : Sieve S} (hI : I ∈ J.sieves S) [Limits.HasPullbacks 𝒮]
  {a : ∀ {Y : 𝒮} {f : Y ⟶ S}, I f → 𝒳}
  (ha : ∀ {Y : 𝒮} {f : Y ⟶ S} (hf : I f), p.obj (a hf) = Y)
  (α : ∀ {Y Y' : 𝒮} {f : Y ⟶ S} {f' : Y' ⟶ S} (hf : I f) (hf' : I f'),
    PullbackObj hp.1 (ha hf) (pb1 f f') ≅ PullbackObj hp.1 (ha hf') (pb2 f f'))
  (hα' : ∀ {Y Y' : 𝒮} {f : Y ⟶ S} {f' : Y' ⟶ S} (hf : I f) (hf' : I f'),
    IsHomLift p (𝟙 (@Limits.pullback _ _ _ _ _ f f' _)) (α hf hf').hom) : Prop :=
   ∀ {Y Y' Y'': 𝒮} {f : Y ⟶ S} {f' : Y' ⟶ S} {f'' : Y'' ⟶ S} (hf : I f) (hf' : I f') (hf'' : I f''),
    ((show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf) (pb1 f f')) (dpb1 f f' f'') ⟶
      PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb2 f f')) (dpb1 f f' f'') from
      res_int hp _ _ (hα' hf hf')) ≫
    (show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb2 f f')) (dpb1 f f' f'') ≅
      PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb1 f' f'')) (dpb1 f' f'' f) from dpbi J hp hI hf hf' hf'').hom) ≫
    ((show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf') (pb1 f' f'')) (dpb1 f' f'' f) ⟶
      PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf'') (pb2 f' f'')) (dpb1 f' f'' f) from
      res_int hp _ _ (hα' hf' hf'')) ≫
    (show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf'') (pb2 f' f'')) (dpb1 f' f'' f) ≅
      PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf'') (pb1 f'' f)) (dpb1 f'' f f') from dpbi J hp hI hf' hf'' hf).hom) ≫
    ((show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf'') (pb1 f'' f)) (dpb1 f'' f f') ⟶
      PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf) (pb2 f'' f)) (dpb1 f'' f f') from
      res_int hp _ _ (hα' hf'' hf)) ≫
    (show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf) (pb2 f'' f)) (dpb1 f'' f f') ≅
      PullbackObj hp.1 (PullbackObjLiftDomain hp.1 (ha hf) (pb1 f f')) (dpb1 f f' f'') from dpbi J hp hI hf'' hf hf').hom)
    = 𝟙 _

/-TODO: the following should be defined in terms of a `descent datum` data type (containing
  all the information about the `a_i` and the `α_i`), which should have a predicate saying
  when it is effective.-/

/-- Say `S_i ⟶ S` is a cover in `𝒮` and `a_i` lies over `S_i`.
  The **object gluing condition** states that if we have a
  family of isomorphisms `α_ij : a_i|S_ij ⟶ a_j|S_ij ` above the identity that verify the cocyle condition then there
  exists an object `a` lying over `S` together with maps `φ_i : a|S_i ⟶ a_i` such that `φ_j|S_ij ∘ α_ij = φ_i|S_ij` -/
def objects_glue {p : 𝒳 ⥤ 𝒮} (hp : IsFiberedInGroupoids p)
  [Limits.HasPullbacks 𝒮] : Prop :=
  ∀ (S : 𝒮) (I : Sieve S) (hI : I ∈ J.sieves S)
  (a : ∀ {Y : 𝒮} {f : Y ⟶ S}, I f → 𝒳)
  (ha : ∀ {Y : 𝒮} {f : Y ⟶ S} (hf : I f), p.obj (a hf) = Y)
  (α : ∀ {Y Y' : 𝒮} {f : Y ⟶ S} {f' : Y' ⟶ S} (hf : I f) (hf' : I f'),
    PullbackObj hp.1 (ha hf) (@Limits.pullback.fst _ _ _ _ _ f f' _)
    ≅ PullbackObj hp.1 (ha hf') (@Limits.pullback.snd _ _ _ _ _ f f' _))
  (hα : ∀ {Y Y' : 𝒮} {f : Y ⟶ S} {f' : Y' ⟶ S} (hf : I f) (hf' : I f'),
    IsHomLift p (𝟙 (@Limits.pullback _ _ _ _ _ f f' _)) (α hf hf').hom),
  CocyleCondition J hp hI ha α hα →
  ∃ (b : 𝒳) (hb : p.obj b = S)
      (φ : ∀ {Y : 𝒮} {f : Y ⟶ S} (hf : I f), PullbackObj hp.1 hb f ≅ a hf)
      (hφ : ∀ {Y : 𝒮} {f : Y ⟶ S} (hf : I f),
      IsHomLift p (𝟙 Y) (φ hf).hom),
     ∀ (Y Y' : 𝒮) (f : Y ⟶ S) (f' : Y' ⟶ S) (hf : I f) (hf' : I f'),
    CommSq
    (show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 hb f) (pb1 f f') ⟶
      PullbackObj hp.1 (ha hf) (Limits.pullback.fst) from
        IsPullbackNaturalityHom (PullbackMapIsPullback hp.1 (PullbackObjLiftDomain hp.1 hb f)
    (pb1 f f'))  (PullbackMapIsPullback hp.1 (ha hf) Limits.pullback.fst)
       (show PullbackObj hp.1 hb f ⟶ a hf from (φ hf).hom) (hφ hf))
    (show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 hb f) (pb1 f f') ⟶ PullbackObj hp.1 (PullbackObjLiftDomain hp.1 hb f')
      (pb1 f' f) from
        (PullbackCompIsoPullbackPullback hp.1 hb f (pb1 f f')).symm.hom ≫ (PullbackPullbackIso'' hp.1 hb f f').hom ≫ (PullbackCompIsoPullbackPullback hp.1 _ _ _).hom)
    (show PullbackObj hp.1 (ha hf) (Limits.pullback.fst) ⟶ PullbackObj hp.1 (ha hf') (pb1 f' f)from
      ((α hf hf').hom ≫ (show PullbackObj hp.1 (ha hf') (pb2 f f') ⟶ PullbackObj hp.1 (ha hf') (pb1 f' f) from
        (PullbackPullbackIso''' hp.1 (ha hf') f' f ).symm.hom)))
      (show PullbackObj hp.1 (PullbackObjLiftDomain hp.1 hb f') (pb1 f' f) ⟶ PullbackObj hp.1 (ha hf') (pb1 f' f)
    from IsPullbackNaturalityHom (PullbackMapIsPullback hp.1 (PullbackObjLiftDomain hp.1 hb f')
    (pb1 f' f))  (PullbackMapIsPullback hp.1 (ha hf') Limits.pullback.fst)
    (show PullbackObj hp.1 hb f' ⟶ a hf' from (φ hf').hom) (hφ hf'))

/-- A **Stack** `p : 𝒳 ⥤ 𝒮` is a functor fibered in groupoids that satisfies the object gluing and morphism gluing
  properties -/
class Stack {p : 𝒳 ⥤ 𝒮} (hp : IsFiberedInGroupoids p)
  [Limits.HasPullbacks 𝒮] : Prop where
  (GlueMorphism : morphisms_glue J hp)
  (ObjectsGlue : objects_glue J hp)

end Stack
