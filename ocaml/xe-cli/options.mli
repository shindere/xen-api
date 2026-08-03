(* Copyright (C) 2026 Vates.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published
   by the Free Software Foundation; version 2.1 only. with the special
   exception on linking described in file LICENSE.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.
*)

val read_rc : unit -> (string * string) list
(** Read configuration from $HOME/.xe
    In the configuration file, blank lines are ignored but comments
    are not supported. All the non-blank lines are expected to be
    of the form:
    key=value
    Any non-blank line that does not contain an equal sign causes
    the parsing to stop and no configuration will be returned,
    not even for the already parsed lines.
    The same holds if the file cannot be found or read.
    The configuration is returned as a list of (key, value) pairs.
    No check of any kind on the keys or values is performed at this stage.
    Currently, if $HOME is empty or not defined, "/.xe" is being read.
    *)
