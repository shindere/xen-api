open Alcotest
open System_status_helpers

let time =
  match Ptime.of_date_time ((2026, 11, 10), ((16, 35, 18), 0)) with
  | Some t ->
      t
  | None ->
      assert false

let uuid = "0b2b1a2e-7a4c-4b1e-9e55-3c5d8a7f6e21"

let outputs = Output.[Tar; TarBz2; Zip]

let filename () =
  check string __LOC__ "system_status-20261110T163518Z-host1.tar"
    (make_filename ~time ~hostname:"host1" ~uuid ~output:Output.Tar) ;
  check string __LOC__ "system_status-20261110T163518Z-host1.tar.bz2"
    (make_filename ~time ~hostname:"host1" ~uuid ~output:Output.TarBz2) ;
  check string __LOC__ "system_status-20261110T163518Z-host1.zip"
    (make_filename ~time ~hostname:"host1" ~uuid ~output:Output.Zip) ;
  check string __LOC__
    ("system_status-20261110T163518Z-" ^ uuid ^ ".tar")
    (make_filename ~time ~hostname:"host_1" ~uuid ~output:Output.Tar)

(* Every name that xapi gives to a system status report must be accepted by
   the xe client *)
let accepted_by_xe () =
  let hostnames =
    [
      "host1"
    ; "host-1.example.com"
    ; ""
    ; "-host1"
    ; "host_1"
    ; "h\195\180te"
    ; "host/1"
    ; String.make 65 'a'
    ]
  in
  List.iter
    (fun hostname ->
      List.iter
        (fun output ->
          let name = make_filename ~time ~hostname ~uuid ~output in
          check bool name true
            (Cli_protocol.is_server_filename_accepted
               ~command:"host-get-system-status" name
            )
        )
        outputs
    )
    hostnames

let tests =
  [
    test_case "filename" `Quick filename
  ; test_case "accepted by xe" `Quick accepted_by_xe
  ]

let () = run __MODULE__ [(__MODULE__, tests)]
