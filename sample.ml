(*

Compilation of

data AlternatingList<A,B>:
  | empty
  | link(f :: A, r :: AlternatingList<B,A>)
end

*)
type meta_record = {
  fields: string list option;
  name: string;
}
let pAlternatingList_empty =
  { fields = None;
    name = "empty";
  }
let pAlternatingList_link =
  { fields = Some(["f"; "r"]);
    name = "link";
  }

type ('a, 'b) pvariant_link_fields = { f: 'a; r: ('b, 'a) pgen_AlternatingList}

and ('a, 'b) pgen_AlternatingList =
  | Pvariant_empty of meta_record
  | Pvariant_link of meta_record * ('b, 'a) pvariant_link_fields

let empty = Pvariant_empty(pAlternatingList_empty);;
let link f r = Pvariant_link(pAlternatingList_link, { f=f; r=r });;

(*

  Compilation of

  fun sum<Number,Number>(l :: AlternatingList<Number,Number>) -> Number:
    cases(AlternatingList) l:
      | empty => 0
      | link(f, r) => f + sum(r)
    end
  end
*)
let rec sum l =
  match l with
    | Pvariant_empty _ -> 0
    | Pvariant_link(_, { f = f; r = r }) -> f + (sum r);;

(*
  Compilation of

  lst = link(1, link("a", empty))
  lst.rest.first
*)

let lst = (link 1 (link "a" empty));;


(*

Compilation of

data AlternatingList<A,B>:
  | empty
  | link(f :: A, r :: AlternatingList<B,A>)
end

*)

type 'a prec_link = { tag: pgen_AlternatingList; f: 'a; r: 'a pgen_List }


and 'a pgen_List =
  | Pvariant_empty of 'a prec_empty
  | Pvariant_link of 'a prec_link
























































