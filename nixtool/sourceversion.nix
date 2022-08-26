{ }:

{
  type,
  ...
} @ args:
let
  fromGithub = args.rev;
in
if type == "github" then fromGithub else (throw "source type not supported : " + type)