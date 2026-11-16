open Cli_protocol

let marshal_unmarshal (a : message) =
  let x = marshal_message a in
  let b, (_, offset) = unmarshal_message (x, 0) in
  if a <> b then
    failwith
      (Printf.sprintf "marshal_unmarshal failure: %s <> %s"
         (string_of_message a) (string_of_message b)
      ) ;
  if String.length x <> offset then
    failwith
      (Printf.sprintf
         "Failed to consume all data in marshal_unmarshal %s (length=%d \
          offset=%d)"
         (string_of_message a) (String.length x) offset
      )

let examples =
  [
    Command (Print "Hello there")
  ; Command (Debug "this is debug output")
  ; Command (Load "ova.xml")
  ; Command (HttpGet ("foo.export", "/import"))
  ; Command (HttpPut ("foo.export", "/export"))
  ; Command Prompt
  ; Command (Exit 5)
  ; Response OK
  ; Response Failed
  ; Response Wait
  ; Blob (Chunk 1024l)
  ; Blob (Chunk 10240l)
  ; Blob (Chunk 102400l)
  ; Blob (Chunk 1024000l)
  ; Blob (Chunk 10240000l)
  ; Blob End
  ; Command (Error ("somecode", ["a"; "b"; "c"]))
  ; Command (Error ("another", []))
  ]

let roundtrip_marshaling_tests =
  let test_case case =
    Alcotest.test_case (string_of_message case) `Quick (fun () ->
        marshal_unmarshal case
    )
  in
  List.map test_case examples

let system_status_timestamp =
  let time = {year= 2026; month= 11; day= 10; hour= 6; minute= 5; second= 8} in
  Alcotest.test_case "system status timestamp" `Quick (fun () ->
      Alcotest.(check string)
        "timestamp" "20261110T060508Z"
        (system_status_timestamp time)
  )

let server_filenames =
  let command = "host-get-system-status" in
  let name = "system_status-20261110T163518Z-host1" in
  let accepted =
    [
      ("tar archive", name ^ ".tar")
    ; ("tar.bz2 archive", name ^ ".tar.bz2")
    ; ("zip archive", name ^ ".zip")
    ; ( "host name with '-' and '.'"
      , "system_status-20261110T163518Z-host-1.example.com.tar"
      )
    ; ("one-letter host name", "system_status-20261110T163518Z-H.tar")
    ; ( "host UUID"
      , "system_status-20261110T163518Z-0b2b1a2e-7a4c-4b1e-9e55-3c5d8a7f6e21.zip"
      )
    ; ( "64-character host name"
      , "system_status-20261110T163518Z-" ^ String.make 64 'a' ^ ".tar"
      )
    ]
  in
  let refused =
    [
      ("empty name", "")
    ; ("wrong prefix", "foo.tar")
    ; ("hidden file", ".bashrc")
    ; ("parent directory", "../" ^ name ^ ".tar")
    ; ("subdirectory", "dir/" ^ name ^ ".tar")
    ; ("no extension", name)
    ; ("unknown extension", name ^ ".tgz")
    ; ("empty host name", "system_status-20261110T163518Z-.tar")
    ; ( "host name starting with '-'"
      , "system_status-20261110T163518Z--host1.tar"
      )
    ; ("host name ending with '-'", "system_status-20261110T163518Z-host1-.tar")
    ; ("'_' in host name", "system_status-20261110T163518Z-host_1.tar")
    ; ("'/' in host name", "system_status-20261110T163518Z-host/1.tar")
    ; ("non-ASCII host name", "system_status-20261110T163518Z-h\195\180te.tar")
    ; ( "65-character host name"
      , "system_status-20261110T163518Z-" ^ String.make 65 'a' ^ ".tar"
      )
    ; ("RFC 3339 time", "system_status-2026-11-10T16:35:18Z-host1.tar")
    ; ("time without 'Z'", "system_status-20261110T163518-host1.tar")
    ; ("lowercase 't' and 'z'", "system_status-20261110t163518z-host1.tar")
    ; ("non-digit in date", "system_status-2026111XT163518Z-host1.tar")
    ; ("no '-' after time", "system_status-20261110T163518Zhost1.tar")
    ; ("trailing newline", name ^ ".tar\n")
    ]
  in
  let test_case expected (reason, filename) =
    Alcotest.test_case reason `Quick (fun () ->
        Alcotest.(check bool)
          filename expected
          (is_server_filename_accepted ~command filename)
    )
  in
  let other_command =
    Alcotest.test_case "other command" `Quick (fun () ->
        Alcotest.(check bool)
          "accepted" false
          (is_server_filename_accepted ~command:"vm-list" (name ^ ".tar"))
    )
  in
  List.map (test_case true) accepted
  @ List.map (test_case false) refused
  @ [other_command]

let () =
  Alcotest.run "CLI Protocol"
    [
      ("roundtrip-marshaling", roundtrip_marshaling_tests)
    ; ("system-status-timestamp", [system_status_timestamp])
    ; ("server-filenames", server_filenames)
    ]
