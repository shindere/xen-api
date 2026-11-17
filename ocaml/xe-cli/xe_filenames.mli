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

(** Checks of the names of the files that the server asks xe to read or
    write. The server is not trusted: xe only reads or writes a file whose
    name appears on its command line. *)

val get_permit_filenames : string list -> Fpath.t list
(** [get_permit_filenames args] is the list of the values of the [key=value]
    arguments of the command line, as canonical paths: the names of the files
    that the server may ask xe to read or write. *)

exception Filename_not_permitted of string

val assert_filename_permitted :
  ?permit_cwd:bool -> Fpath.t list -> string -> unit
(** [assert_filename_permitted ?permit_cwd permitted filename] raises
    [Filename_not_permitted] unless [filename] is one of [permitted], or the
    current directory if [permit_cwd] is true. *)
