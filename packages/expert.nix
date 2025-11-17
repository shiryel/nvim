{ config, ... }:

with config.nix-neovim.pkgs;

let
  beam = beam26Packages;
  erlang = beam.erlang;
  burritoTarget =
    {
      "aarch64-darwin" = "darwin_arm64";
      "x86_64-darwin" = "darwin_amd64";
      "aarch64-linux" = "linux_arm64";
      "x86_64-linux" = "linux_amd64";
    }."${system}" or (throw "Unsupported system: ${system}");
in
beam.mixRelease rec {
  pname = "expert";
  version = "git";

  src = fetchFromGitHub {
    owner = "elixir-lang";
    repo = "expert";
    rev = "583ee15fe361f892b51cbed823afc3fc61a9ed3f";
    hash = "sha256-VwsGOWMzgh+TUq0NJ7a74c6n3qsjWxTwFafuVH2AQx0=";
    fetchSubmodules = true;
    fetchLFS = true;
  };

  mixFodDeps = beam.fetchMixDeps {
    inherit pname;
    inherit version;
    inherit src;
    sha256 = "sha256-RIzkbQqOl9sLaTSigl+4tfxbOx1ikYIg6ZnYAJ62X7w=";
    mixEnv = "prod";
    installPhase = ''
      runHook preInstall
      cd apps/expert; mix deps.get ''${MIX_ENV:+--only $MIX_ENV}; cd -;
      find "$TEMPDIR/deps" -path '*/.git/*' -a ! -name HEAD -exec rm -rf {} +
      cp -r --no-preserve=mode,ownership,timestamps $TEMPDIR/deps $out
      runHook postInstall
    '';
  };

  env.EXPERT_RELEASE_MODE = "burrito";
  env.ZIG_GLOBAL_CACHE_DIR = "$TEMPDIR/zig";

  nativeBuildInputs = [ makeWrapper zig_0_15 xz _7zz ];

  postPatch = ''
    substituteInPlace apps/expert/mix.exs \
      --replace-fail 'cpu: :x86_64' 'cpu: :x86_64, custom_erts: "${erlang}/lib/erlang/"'
    substituteInPlace apps/expert/mix.exs \
      --replace-fail 'cpu: :aarch64' 'cpu: :aarch64, custom_erts: "${erlang}/lib/erlang/"'
  '';

  configurePhase = ''
    runHook preConfigure

    cd apps/expert

    ln -sf ../../deps ../engine/deps
    ln -sf ../../deps ../forge/deps

    mix deps.compile --no-deps-check

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    export BURRITO_TARGET=${burritoTarget}
    mix release --overwrite --path ./release_build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r release_build/* $out/

    if [ -d "burrito_out" ]; then
      mkdir -p $out/burrito_out
      cp -r burrito_out/* $out/burrito_out/
    fi

    find $out -type l -exec test ! -e {} \; -delete

    runHook postInstall
  '';

  preFixup = ''
    # Use Burrito binary if it exists for this system
    if [ -n "expert_${burritoTarget}" ] && [ -f "$out/burrito_out/expert_${burritoTarget}" ]; then
      mkdir -p $out/bin
      cp "$out/burrito_out/expert_${burritoTarget}" "$out/bin/expert"
      chmod +x "$out/bin/expert"
    fi

    # Copy Erlang cookie so distributed mode works
    if [ -f "$out/releases/COOKIE" ]; then
      mkdir -p $out/var
      cp "$out/releases/COOKIE" "$out/var/COOKIE"
      chmod 600 "$out/var/COOKIE"
    fi
  '';
}
