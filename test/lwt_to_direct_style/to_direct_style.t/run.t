  $ chmod -R a+w lib
  $ dune build @ocaml-index
  $ find _build -name '*.ocaml-index'
  _build/default/lib/.test.objs/cctx.ocaml-index
  _build/default/bin/.main.eobjs/cctx.ocaml-index

  $ lwt-to-direct-style
  Warning: 3 occurrences have not been rewritten.
    "let*" (bin/main.ml[4,31+2]..[4,31+6])
    "Lwt.Syntax" (bin/main.ml[1,0+5]..[1,0+15])
    "let+" (bin/main.ml[5,73+2]..[5,73+6])
  Warning: 26 occurrences have not been rewritten.
    ">>=" (lib/test.ml[26,608+2]..[26,608+5])
    "Lwt.return" (lib/test.ml[22,555+2]..[22,555+12])
    "and*" (lib/test.ml[21,521+2]..[21,521+6])
    "Lwt.try_bind" (lib/test.ml[5,51+2]..[5,51+14])
    "Lwt.bind" (lib/test.ml[7,81+6]..[7,81+14])
    "Lwt.Infix" (lib/test.ml[1,0+5]..[1,0+14])
    "Lwt.return" (lib/test.ml[27,662+40]..[27,662+50])
    "Lwt.return" (lib/test.ml[10,258+14]..[10,258+24])
    "Lwt.map" (lib/test.ml[8,128+10]..[8,128+17])
    ">>=" (lib/test.ml[30,732+29]..[30,732+32])
    "let+" (lib/test.ml[19,477+4]..[19,477+8])
    "Lwt.return" (lib/test.ml[32,840+39]..[32,840+49])
    ">|=" (lib/test.ml[26,608+36]..[26,608+39])
    "Lwt.return" (lib/test.ml[9,185+57]..[9,185+67])
    ">>=" (lib/test.ml[32,840+35]..[32,840+38])
    "Lwt.bind" (lib/test.ml[13,318+2]..[13,318+10])
    ">>=" (lib/test.ml[31,775+52]..[31,775+55])
    "Lwt.join" (lib/test.ml[32,840+2]..[32,840+10])
    "Lwt.map" (lib/test.ml[14,363+24]..[14,363+31])
    "<&>" (lib/test.ml[27,662+2]..[27,662+5])
    ">>=" (lib/test.ml[27,662+26]..[27,662+29])
    "Lwt.both" (lib/test.ml[31,775+2]..[31,775+10])
    "Lwt.Syntax" (lib/test.ml[2,15+5]..[2,15+15])
    "let*" (lib/test.ml[17,428+2]..[17,428+6])
    "Lwt.bind" (lib/test.ml[9,185+16]..[9,185+24])
    "let*" (lib/test.ml[18,441+4]..[18,441+8])
  Formatted 2 files, 0 errors
