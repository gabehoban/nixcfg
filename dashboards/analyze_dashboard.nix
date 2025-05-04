{ pkgs ? import <nixpkgs> {} }:

pkgs.writeScriptBin "analyze-dashboard" ''
  #!${pkgs.stdenv.shell}

  echo "Analyzing dashboard for regex issues..."

  # Use jq to find all expr fields
  ${pkgs.jq}/bin/jq -r '.. | .expr? // empty' ${./mikrotik-wan-lan-analysis-v3.json} | while read -r expr; do
    echo "Expression: $expr"
    if echo "$expr" | grep -q '(?!'; then
      echo "  *** FOUND NEGATIVE LOOKAHEAD! ***"
    fi
    echo "----------------------------------------"
  done
''
