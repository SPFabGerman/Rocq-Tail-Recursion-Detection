From MetaRocq.Utils Require Import utils.
From MetaRocq.Template Require Import All.

Import IfNotations.

Require Import FixpointReference.
Require Import ContextTracking.

(* This file implements the main algorithm to find all recursive references and detect their respective kind.
It only includes functions for low level term checks. Higher level functions are defined in Commands.v as needed. *)

(** Recursively descend into term and return a list of all fixpoints in it to check.
Does not return nested fixpoints! These are handled later by [find_all_rec_calls]. *)
Fixpoint find_all_fixpoints (t : term) : list term :=
  match t with
  | tFix _ _ => [t]
  | tCast term _kind _type => find_all_fixpoints term
  | tProd _name _type body | tLambda _name _type body => find_all_fixpoints body
  | tLetIn _name def _type body => (find_all_fixpoints def) ++ (find_all_fixpoints body)
  | tApp func args => (find_all_fixpoints func) ++ (flat_map find_all_fixpoints args)
  | tCase _ind _type scrutinee branches => find_all_fixpoints scrutinee ++ (flat_map (fun b => find_all_fixpoints b.(bbody)) branches)
  | tProj _proj term => find_all_fixpoints term
  | _ => []
  end.

(** Remove leading Lambda Abstractions (tLambda) from the term.
Return the number of lambdas removed and the remaining body. *)
Fixpoint strip_lambdas (t : term) : (nat * term) :=
  match t with
  | tLambda _name _type body => let (i,r) := strip_lambdas body in (i+1,r)
  | _ => (0, t)
  end.

(** Takes a term (typically a function body) and a list of indices and names and returns a list of all references to these indices.
[caller] and [definition] are used to create the reference record. *)
Definition find_all_references (t : term) (context : fixpointcontext) (caller : name) (definition : kername) : list FixpointReference :=
  (** Recursively descend into a term and return a list of all references with matching de Bruijn indices.
  (For example recursive function calls.)
  [context] is automatically adjusted during the function call to handle newly introduced variables.
  [is_tailpos] denotes if the current term is in tail positiion. This is used to either assign Tailcall or NonTailcall as a reference [kind]. *)
  let fix find_all_references_aux (t : term) (context : fixpointcontext) (is_tailpos : bool) {struct t} : list FixpointReference :=
    let find_all_references_aux_notail := fun t => find_all_references_aux t context false
    in match t with
    
    (* Function Application *)
    | tApp func args => (flat_map find_all_references_aux_notail args) ++
      (* Check for direct function call with matching de Bruijn index. *)
      if func is (tRel n)
        then if (get_name_from_context context n) is Some callee
          (* Matching function call -> create reference *)
          then [mkFixpointReference caller callee definition t (if is_tailpos then Tailcall else NonTailcall)]
          (* Function call does not match -> ignore *)
          else []
        (* No direct function call -> descend into function. *)
        else find_all_references_aux_notail func
    
    (* Let Expressions: increase de Bruijn index by 1 *)
    | tLetIn _name def _type body => find_all_references_aux_notail def ++ find_all_references_aux body (increase_context context 1) is_tailpos
    
    (* Pattern Matching and Projection *)
    | tCase _ind _type scrutinee branches => find_all_references_aux_notail scrutinee ++
      (* Descend into each branch and increase index by number of newly introduced variables. *)
      (flat_map (fun b => find_all_references_aux b.(bbody) (increase_context context (length b.(bcontext))) is_tailpos) branches)
    | tProj _proj term => find_all_references_aux_notail term
    
    (* Typecasts *)
    | tCast term _kind _type => find_all_references_aux term context is_tailpos
    
    (* Unknown reference to [index] *)
    | tRel n => if (get_name_from_context context n) is Some callee then [mkFixpointReference caller callee definition t StandaloneReference] else []
    
    (* Elementary Stuff that cannot have a recursive call: Variables and Constants *)
    | tVar _ | tEvar _ _ | tConst _ _ | tInt _ | tFloat _ | tString _ => []
    (* Everything to do with types: Sorts, Inductive types and Inductive Constructors *)
    | tSort _ | tInd _ _ | tConstruct _ _ _ => []
    
    (* TODO: No support for nested Functions / Fixpoints and Arrays, as of now. No support for nested CoFixpoints. *)
    | tLambda _ _ _ | tProd _ _ _ | tFix _ _ | tArray _ _ _ _ | tCoFix _ _ => [mkFixpointReference caller nAnon definition t UnsupportedTerm]

    end
  in find_all_references_aux t context true.

(** Takes a term and returns all recursive references for all fixpoints in it.
Returns nothing, if the term does not have a fixpoint.
[definition] is only used to create the references. *)
Definition find_all_rec_references (t : term) (definition : kername) : list FixpointReference :=
  let fpts := find_all_fixpoints t
  in (flat_map
    (fun (fpt : term) =>
      match fpt with
      | tFix fpds n =>
        (* Create context of all fixpoints that we want to check against. This is the same for all definitions of the fixpoint. *)
        let context := get_fixpoint_context fpds
        in flat_map
          (fun fpd =>
            (* Get real function body and number of arguments that are added to the context in this definition. *)
            let (index, body) := strip_lambdas fpd.(dbody)
            in (find_all_references body (increase_context context index) (fpd.(dname).(binder_name)) definition))
          fpds
      | _ => [] (* This should be unreachable, as [find_all_fixpoints] should only ever return a list of fixpoints. *)
      end)
    fpts).
