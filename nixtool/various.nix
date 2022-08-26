{}:

{
  sluggify = x: builtins.replaceStrings
    [ "-----" "----" "---" "--" ]
    [ "-" "-" "-" "-" ]
    (builtins.replaceStrings
      [ " " "'" ]
      [ "-" ""  ]
    x);
}