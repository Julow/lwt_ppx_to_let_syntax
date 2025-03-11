Make a writable directory tree:
  $ cp -r --no-preserve=mode -L src out
  $ cd out

  $ dune build @ocaml-index
  $ find _build -name '*.ocaml-index'
  _build/default/lib/.test.objs/cctx.ocaml-index
  _build/default/bin/.main.eobjs/cctx.ocaml-index

  $ lwt-to-direct-style
  bin/main.ml: (19 occurrences)
    "return" (bin/main.ml[9,150+15]..[9,150+25])
    "return" (bin/main.ml[16,317+45]..[16,317+55])
    "return" (bin/main.ml[19,410+24]..[19,410+34])
    "return" (bin/main.ml[20,475+14]..[20,475+24])
    "return_unit" (bin/main.ml[19,410+48]..[19,410+63])
    "return_none" (bin/main.ml[16,317+28]..[16,317+43])
    "return_none" (bin/main.ml[24,538+8]..[24,538+23])
    "return_nil" (bin/main.ml[25,562+8]..[25,562+22])
    "return_true" (bin/main.ml[26,585+8]..[26,585+23])
    "return_false" (bin/main.ml[27,609+8]..[27,609+24])
    "return_ok" (bin/main.ml[28,634+8]..[28,634+21])
    "return_error" (bin/main.ml[29,659+8]..[29,659+24])
    "reraise" (bin/main.ml[12,254+15]..[12,254+26])
    "reraise" (bin/main.ml[16,317+56]..[16,317+67])
    "try_bind" (bin/main.ml[4,32+2]..[4,32+14])
    "try_bind" (bin/main.ml[16,317+4]..[16,317+16])
    "try_bind" (bin/main.ml[18,390+2]..[18,390+14])
    "let*" (bin/main.ml[6,62+6]..[6,62+10])
    "let+" (bin/main.ml[7,108+6]..[7,108+10])
  lib/test.ml: (92 occurrences)
    "wakeup" (lib/test.ml[124,3241+2]..[124,3241+12])
    "wakeup_later" (lib/test.ml[125,3260+2]..[125,3260+18])
    "return" (lib/test.ml[9,185+57]..[9,185+67])
    "return" (lib/test.ml[10,258+14]..[10,258+24])
    "return" (lib/test.ml[28,713+2]..[28,713+12])
    "return" (lib/test.ml[33,820+40]..[33,820+50])
    "return" (lib/test.ml[40,1030+45]..[40,1030+51])
    "return" (lib/test.ml[41,1087+14]..[41,1087+20])
    "return" (lib/test.ml[48,1260+15]..[48,1260+25])
    "return" (lib/test.ml[60,1582+34]..[60,1582+42])
    "return" (lib/test.ml[70,1832+45]..[70,1832+51])
    "return" (lib/test.ml[71,1889+14]..[71,1889+20])
    "return" (lib/test.ml[88,2290+6]..[88,2290+16])
    "return" (lib/test.ml[90,2308+8]..[90,2308+18])
    "return" (lib/test.ml[94,2359+22]..[94,2359+32])
    "return" (lib/test.ml[94,2359+37]..[94,2359+47])
    "return" (lib/test.ml[95,2415+25]..[95,2415+35])
    "return" (lib/test.ml[111,2902+8]..[111,2902+18])
    "return" (lib/test.ml[117,3039+19]..[117,3039+29])
    "fail" (lib/test.ml[109,2841+8]..[109,2841+16])
    "fail_with" (lib/test.ml[110,2868+8]..[110,2868+21])
    "fail_invalid_arg" (lib/test.ml[118,3074+32]..[118,3074+52])
    "wait" (lib/test.ml[122,3186+13]..[122,3186+21])
    "bind" (lib/test.ml[7,81+6]..[7,81+14])
    "bind" (lib/test.ml[9,185+16]..[9,185+24])
    "bind" (lib/test.ml[13,318+2]..[13,318+10])
    "bind" (lib/test.ml[39,951+15]..[39,951+19])
    "bind" (lib/test.ml[40,1030+16]..[40,1030+20])
    "bind" (lib/test.ml[45,1166+10]..[45,1166+18])
    "bind" (lib/test.ml[69,1753+15]..[69,1753+19])
    "bind" (lib/test.ml[70,1832+16]..[70,1832+20])
    "map" (lib/test.ml[8,128+10]..[8,128+17])
    "map" (lib/test.ml[14,363+24]..[14,363+31])
    "map" (lib/test.ml[39,951+44]..[39,951+47])
    "map" (lib/test.ml[69,1753+44]..[69,1753+47])
    "catch" (lib/test.ml[101,2523+11]..[101,2523+20])
    "catch" (lib/test.ml[102,2574+11]..[102,2574+20])
    "catch" (lib/test.ml[103,2618+11]..[103,2618+20])
    "catch" (lib/test.ml[104,2675+11]..[104,2675+20])
    "catch" (lib/test.ml[105,2725+11]..[105,2725+20])
    "catch" (lib/test.ml[106,2798+11]..[106,2798+20])
    "try_bind" (lib/test.ml[5,51+2]..[5,51+14])
    "try_bind" (lib/test.ml[38,940+2]..[38,940+10])
    "try_bind" (lib/test.ml[44,1139+11]..[44,1139+23])
    "try_bind" (lib/test.ml[68,1742+2]..[68,1742+10])
    "finalize" (lib/test.ml[118,3074+8]..[118,3074+20])
    "async" (lib/test.ml[119,3145+8]..[119,3145+17])
    "async" (lib/test.ml[123,3214+2]..[123,3214+11])
    "join" (lib/test.ml[79,2128+2]..[79,2128+10])
    "join" (lib/test.ml[116,3013+8]..[116,3013+16])
    "join" (lib/test.ml[117,3039+8]..[117,3039+16])
    "both" (lib/test.ml[75,1972+2]..[75,1972+10])
    "both" (lib/test.ml[77,2096+3]..[77,2096+11])
    "choose" (lib/test.ml[115,2985+8]..[115,2985+18])
    "pick" (lib/test.ml[94,2359+11]..[94,2359+19])
    "pick" (lib/test.ml[95,2415+11]..[95,2415+19])
    "pick" (lib/test.ml[96,2462+11]..[96,2462+19])
    "pause" (lib/test.ml[114,2964+8]..[114,2964+17])
    ">>=" (lib/test.ml[32,766+2]..[32,766+5])
    ">>=" (lib/test.ml[33,820+26]..[33,820+29])
    ">>=" (lib/test.ml[59,1534+2]..[59,1534+5])
    ">>=" (lib/test.ml[60,1582+20]..[60,1582+23])
    ">>=" (lib/test.ml[74,1929+29]..[74,1929+32])
    ">>=" (lib/test.ml[75,1972+52]..[75,1972+55])
    ">>=" (lib/test.ml[78,2113+2]..[78,2113+5])
    ">>=" (lib/test.ml[88,2290+2]..[88,2290+5])
    "=<<" (lib/test.ml[111,2902+19]..[111,2902+22])
    ">|=" (lib/test.ml[32,766+36]..[32,766+39])
    ">|=" (lib/test.ml[46,1188+15]..[46,1188+32])
    ">|=" (lib/test.ml[59,1534+30]..[59,1534+33])
    "=|<" (lib/test.ml[112,2927+15]..[112,2927+18])
    "<&>" (lib/test.ml[33,820+2]..[33,820+5])
    "<&>" (lib/test.ml[60,1582+2]..[60,1582+5])
    "<?>" (lib/test.ml[113,2948+10]..[113,2948+13])
    "let*" (lib/test.ml[17,428+2]..[17,428+6])
    "let*" (lib/test.ml[18,441+4]..[18,441+8])
    "let*" (lib/test.ml[22,555+2]..[22,555+6])
    "let*" (lib/test.ml[23,568+4]..[23,568+8])
    "let*" (lib/test.ml[94,2359+2]..[94,2359+6])
    "let*" (lib/test.ml[95,2415+2]..[95,2415+6])
    "let*" (lib/test.ml[96,2462+2]..[96,2462+6])
    "let*" (lib/test.ml[101,2523+2]..[101,2523+6])
    "let*" (lib/test.ml[102,2574+2]..[102,2574+6])
    "let*" (lib/test.ml[103,2618+2]..[103,2618+6])
    "let*" (lib/test.ml[104,2675+2]..[104,2675+6])
    "let*" (lib/test.ml[105,2725+2]..[105,2725+6])
    "let*" (lib/test.ml[106,2798+2]..[106,2798+6])
    "and*" (lib/test.ml[21,521+2]..[21,521+6])
    "and*" (lib/test.ml[26,648+2]..[26,648+6])
    "and*" (lib/test.ml[27,679+2]..[27,679+6])
    "let+" (lib/test.ml[19,477+4]..[19,477+8])
    "let+" (lib/test.ml[24,604+4]..[24,604+8])

  $ lwt-to-direct-style --migrate
  Warning: 2 occurrences have not been rewritten.
    <?> (lib/test.ml[113,2948+10]..[113,2948+13])
    choose (lib/test.ml[115,2985+8]..[115,2985+18])
  Formatted 2 files, 0 errors

  $ cat bin/main.ml
  open Lwt.Syntax
  
  let _main () =
    match
      let () = Lwt_fmt.printf "Main.main" in
      let () = Test.test () in
      ()
    with
    | () -> ()
    | exception Failure msg -> Lwt_fmt.printf "Failure: %s\n%!" msg
  
  let main () =
    let main () = match None with v -> v in
    match main () with Some _ -> () | None -> () | exception _ -> ()
  
  let () = Lwt_main.run (main ())
  let _ = None
  let _ = []
  let _ = true
  let _ = false
  let _ = Ok ()
  let _ = Error ()

  $ cat lib/test.ml
  open Eio
  open Lwt.Infix
  open Lwt.Syntax
  
  let lwt_calls () =
    match
      let () = Lwt_fmt.printf "1" in
      let () = Lwt_fmt.printf "2" in
      `Ok
    with
    | `Ok ->
        let () = Lwt_fmt.printf "3" in
        ()
    | exception _ -> ()
  
  let lwt_calls_point_free () =
    let () = Lwt_fmt.printf "1" in
    let () = Lwt_fmt.printf "2" in
    ()
  
  let letops () =
    let (), `Ok =
      Fiber.pair (Lwt_fmt.printf "3")
        (let () = Lwt_fmt.printf "1" in
         let () = Lwt_fmt.printf "2" in
         `Ok)
    in
    let (), ((), `Ok) =
      Fiber.pair (Lwt_fmt.printf "6")
        (Fiber.pair (Lwt_fmt.printf "7")
           (let () = Lwt_fmt.printf "4" in
            let () = Lwt_fmt.printf "5" in
            `Ok))
    in
    ()
  
  let infix () =
    Fiber.pair
      (fun () ->
        let () =
          Lwt_fmt.printf
            (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
            "1"
        in
        let () = Lwt_fmt.printf "2" in
        ())
      (fun () ->
        let () =
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
          Lwt_fmt.printf "3"
        in
        ())
  
  let lwt_calls_open () =
    let open Lwt in
    let open Lwt_fmt in
    match
      let () = printf "1" in
      let () = printf "2" in
      `Ok
    with
    | `Ok ->
        let () = printf "3" in
        ()
    | exception _ -> ()
  
  let lwt_calls_rebind () =
    let tr = fun x1 x2 x3 -> match x1 () with v -> x2 v | exception v -> x3 v in
    let b = fun x1 x2 -> x2 x1 in
    let ( >> ) = fun x1 x2 -> x2 x1 in
    let p fmt = Lwt_fmt.printf fmt in
    let ( ~@ ) = fun x1 -> x1 in
    tr
      (fun () -> b (p "1") (fun () -> p "2" >> fun () -> `Ok))
      (fun `Ok -> b (p "3") (fun () -> ~@()))
      (fun _ -> ~@())
  
  let lwt_calls_alias () =
    let module L = Lwt in
    let module F = Lwt_fmt in
    let open L.Infix in
    Fiber.pair
      (fun () ->
        let () =
          F.printf
            (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
            "1"
        in
        let () = F.printf "2" in
        ())
      (fun () ->
        let () =
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *)
          F.printf "3"
        in
        ())
  
  let lwt_calls_include () =
    let module L = struct
      include Lwt
      include Lwt_fmt
    end in
    let open L in
    match
      let () = printf "1" in
      let () = printf "2" in
      `Ok
    with
    | `Ok ->
        let () = printf "3" in
        ()
    | exception _ -> ()
  
  let test () =
    let () = Lwt_fmt.printf "Test.test" in
    let _ = Fiber.pair lwt_calls lwt_calls_point_free in
    let _ =
      let a = lwt_calls () and b = lwt_calls_point_free () in
      Fiber.pair
        (fun () ->
          a
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *))
        (fun () ->
          b
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *))
    in
    Fiber.all
      [
        letops;
        infix;
        lwt_calls_open;
        lwt_calls_rebind;
        lwt_calls_alias;
        lwt_calls_include;
      ]
  
  let x = ()
  
  let _ =
    let xs = [ x ] in
    let _ = Fiber.any [ (fun x1 -> x1); (fun x1 -> x1) ] in
    let _ =
      Fiber.any
        [
          (fun () ->
            x
            (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
          (fun x1 -> x1);
          (fun () ->
            x
            (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
        ]
    in
    let _ =
      Fiber.any xs
      (* TODO: lwt-to-direct-style: This expression is a ['a Lwt.t list] but a [(unit -> 'a) list] is expected. *)
    in
    x
  
  let _ =
    let handle _ = x in
    let _ = try x with _ -> x in
    let _ = try x with v -> handle v in
    let _ = try (fun _ : unit Lwt.t -> x) () with v -> handle v in
    let _ = try (function () -> x) () with v -> handle v in
    let _ = try x with Not_found -> x | _ -> x in
    let _ = try handle () with v -> handle v in
    x
  
  let _ = raise Not_found
  let _ = failwith "not found"
  let _ = x
  let _ = Fun.id x
  
  let _ =
    x
    (* TODO: lwt-to-direct-style: [<?>] can't be automatically translated.Use Eio.Promise instead.  *)
    <?> x
  
  let _ = Fiber.yield ()
  
  let _ =
    Lwt.choose
      (* TODO: lwt-to-direct-style: [Lwt.choose] can't be automatically translated.Use Eio.Promise instead.  *)
      (* TODO: lwt-to-direct-style: [Lwt.choose] can't be automatically translated.Use Eio.Promise instead.  *)
      [ x; x ]
  
  let _ =
    Fiber.all
      [
        (fun () ->
          x
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
        (fun () ->
          x
          (* TODO: lwt-to-direct-style: This computation might not be suspended correctly. *));
      ]
  
  let _ = Fiber.all [ (fun x1 -> x1) ]
  let _ = Fun.protect ~finally:(fun () -> x) (fun () -> invalid_arg "")
  
  let _ =
    Fiber.fork ~sw
      (* TODO: lwt-to-direct-style: [sw] must be propagated here. *)
      (fun () -> x)
  
  let _ =
    let t, u
        (* TODO: lwt-to-direct-style: Translation is incomplete, [Promise.await] must be called on the promise when it's part of control-flow. *)
        =
      Promise.create ()
    in
    Fiber.fork ~sw
      (* TODO: lwt-to-direct-style: [sw] must be propagated here. *) (fun () -> t);
    Promise.resolve u ();
    Promise.resolve u ()
