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

let accepted ?permit_cwd name () =
  assert_filename_permitted ?permit_cwd permitted name

let refused ?permit_cwd name expected () =
  match assert_filename_permitted ?permit_cwd permitted name with
  | () ->
      Alcotest.failf "%s was accepted" name
  | exception Filename_not_permitted msg ->
      Alcotest.(check string) "message" expected msg

let message name =
  Printf.sprintf
    "Blocked upload/download of the file %s, which was requested by the \
     server. The file name was not present on the command line"
    name

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
    , refused "other.tar" (message "other.tar")
    )
  ; ("current directory", `Quick, refused "." (message "."))
  ; ("current directory with permit_cwd", `Quick, accepted ~permit_cwd:true ".")
  ]

let () = Alcotest.run "xe file names" [("Xe_filenames", tests)]
