(**************************************************************************)
(*                                                                        *)
(*    Copyright (c) 2014 - 2017.                                          *)
(*    Dynamic Ledger Solutions, Inc. <contact@tezos.com>                  *)
(*                                                                        *)
(*    All rights reserved. No warranty, explicit or implicit, provided.   *)
(*                                                                        *)
(**************************************************************************)

type error +=
  | Initial_amount_too_low of Contract_repr.contract * Tez_repr.t * Tez_repr.t (* `Permanent *)
  | Balance_too_low of Contract_repr.contract * Tez_repr.t * Tez_repr.t (* `Temporary *)
  | Cannot_pay_storage_fee of Contract_repr.contract * Tez_repr.t * Tez_repr.t (* `Temporary *)
  | Counter_in_the_past of Contract_repr.contract * int32 * int32 (* `Branch *)
  | Counter_in_the_future of Contract_repr.contract * int32 * int32 (* `Temporary *)
  | Unspendable_contract of Contract_repr.contract (* `Permanent *)
  | Non_existing_contract of Contract_repr.contract (* `Temporary *)
  | Non_delegatable_contract of Contract_repr.contract (* `Permanent *)
  | Inconsistent_hash of Ed25519.Public_key.t * Ed25519.Public_key_hash.t * Ed25519.Public_key_hash.t (* `Permanent *)
  | Inconsistent_public_key of Ed25519.Public_key.t * Ed25519.Public_key.t (* `Permanent *)
  | Missing_public_key of Ed25519.Public_key_hash.t (* `Permanent *)
  | Failure of string (* `Permanent *)

val delete : Raw_context.t -> Contract_repr.t -> Raw_context.t tzresult Lwt.t

val exists: Raw_context.t -> Contract_repr.t -> bool tzresult Lwt.t
val must_exist: Raw_context.t -> Contract_repr.t -> unit tzresult Lwt.t

val list: Raw_context.t -> Contract_repr.t list Lwt.t

val check_counter_increment: Raw_context.t -> Contract_repr.t -> int32 -> unit tzresult Lwt.t
val increment_counter: Raw_context.t -> Contract_repr.t -> Raw_context.t tzresult Lwt.t

val is_delegatable : Raw_context.t -> Contract_repr.t -> bool tzresult Lwt.t
val is_spendable : Raw_context.t -> Contract_repr.t -> bool tzresult Lwt.t

val get_manager: Raw_context.t -> Contract_repr.t -> Ed25519.Public_key_hash.t tzresult Lwt.t
val update_manager_key:
  Raw_context.t -> Contract_repr.t -> Ed25519.Public_key.t option ->
  (Raw_context.t * Ed25519.Public_key.t) tzresult Lwt.t

val get_delegate_opt: Raw_context.t -> Contract_repr.t -> Ed25519.Public_key_hash.t option tzresult Lwt.t
val get_balance: Raw_context.t -> Contract_repr.t -> Tez_repr.t tzresult Lwt.t
val get_counter: Raw_context.t -> Contract_repr.t -> int32 tzresult Lwt.t

val get_script: Raw_context.t -> Contract_repr.t -> Script_repr.t option tzresult Lwt.t
val get_storage: Raw_context.t -> Contract_repr.t -> Script_repr.expr option tzresult Lwt.t

val update_script_storage_and_fees: Raw_context.t -> Contract_repr.t -> Tez_repr.t -> Script_repr.expr -> Raw_context.t tzresult Lwt.t

(** fails if the contract is not delegatable *)
val set_delegate : Raw_context.t -> Contract_repr.t -> Ed25519.Public_key_hash.t option -> Raw_context.t tzresult Lwt.t

val credit : Raw_context.t -> Contract_repr.t -> Tez_repr.t -> Raw_context.t tzresult Lwt.t

(** checks that the contract is spendable and decrease_balance *)
val spend : Raw_context.t -> Contract_repr.t -> Tez_repr.t -> Raw_context.t tzresult Lwt.t

(** decrease_balance even if the contract is not spendable *)
val spend_from_script : Raw_context.t -> Contract_repr.t -> Tez_repr.t -> Raw_context.t tzresult Lwt.t

val originate :
  Raw_context.t ->
  Contract_repr.origination_nonce ->
  balance:Tez_repr.t ->
  manager:Ed25519.Public_key_hash.t ->
  ?script:(Script_repr.t * (Tez_repr.t * Tez_repr.t)) ->
  delegate:Ed25519.Public_key_hash.t option ->
  spendable:bool ->
  delegatable:bool ->
  (Raw_context.t * Contract_repr.t * Contract_repr.origination_nonce) tzresult Lwt.t

val init :
  Raw_context.t -> Raw_context.t tzresult Lwt.t
