{ callPackage, fetchFromGitHub }:

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
in
if type == "github" then fromGithub else (throw "source type not supported : " + type)