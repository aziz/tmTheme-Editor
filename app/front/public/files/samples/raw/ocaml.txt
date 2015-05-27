open Lexer_flow
module Ast = Spider_monkey_ast
open Ast
module Error = Parse_error
module SSet = Set.Make(String)
module SMap = Map.Make(String)

type lex_mode =
  | NORMAL_LEX
  | TYPE_LEX
  | JSX_TAG
  | JSX_CHILD

let mode_to_string = function
  | NORMAL_LEX -> "NORMAL"
  | TYPE_LEX -> "TYPE"
  | JSX_TAG -> "JSX TAG"
  | JSX_CHILD -> "JSX CHILD"

let lex lex_env = function
  | NORMAL_LEX -> token lex_env
  | TYPE_LEX -> type_token lex_env
  | JSX_TAG -> lex_jsx_tag lex_env
  | JSX_CHILD -> lex_jsx_child lex_env

type env = {
  errors          : (Loc.t * Error.t) list ref;
  comments        : Comment.t list ref;
  labels          : SSet.t;
  lb              : Lexing.lexbuf;
  lookahead       : lex_result ref;
  last            : (lex_env * lex_result) option ref;
  priority        : int;
  strict          : bool;
  in_export       : bool;
  in_loop         : bool;
  in_switch       : bool;
  in_function     : bool;
  no_in           : bool;
  no_call         : bool;
  no_let          : bool;
  allow_yield     : bool;
  (* Use this to indicate that the "()" as in "() => 123" is not allowed in
   * this expression *)
  error_callback  : (env -> Error.t -> unit) option;
  lex_mode_stack  : lex_mode list ref;
  lex_env         : lex_env ref;
}

(* constructor *)
let init_env lb =
  let lex_env = new_lex_env lb in
  let lex_env, lookahead = lex lex_env NORMAL_LEX in
  {
    errors          = ref [];
    comments        = ref [];
    labels          = SSet.empty;
    lb              = lb;
    lookahead       = ref lookahead;
    last            = ref None;
    priority        = 0;
    strict          = false;
    in_export       = false;
    in_loop         = false;
    in_switch       = false;
    in_function     = false;
    no_in           = false;
    no_call         = false;
    no_let          = false;
    allow_yield     = true;
    error_callback  = None;
    lex_mode_stack  = ref [NORMAL_LEX];
    lex_env         = ref lex_env;
  }

(* getters: *)
let strict env = env.strict
let lookahead env = !(env.lookahead)
let lb env = env.lb
let lex_mode env = List.hd !(env.lex_mode_stack)
let lex_env env = !(env.lex_env)
let last env = !(env.last)
let in_export env = env.in_export
let comments env = !(env.comments)
let labels env = env.labels
let in_loop env = env.in_loop
let in_switch env = env.in_switch
let in_function env = env.in_function
let allow_yield env = env.allow_yield
let no_in env = env.no_in
let no_call env = env.no_call
let no_let env = env.no_let
let errors env = !(env.errors)
