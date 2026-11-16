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

(** {2 Names of downloaded files chosen by the server}

    The xe client writes a downloaded file only if its name appears on its
    command line, or if [is_server_filename_accepted] accepts it. *)

val is_valid_hostname : string -> bool
(** [is_valid_hostname s] holds if [s] is made of ASCII letters, digits, '-'
    and '.', does not start or end with '-', and is 1 to 64 characters long. *)

(** A time in UTC, as written in the names of system status reports *)
type utc_time = {
    year: int
  ; month: int
  ; day: int
  ; hour: int
  ; minute: int
  ; second: int
}

val system_status_timestamp : utc_time -> string
(** [system_status_timestamp t] writes [t] in the ISO 8601 basic format,
    for instance 20261110T163518Z. *)

val is_server_filename_accepted : command:string -> string -> bool
(** [is_server_filename_accepted ~command name] holds if the xe client may
    write a file called [name], chosen by the server, while running
    [command]. For host-get-system-status, [name] must be of the form
    system_status-<timestamp>-<hostname>.<tar|tar.bz2|zip>, with the
    timestamp written by [system_status_timestamp] and a host name accepted
    by [is_valid_hostname]. Such a name contains no '/' and does not start
    with a dot. *)
