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

let assert_filename_permitted ?(permit_cwd = false) permitted_filenames filename
    =
  let permitted_filenames =
    match permit_cwd with
    | true ->
        Filename.current_dir_name |> canonicalize |> fun x ->
        x :: permitted_filenames
    | _ ->
        permitted_filenames
  in
  let requested_file = canonicalize filename in
  match List.mem requested_file permitted_filenames with
  | false ->
      let error_message =
        Printf.sprintf
          "Blocked upload/download of the file %s, which was requested by the \
           server. The file name was not present on the command line\n"
          filename
      in
      raise (Filename_not_permitted error_message)
  | _ ->
      ()
