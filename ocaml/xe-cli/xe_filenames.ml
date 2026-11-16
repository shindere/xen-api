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

(* Checks of the names of the files that the server asks xe to read or
   write *)

let canonicalize path =
  let open Fpath in
  match Filename.is_relative path with
  | true ->
      (Sys.getcwd () |> v) // (path |> v) |> normalize
  | false ->
      path |> v |> normalize

let get_permit_filenames args =
  List.filter_map
    (fun arg ->
      match Astring.String.cut ~sep:"=" arg with
      | Some (_, v) -> (
        match String.trim v with "" -> None | _ -> Some (v |> canonicalize)
      )
      | _ ->
          None
    )
    args

exception Filename_not_permitted of string

let is_on_command_line permitted_filenames filename =
  List.mem (canonicalize filename) permitted_filenames

let assert_filename_permitted permitted_filenames filename =
  if not (is_on_command_line permitted_filenames filename) then
    raise
      (Filename_not_permitted
         (Printf.sprintf
            "Blocked upload of the file %s, which was requested by the server. \
             The file name was not present on the command line"
            filename
         )
      )

(* The names under which xe writes a file downloaded from the server *)
let is_download_filename_permitted ~command permitted_filenames filename =
  is_on_command_line permitted_filenames filename
  || Cli_protocol.is_server_filename_accepted ~command filename

let assert_download_filename_permitted ~command permitted_filenames filename =
  if not (is_download_filename_permitted ~command permitted_filenames filename)
  then
    raise
      (Filename_not_permitted
         (Printf.sprintf
            "Blocked download of the file %s, which was requested by the \
             server. The file name was not present on the command line, and is \
             not one that xe accepts from the server for this command"
            filename
         )
      )
