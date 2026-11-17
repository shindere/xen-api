(*
 * Copyright (C) 2006-2009 Citrix Systems Inc.
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

type command =
  | Print of string
  | Debug of string
  | Load of string
  | HttpGet of string * string
  | HttpPut of string * string
  | HttpConnect of string
  | Prompt
  | Exit of int
  | Error of string * string list
  | PrintStderr of string

type response = OK | Wait | Failed

type blob_header = Chunk of int32 | End

type message = Command of command | Response of response | Blob of blob_header

val major : int

val minor : int

val string_of_message : message -> string

val marshal_message : message -> string

(** A string being unmarshalled, and the offset of the next value in it *)
type context = string * int

val unmarshal_message : context -> message * context

val marshal : Unix.file_descr -> message -> unit

exception Unmarshal_failure of exn * string

val unmarshal : Unix.file_descr -> message

val marshal_protocol : Unix.file_descr -> unit

exception Not_a_cli_server

val unmarshal_protocol : Unix.file_descr -> int * int
