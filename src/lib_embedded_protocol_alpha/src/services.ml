(**************************************************************************)
(*                                                                        *)
(*    Copyright (c) 2014 - 2017.                                          *)
(*    Dynamic Ledger Solutions, Inc. <contact@tezos.com>                  *)
(*                                                                        *)
(*    All rights reserved. No warranty, explicit or implicit, provided.   *)
(*                                                                        *)
(**************************************************************************)

open Data_encoding
open Tezos_context

let error_encoding =
  let open Data_encoding in
  describe
    ~description:
      "The full list of error is available with \
       the global RPC `/errors`"
    (conv
       (fun exn -> `A (List.map json_of_error exn))
       (function `A exns -> List.map error_of_json exns | _ -> [])
       json)

let wrap_tzerror encoding =
  let open Data_encoding in
  union [
    case (Tag 0)
      (obj1 (req "ok" encoding))
      (function Ok x -> Some x | _ -> None)
      (fun x -> Ok x) ;
    case (Tag 1)
      (obj1 (req "error" error_encoding))
      (function Error x -> Some x | _ -> None)
      (fun x -> Error x) ;
  ]


let operations custom_root =
  RPC_service.post_service
    ~description: "All the operations of the block (fully decoded)."
    ~query: RPC_query.empty
    ~input: empty
    ~output: (wrap_tzerror @@
              (list (list (dynamic_size Operation.encoding))))
    ~error: Data_encoding.empty
    RPC_path.(custom_root / "operations")

let header custom_root =
  RPC_service.post_service
    ~description: "The header of the block (fully decoded)."
    ~query: RPC_query.empty
    ~input: empty
    ~output: (wrap_tzerror Block_header.encoding)
    ~error: Data_encoding.empty
    RPC_path.(custom_root / "header")

module Header = struct

  let priority custom_root =
    RPC_service.post_service
      ~description: "Baking priority of the block."
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror uint16)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "header" / "priority")

  let seed_nonce_hash custom_root =
    RPC_service.post_service
      ~description: "Hash of the seed nonce of the block."
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror Nonce_hash.encoding)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "header" / "seed_nonce_hash")

end

module Constants = struct

  let cycle_length custom_root =
    RPC_service.post_service
      ~description: "Cycle length"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "cycle length" int32)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "cycle_length")

  let voting_period_length custom_root =
    RPC_service.post_service
      ~description: "Length of the voting period"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "voting period length" int32)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "voting_period_length")

  let time_before_reward custom_root =
    RPC_service.post_service
      ~description: "Time before reward"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "time before reward" Period.encoding)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "time_before_reward")

  let slot_durations custom_root =
    RPC_service.post_service
      ~description: "Slot durations"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "time between slots" (list Period.encoding))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "time_between_slots")

  let first_free_baking_slot custom_root =
    RPC_service.post_service
      ~description: "First free baking slot"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "first free baking slot" uint16)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "first_free_baking_slot")

  let max_signing_slot custom_root =
    RPC_service.post_service
      ~description: "Max signing slot"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "max signing slot" uint16)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "max_signing_slot")

  let max_gas custom_root =
    RPC_service.post_service
      ~description: "Instructions per transaction"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "instructions per transaction" int31)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "max_gas")

  let proof_of_work_threshold custom_root =
    RPC_service.post_service
      ~description: "Stamp threshold"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "proof_of_work threshold" int64)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "proof_of_work_threshold")

  let errors custom_root =
    RPC_service.post_service
      ~description: "Schema for all the RPC errors from this protocol version"
      ~query: RPC_query.empty
      ~input: empty
      ~output: json_schema
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "constants" / "errors")

end

module Context = struct

  let level custom_root =
    RPC_service.post_service
      ~description: "Detailled level information for the current block"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "detailled level info" Level.encoding)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "context" / "level")

  let next_level custom_root =
    RPC_service.post_service
      ~description: "Detailled level information for the next block"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "detailled level info" Level.encoding)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "context" / "next_level")

  let roll_value custom_root =
    RPC_service.post_service
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror Tez.encoding)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "context" / "roll_value")

  let next_roll custom_root =
    RPC_service.post_service
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror int32)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "context" / "next_roll")

  let voting_period_kind custom_root =
    RPC_service.post_service
      ~description: "Voting period kind for the current block"
      ~query: RPC_query.empty
      ~input: empty
      ~output:
        (wrap_tzerror @@
         (obj1
            (req "voting_period_kind" Voting_period.kind_encoding)))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "context" / "voting_period_kind")


  module Nonce = struct

    type nonce_info =
      | Revealed of Nonce.t
      | Missing of Nonce_hash.t
      | Forgotten

    let nonce_encoding =
      union [
        case (Tag 0)
          (obj1 (req "nonce" Nonce.encoding))
          (function Revealed nonce -> Some nonce | _ -> None)
          (fun nonce -> Revealed nonce) ;
        case (Tag 1)
          (obj1 (req "hash" Nonce_hash.encoding))
          (function Missing nonce -> Some nonce | _ -> None)
          (fun nonce -> Missing nonce) ;
        case (Tag 2)
          empty
          (function Forgotten -> Some () | _ -> None)
          (fun () -> Forgotten) ;
      ]

    let get custom_root =
      RPC_service.post_service
        ~description: "Info about the nonce of a previous block."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror nonce_encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "nonce" /: Raw_level.arg)

    let hash custom_root =
      RPC_service.post_service
        ~description: "Hash of the current block's nonce."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@
                  describe ~title: "nonce hash" Nonce_hash.encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "nonce")

  end

  module Key = struct

    let public_key_hash_arg = Ed25519.Public_key_hash.rpc_arg

    let pk_encoding =
      (obj2
         (req "hash" Ed25519.Public_key_hash.encoding)
         (req "public_key" Ed25519.Public_key.encoding))

    let list custom_root =
      RPC_service.post_service
        ~description: "List the known public keys"
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@ list pk_encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "keys")

    let get custom_root =
      RPC_service.post_service
        ~description: "Fetch the stored public key"
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@ pk_encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "keys" /: public_key_hash_arg )

  end

  (*-- Contracts ---------------------------------------------------------------*)

  module Contract = struct

    let balance custom_root =
      RPC_service.post_service
        ~description: "Access the balance of a contract."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror Tez.encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "balance")

    let manager custom_root =
      RPC_service.post_service
        ~description: "Access the manager of a contract."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror Ed25519.Public_key_hash.encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "manager")

    let delegate custom_root =
      RPC_service.post_service
        ~description: "Access the delegate of a contract, if any."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror (option Ed25519.Public_key_hash.encoding))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "delegate")

    let counter custom_root =
      RPC_service.post_service
        ~description: "Access the counter of a contract, if any."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror int32)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "counter")

    let spendable custom_root =
      RPC_service.post_service
        ~description: "Tells if the contract tokens can be spent by the manager."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror bool)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "spendable")

    let delegatable custom_root =
      RPC_service.post_service
        ~description: "Tells if the contract delegate can be changed."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror bool)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "delegatable")

    let script custom_root =
      RPC_service.post_service
        ~description: "Access the code and data of the contract."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror (option Script.encoding))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "script")

    let storage custom_root =
      RPC_service.post_service
        ~description: "Access the data of the contract."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror (option Script.expr_encoding))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg / "storage")

    type info = {
      manager: public_key_hash ;
      balance: Tez.t ;
      spendable: bool ;
      delegate: bool * public_key_hash option ;
      script: Script.t option ;
      counter: int32 ;
    }

    let get custom_root =
      RPC_service.post_service
        ~description: "Access the complete status of a contract."
        ~query: RPC_query.empty
        ~input: empty
        ~output:
          (wrap_tzerror @@
           conv
             (fun {manager;balance;spendable;delegate;script;counter} ->
                (manager,balance,spendable,delegate,script,counter))
             (fun (manager,balance,spendable,delegate,script,counter) ->
                {manager;balance;spendable;delegate;script;counter}) @@
           obj6
             (req "manager" Ed25519.Public_key_hash.encoding)
             (req "balance" Tez.encoding)
             (req "spendable" bool)
             (req "delegate" @@ obj2
                (req "setable" bool)
                (opt "value" Ed25519.Public_key_hash.encoding))
             (opt "script" Script.encoding)
             (req "counter" int32))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts" /: Contract.arg)

    let list custom_root =
      RPC_service.post_service
        ~description:
          "All existing contracts (including non-empty default contracts)."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@ list Contract.encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "context" / "contracts")

  end

end

(*-- Helpers ----------------------------------------------------------------*)

module Helpers = struct

  let minimal_timestamp custom_root =
    RPC_service.post_service
      ~description: "Minimal timestamp for the next block."
      ~query: RPC_query.empty
      ~input: (obj1 (opt "priority" int31))
      ~output: (wrap_tzerror @@
                obj1 (req "timestamp" Timestamp.encoding))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "minimal_timestamp")

  let run_code_input_encoding =
    (obj6
       (req "script" Script.expr_encoding)
       (req "storage" Script.expr_encoding)
       (req "input" Script.expr_encoding)
       (req "amount" Tez.encoding)
       (opt "contract" Contract.encoding)
       (opt "origination_nonce" Contract.origination_nonce_encoding))

  let run_code custom_root =
    RPC_service.post_service
      ~description: "Run a piece of code in the current context"
      ~query: RPC_query.empty
      ~input: run_code_input_encoding
      ~output: (wrap_tzerror
                  (obj2
                     (req "storage" Script.expr_encoding)
                     (req "output" Script.expr_encoding)))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "run_code")

  let apply_operation custom_root =
    RPC_service.post_service
      ~description: "Applies an operation in the current context"
      ~query: RPC_query.empty
      ~input: (obj4
                 (req "pred_block" Block_hash.encoding)
                 (req "operation_hash" Operation_hash.encoding)
                 (req "forged_operation" bytes)
                 (opt "signature" Ed25519.Signature.encoding))
      ~output: (wrap_tzerror
                  (obj1 (req "contracts" (list Contract.encoding))))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "apply_operation")


  let trace_code custom_root =
    RPC_service.post_service
      ~description: "Run a piece of code in the current context, \
                     keeping a trace"
      ~query: RPC_query.empty
      ~input: run_code_input_encoding
      ~output: (wrap_tzerror
                  (obj3
                     (req "storage" Script.expr_encoding)
                     (req "output" Script.expr_encoding)
                     (req "trace"
                        (list @@ obj3
                           (req "location" Script.location_encoding)
                           (req "gas" Gas.encoding)
                           (req "stack" (list (Script.expr_encoding)))))))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "trace_code")

  let typecheck_code custom_root =
    RPC_service.post_service
      ~description: "Typecheck a piece of code in the current context"
      ~query: RPC_query.empty
      ~input: Script.expr_encoding
      ~output: (wrap_tzerror Script_ir_translator.type_map_enc)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "typecheck_code")

  let typecheck_data custom_root =
    RPC_service.post_service
      ~description: "Check that some data expression is well formed \
                     and of a given type in the current context"
      ~query: RPC_query.empty
      ~input: (obj2
                 (req "data" Script.expr_encoding)
                 (req "type" Script.expr_encoding))
      ~output: (wrap_tzerror empty)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "typecheck_data")

  let hash_data custom_root =
    RPC_service.post_service
      ~description: "Computes the hash of some data expression \
                     using the same algorithm as script instruction H"
      ~query: RPC_query.empty
      ~input: (obj2 (req "data" Script.expr_encoding)
                 (req "type" Script.expr_encoding))
      ~output: (wrap_tzerror @@
                obj1 (req "hash" string))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "hash_data")

  let level custom_root =
    RPC_service.post_service
      ~description: "..."
      ~query: RPC_query.empty
      ~input: (obj1
                 (opt "offset" int32))
      ~output: (wrap_tzerror @@
                describe ~title: "block level and cycle information" Level.encoding)
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "level" /: Raw_level.arg)

  let levels custom_root =
    RPC_service.post_service
      ~description: "Levels of a cycle"
      ~query: RPC_query.empty
      ~input: empty
      ~output: (wrap_tzerror @@
                describe ~title: "levels of a cycle"
                  (obj2
                     (req "first" Raw_level.encoding)
                     (req "last" Raw_level.encoding)))
      ~error: Data_encoding.empty
      RPC_path.(custom_root / "helpers" / "levels" /: Cycle.arg)

  module Rights = struct

    let slots_range_encoding =
      (obj3
         (opt "max_priority" int31)
         (opt "first_level" Raw_level.encoding)
         (opt "last_level" Raw_level.encoding))

    let endorsement_slot_encoding =
      (obj2
         (req "level" Raw_level.encoding)
         (req "priority" int31))

    let baking_slot_encoding =
      (obj3
         (req "level" Raw_level.encoding)
         (req "priority" int31)
         (req "timestamp" Timestamp.encoding))

    let baking_rights custom_root =
      RPC_service.post_service
        ~description:
          "List gelegates allowed to bake for the next level, \
           ordered by priority."
        ~query: RPC_query.empty
        ~input: (obj1 (opt "max_priority" int31))
        ~output: (wrap_tzerror @@
                  obj2
                    (req "level" Raw_level.encoding)
                    (req "baking_rights"
                       (list
                          (obj2
                             (req "delegate" Ed25519.Public_key_hash.encoding)
                             (req "timestamp" Timestamp.encoding)))))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights" / "baking")

    let baking_rights_for_level custom_root =
      RPC_service.post_service
        ~description:
          "List delegate allowed to bake for a given level, \
           ordered by priority."
        ~query: RPC_query.empty
        ~input: (obj1 (opt "max_priority" int31))
        ~output: (wrap_tzerror @@
                  obj2
                    (req "level" Raw_level.encoding)
                    (req "delegates"
                       (list Ed25519.Public_key_hash.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "baking" / "level" /: Raw_level.arg )

    let baking_levels custom_root =
      RPC_service.post_service
        ~description:
          "List level for which we might computed baking rights."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@
                  obj1 (req "levels" (list Raw_level.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "baking" / "level"  )

    let baking_rights_for_delegate custom_root =
      RPC_service.post_service
        ~description: "Future baking rights for a given delegate."
        ~query: RPC_query.empty
        ~input: slots_range_encoding
        ~output: (wrap_tzerror (Data_encoding.list baking_slot_encoding))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "baking" / "delegate" /: Context.Key.public_key_hash_arg )

    let baking_delegates custom_root =
      RPC_service.post_service
        ~description:
          "List delegates with baking rights."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@
                  obj1 (req "delegates"
                          (list Ed25519.Public_key_hash.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "baking" / "delegate"  )

    let endorsement_rights custom_root =
      RPC_service.post_service
        ~description:
          "List delegates allowed to endorse for the current block."
        ~query: RPC_query.empty
        ~input: (obj1 (opt "max_priority" int31))
        ~output: (wrap_tzerror @@
                  obj2
                    (req "level" Raw_level.encoding)
                    (req "delegates"
                       (list Ed25519.Public_key_hash.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights" / "endorsement")

    let endorsement_rights_for_level custom_root =
      RPC_service.post_service
        ~description:
          "List delegates allowed to endorse blocks for a given level."
        ~query: RPC_query.empty
        ~input: (obj1 (opt "max_priority" int31))
        ~output: (wrap_tzerror @@
                  obj2
                    (req "level" Raw_level.encoding)
                    (req "delegates"
                       (list Ed25519.Public_key_hash.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "endorsement" / "level" /: Raw_level.arg )

    let endorsement_levels custom_root =
      RPC_service.post_service
        ~description:
          "List level for which we might computed endorsement rights."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@
                  obj1 (req "levels" (list Raw_level.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "endorsement" / "level"  )

    let endorsement_rights_for_delegate custom_root =
      RPC_service.post_service
        ~description: "Compute endorsement rights for a given delegate."
        ~query: RPC_query.empty
        ~input: slots_range_encoding
        ~output: (wrap_tzerror @@ Data_encoding.list endorsement_slot_encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "endorsement" / "delegate" /: Context.Key.public_key_hash_arg )

    let endorsement_delegates custom_root =
      RPC_service.post_service
        ~description:
          "List delegates with endorsement rights."
        ~query: RPC_query.empty
        ~input: empty
        ~output: (wrap_tzerror @@
                  obj1 (req "delegates"
                          (list Ed25519.Public_key_hash.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "rights"
                  / "endorsement" / "delegate"  )

  end

  module Forge = struct

    let operations custom_root =
      RPC_service.post_service
        ~description:"Forge an operation"
        ~query: RPC_query.empty
        ~input: Operation.unsigned_operation_encoding
        ~output:
          (wrap_tzerror @@
           (obj1
              (req "operation" @@
               describe ~title: "hex encoded operation" bytes)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "forge" / "operations" )

    let empty_proof_of_work_nonce =
      MBytes.of_string
        (String.make Constants_repr.proof_of_work_nonce_size  '\000')

    let block_proto_header custom_root =
      RPC_service.post_service
        ~description: "Forge the protocol-specific part of a block header"
        ~query: RPC_query.empty
        ~input:
          (obj3
             (req "priority" uint16)
             (req "nonce_hash" Nonce_hash.encoding)
             (dft "proof_of_work_nonce"
                (Fixed.bytes
                   Tezos_context.Constants.proof_of_work_nonce_size)
                empty_proof_of_work_nonce))
        ~output: (wrap_tzerror bytes)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "forge" / "block_proto_header")

  end

  module Parse = struct

    let operations custom_root =
      RPC_service.post_service
        ~description:"Parse operations"
        ~query: RPC_query.empty
        ~input:
          (obj2
             (req "operations" (list (dynamic_size Operation.raw_encoding)))
             (opt "check_signature" bool))
        ~output:
          (wrap_tzerror (list (dynamic_size Operation.encoding)))
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "parse" / "operations" )

    let block custom_root =
      RPC_service.post_service
        ~description:"Parse a block"
        ~query: RPC_query.empty
        ~input: Block_header.raw_encoding
        ~output: (wrap_tzerror Block_header.proto_header_encoding)
        ~error: Data_encoding.empty
        RPC_path.(custom_root / "helpers" / "parse" / "block" )

  end

end
