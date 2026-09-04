(*
 * Copyright (C) 2026 Vates.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *)

(* [used] records whether a command has read this parameter. It is mutable and
   the entry records are shared between a structure and the views taken from it
   ({!view}), so marking through a view is visible from the root. Nothing reads
   [used] yet -- the report of ignored parameters is a later commit. *)
type 'a entry = {mutable key: string; value: 'a; mutable used: bool}

(* [scope = Some prefix] restricts the visible entries to those whose key is
   [prefix] followed by at least one more character (any separator, matching the
   historical map-parameter parsing); their keys are seen with that prefix and
   its separator removed. [entries] is shared with the structure the view was
   taken from. *)
type 'a t = {entries: 'a entry list; scope: string option}

(* [bare t e] is [e]'s key as seen through [t] (scope prefix stripped), or [None]
   when [e] is not visible through [t]. *)
let bare t e =
  match t.scope with
  | None ->
      Some e.key
  | Some prefix ->
      let plen = String.length prefix in
      let len = plen + 1 in
      if String.length e.key > len && String.sub e.key 0 plen = prefix then
        Some (String.sub e.key len (String.length e.key - len))
      else
        None

(* The entries visible through [t], each paired with its bare key. *)
let visible t =
  List.filter_map (fun e -> Option.map (fun k -> (k, e)) (bare t e)) t.entries

let mark e = e.used <- true

let from_pairs pairs =
  {
    entries= List.map (fun (key, value) -> {key; value; used= false}) pairs
  ; scope= None
  }

let to_pairs t = List.map (fun (k, e) -> (k, e.value)) (visible t)

let view prefix t = {t with scope= Some prefix}

let reserved =
  [
    "server"
  ; "username"
  ; "password"
  ; "port"
  ; "minimal"
  ; "all"
  ; "report-ignored-params"
  ]

let is_reserved arg = List.mem arg reserved

let get key t =
  match List.find_opt (fun (k, _) -> k = key) (visible t) with
  | Some (_, e) ->
      mark e ; e.value
  | None ->
      raise Not_found

let get_opt key t =
  match List.find_opt (fun (k, _) -> k = key) (visible t) with
  | Some (_, e) ->
      mark e ; Some e.value
  | None ->
      None

let get_default key t default =
  match get_opt key t with None -> default | Some v -> v

let get_all key t =
  List.filter_map
    (fun (k, e) ->
      if k = key then (
        mark e ; Some e.value
      ) else
        None
    )
    (visible t)

let exists key t =
  match List.find_opt (fun (k, _) -> k = key) (visible t) with
  | Some (_, e) ->
      mark e ; true
  | None ->
      false

let keys t = List.map fst (visible t)

(* Mark every visible entry of [t] as read. For call sites that take a whole
   (view's) contents wholesale, e.g. forwarding a map parameter to the API.
   Returns [t] so it can sit in a pipeline before {!to_pairs}. *)
let consume t =
  List.iter (fun (_, e) -> mark e) (visible t) ;
  t

(* The bare keys of the entries visible through [t] that no command has read.
   Not called yet -- the report of ignored parameters is a later commit. *)
let unused t =
  List.filter_map
    (fun (k, e) ->
      if e.used then
        None
      else
        Some k
    )
    (visible t)

(* Mark the entry for [key], if any, as read -- without reading its value. *)
let mark_used key t =
  match List.find_opt (fun (k, _) -> k = key) (visible t) with
  | Some (_, e) ->
      mark e
  | None ->
      ()

(* The helpers below are only ever used on an unscoped structure. *)

(* Rename every entry keyed [from_] to [to_], in place: the entry records are
   shared with the views taken from [t], so the rename is seen everywhere,
   including a report computed on the structure this one was derived from. *)
let rename_key ~from_ ~to_ t =
  List.iter (fun e -> if e.key = from_ then e.key <- to_) t.entries

let add key value t = {t with entries= {key; value; used= false} :: t.entries}

let remove key t =
  let rec go = function
    | [] ->
        []
    | e :: rest ->
        if e.key = key then
          rest
        else
          e :: go rest
  in
  {t with entries= go t.entries}

let filter pred t =
  {t with entries= List.filter (fun e -> pred e.key) t.entries}

let filter_out pred t =
  {t with entries= List.filter (fun e -> not (pred e.key)) t.entries}
