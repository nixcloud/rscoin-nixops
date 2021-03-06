{ pkgs } :

with pkgs; rec {

  serokellPackage = haskellPackagesExtended.mkDerivation {
    pname = "serokell-core";
    version = "0.1.0.0";
    src = pkgs.fetchgit {
      url = "https://github.com/serokell/serokell-core.git";
      rev = "db7cde4e096eb6b4167b16b90aea0767895481ca";
      sha256 = "0iqm3im90rpf2rfw897qpzkfal9jxyqiqh02v6ysc21072hi93ns";
    };

    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    libraryHaskellDepends = with haskellPackagesExtended; [
       acid-state base64-bytestring either lens optparse-applicative time-units
       either aeson clock formatting
    ];
    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  msgpackGIT = pkgs.fetchgit {
    url = "https://github.com/serokell/msgpack-haskell.git";
    rev = "ec26163035b049bfeff09444a7142a6ce7332493";
    sha256 = "0968icqkzizlvnylgzaqbyz114j866ccklcx464n8vf3k8haza9g";
  };

  msgpackPackage = haskellPackagesExtended.mkDerivation {
    pname = "msgpack";
    version = "1.0.0";
    src = msgpackGIT;
    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    # HACK best workaround ever
    patchPhase = ''
      mv msgpack .msgpack
      rm -Rf *
      mv .msgpack/* .
    '';

    libraryHaskellDepends = with haskellPackagesExtended; [
      base mtl bytestring text containers unordered-containers hashable vector 
      blaze-builder deepseq binary data-binary-ieee754
    ];
    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  msgpack-rpcPackage = haskellPackagesExtended.mkDerivation {
    pname = "msgpack-rpc";
    version = "1.0.0";
    src = msgpackGIT;
    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    # HACK best workaround ever
    patchPhase = ''
      mv msgpack-rpc .msgpack-rpc
      rm -Rf *
      mv .msgpack-rpc/* .
    '';

    libraryHaskellDepends = with haskellPackagesExtended; [
       msgpackPackage base bytestring text network random mtl monad-control conduit conduit-extra binary-conduit exceptions binary
    ];

    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  msgpack-aesonPackage = haskellPackagesExtended.mkDerivation {
    pname = "msgpack-aeson";
    version = "0.1.0.0";
    src = msgpackGIT;
    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    # HACK best workaround ever
    patchPhase = ''
      mv msgpack-aeson .msgpack-aeson
      rm -Rf *
      mv .msgpack-aeson/* .
    '';

    libraryHaskellDepends = with haskellPackagesExtended; [
       msgpackPackage base aeson bytestring scientific text unordered-containers vector deepseq
    ];
    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  acid-statePackage = haskellPackagesExtended.mkDerivation {
    pname = "acid-state";
    version = "0.14.1";
    src = pkgs.fetchgit {
      url = "https://github.com/serokell/acid-state.git";
      rev = "ad77e909bcd46c3e44eeca558eb8a6f1ff3600eb";
      sha256 = "1jl1j0v9wplqz2ayq2af6hnvisp9ysvnf2f77a5ykn9zik8qbhrg";
    };

    isLibrary = true;
    doCheck = false;

    libraryHaskellDepends = with haskellPackagesExtended; [
       array base bytestring cereal containers directory extensible-exceptions 
       filepath mtl network safecopy stm template-haskell unix
    ];
    license = pkgs.stdenv.lib.licenses.publicDomain;
  };

  haskellPackagesExtended  = pkgs.haskell.packages.lts-6_7.override {
    overrides = self: super: {
      serokell-core = serokellPackage;
      msgpack = msgpackPackage;
      msgpack-rpc = msgpack-rpcPackage;
      msgpack-aeson = msgpack-aesonPackage;
      acid-state = acid-statePackage;
    };
  };

  rscoinExtraDeps = with haskellPackagesExtended; [ serokell-core gtk3 
    aeson pqueue blake2 yaml clock derive extra formatting optparse-generic
    purescript-bridge servant-server string-conversions temporary turtle wai
    wai-extra wai-websockets warp websockets configurator 
    configurator-export ];

  rscoinLibraryHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson base base64-bytestring binary bytestring cereal
    conduit-extra containers cryptohash data-default directory ed25519
    either exceptions file-embed filepath hashable hslogger lens
    monad-control monad-loops MonadRandom msgpack msgpack-aeson
    msgpack-rpc mtl QuickCheck random safe safecopy
      stm text text-format time time-units transformers
    transformers-base tuple unordered-containers vector
  ] ++ rscoinExtraDeps;
  rscoinExecutableHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson base base64-bytestring binary bytestring cereal
    conduit-extra containers cryptohash data-default directory ed25519
    exceptions filepath hashable hslogger hspec lens monad-control
    monad-loops MonadRandom msgpack msgpack-aeson msgpack-rpc mtl
    optparse-applicative QuickCheck random safe safecopy
      stm text text-format time time-units transformers
    transformers-base tuple unordered-containers vector
  ] ++ rscoinExtraDeps;
  rscoinTestHaskellDepends = with haskellPackagesExtended; [
    acid-state async base bytestring containers data-default exceptions
    conduit-extra hspec lens MonadRandom msgpack msgpack-rpc mtl QuickCheck random
    safe safecopy stm text time-units transformers tuple vector
  ] ++ rscoinExtraDeps;
  rscoinLibraryPkgconfigDepends =
    [ haskellPackagesExtended.aeson zlib git openssh stack nodejs ] ++
    [ pkgconfig cairo haskellPackagesExtended.conduit-extra ] ++
    [ haskellPackagesExtended.serokell-core
      haskellPackagesExtended.purescript ];
}
