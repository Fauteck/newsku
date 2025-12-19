# Using a fixed nix commit for maximum reproducability
{ pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
    config.allowBroken = true;
    config.permittedInsecurePackages = [
                    "gradle-7.6.6"
                  ];
  }
, ci ? false}:

let
 aliases = [
     ];

 dynamicInputs = with pkgs; [
            libepoxy
            fontconfig
];
in
pkgs.mkShell {
  buildInputs = with pkgs; builtins.concatLists [
    [ flutter git http-server

    # flutter desktop
    clang
    cmake
    gtk3
    libepoxy
    ninja
    pkg-config
    mesa-demos

    xorg.libX11.dev
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxkbfile
    xorg.libxshmfence

    ]
  ];

  # What to run when the shell starts
  # clipiousNix.prepareShell is a helper function to sort things properly. It returns a string so it's possible to just concatenate stuff afterwards
  # to run CI or DB migrations
  shellHook =  ''

  echo "Setting up submodules"
  git submodule init
  git submodule update

  echo "Setting up pre-commit hook"
  dart run tools/setup_git_hooks.dart

  "Adding flutter submodule to path"
  export PATH="./submodules/flutter/bin:$PATH"

  echo "creating useful aliases..."


  flutter config --jdk-dir ${pkgs.corretto21}/lib/corretto

  echo -e "\nAll done 🎉 \nAvailable aliases:"


  ''+
          pkgs.lib.concatStrings (map (x: ''echo "${x.name}: ${x.description}";'') aliases);



  ####################################################################
  # Without  this, almost  everything  fails with  locale issues  when
  # using `nix-shell --pure` (at least on NixOS).
  # See
  # + https://github.com/NixOS/nix/issues/318#issuecomment-52986702
  # + http://lists.linuxfromscratch.org/pipermail/lfs-support/2004-June/023900.html
  ####################################################################

  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
  LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath dynamicInputs}";
  DESTDIR="build/install";
}

# vim: set tabstop=2 shiftwidth=2 expandtab:
