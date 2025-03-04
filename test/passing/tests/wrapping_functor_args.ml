(* This declaration looks odd *)
type request_token =
  Sociaml_oauth_client.Client.Make(Sociaml_oauth_client.Posix.Clock)
    (Sociaml_oauth_client.Posix.MAC_SHA1)
    (Sociaml_oauth_client.Posix.Random)
  .request_token

(* Whereas this one works well *)
module OauthClient =
  Sociaml_oauth_client.Client.Make
    (Sociaml_oauth_client.Posix.Clock)
    (Sociaml_oauth_client.Posix.MAC_SHA1)
    (Sociaml_oauth_client.Posix.Random)

module F1
    (G : functor (_ : T) -> T)
    (A : sig
      val x : int
    end) =
struct end

module F2
    (G : functor
      (_ : T)
      ->
      T_________________________________________________________________________)
    (A : sig
      val x : int
    end) =
struct end

module F3
    (G : functor
      (_ : T____________________________________________)
      (_ : T____________________________________________)
      -> T)
    (A : sig
      val x : int
    end) =
struct end

module F (* test *) (M : sig
  type t
end) : S = struct end
