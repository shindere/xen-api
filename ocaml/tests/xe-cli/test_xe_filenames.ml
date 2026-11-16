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

open Xe_filenames

let permitted = get_permit_filenames ["filename=report.tar"; "uuid=1234"]

let accepted name () = assert_filename_permitted permitted name

let refused name expected () =
  match assert_filename_permitted permitted name with
  | () ->
      Alcotest.failf "%s was accepted" name
  | exception Filename_not_permitted msg ->
      Alcotest.(check string) "message" expected msg

let upload_message name =
  Printf.sprintf
    "Blocked upload of the file %s, which was requested by the server. The \
     file name was not present on the command line"
    name

let download_message name =
  Printf.sprintf
    "Blocked download of the file %s, which was requested by the server. The \
     file name was not present on the command line, and is not one that xe \
     accepts from the server for this command"
    name

let command = "host-get-system-status"

let report = "system_status-20261110T163518Z-host1.tar"

let download_accepted ~command name () =
  assert_download_filename_permitted ~command permitted name

let download_refused ~command name () =
  match assert_download_filename_permitted ~command permitted name with
  | () ->
      Alcotest.failf "%s was accepted" name
  | exception Filename_not_permitted msg ->
      Alcotest.(check string) "message" (download_message name) msg

let command_line () =
  Alcotest.(check int)
    "values of key=value arguments, empty values left out" 2
    (List.length
       (get_permit_filenames
          ["filename=report.tar"; "uuid=1234"; "output="; "--multiple"]
       )
    )

let tests =
  [
    ("values of the command line", `Quick, command_line)
  ; ("name on the command line", `Quick, accepted "report.tar")
  ; ("same file, other spelling", `Quick, accepted "./report.tar")
  ; ( "same file, absolute path"
    , `Quick
    , accepted (Filename.concat (Sys.getcwd ()) "report.tar")
    )
  ; ("any value of the command line", `Quick, accepted "1234")
  ; ( "name absent from the command line"
    , `Quick
    , refused "other.tar" (upload_message "other.tar")
    )
  ; ("current directory", `Quick, refused "." (upload_message "."))
  ; ( "download, name on the command line"
    , `Quick
    , download_accepted ~command "report.tar"
    )
  ; ( "download, name chosen by the server"
    , `Quick
    , download_accepted ~command report
    )
  ; ( "download, name chosen by the server for another command"
    , `Quick
    , download_refused ~command:"vm-export" report
    )
  ; ( "download, other name chosen by the server"
    , `Quick
    , download_refused ~command "other.tar"
    )
  ]

let () = Alcotest.run "xe file names" [("Xe_filenames", tests)]
