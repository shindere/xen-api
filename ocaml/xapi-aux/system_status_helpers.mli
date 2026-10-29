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

module Output : sig
  (** The output formats of xen-bugtool *)
  type t = Tar | TarBz2 | Zip

  val of_string : string -> t option

  val to_string : t -> string

  val to_extension : t -> string

  val to_mime : t -> string
end

val make_filename : time:Ptime.t -> hostname:string -> output:Output.t -> string
(** [make_filename ~time ~hostname ~output] is the name under which the system
    status report of host [hostname], requested at [time], is downloaded. The
    time is written in UTC, in the ISO 8601 basic format (20261110T163518Z),
    so that the name contains no colon. *)
