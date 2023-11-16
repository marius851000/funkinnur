{ callPackage, fetchFromGitHub, fetchzip }:

{
  type
  , ...
} @ args:

let
  fromGithub = fetchFromGitHub {
    owner = args.owner;
    repo = args.repo;
    rev = args.rev;
    sha256 = args.nixSha;
  };
  fromZipUrl = fetchzip {
    url = args.url;
    sha256 = args.hash;
  };
in
if type == "github" then fromGithub else if type == "urlzip" then fromZipUrl else (throw "source type not supported : " + type)