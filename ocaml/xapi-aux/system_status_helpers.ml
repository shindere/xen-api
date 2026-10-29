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

module Output = struct
  (** The output formats of xen-bugtool *)
  type t = Tar | TarBz2 | Zip

  let of_string = function
    | "tar" ->
        Some Tar
    | "tar.bz2" ->
        Some TarBz2
    | "zip" ->
        Some Zip
    | _ ->
        None

  let to_extension = function
    | Tar ->
        "tar"
    | TarBz2 ->
        "tar.bz2"
    | Zip ->
        "zip"

  let to_mime = function
    | Tar ->
        "application/x-tar"
    | TarBz2 ->
        "application/x-bzip2"
    | Zip ->
        "application/zip"
end

let make_filename ~time ~hostname ~output =
  let timestamp = Ptime.to_rfc3339 ~tz_offset_s:0 time in
  Printf.sprintf "system_status-%s-%s.%s" timestamp hostname
    (Output.to_extension output)
