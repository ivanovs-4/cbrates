{ mkDerivation, attoparsec, base, containers, fetchgit, hspec
, hspec-discover, interpolatedstring-perl6, mtl, safe, stdenv, text
, time
}:
mkDerivation {
  pname = "fuzzy-parse";
  version = "0.1.1.0";
  src = fetchgit {
    url = "git@github.com:hexresearch/fuzzy-parse.git";
    sha256 = "0ss5npmxbv498ziblr766mz2q6cy5nkm6zi3y9cpfyb3bkax8cfj";
    rev = "99643c1d49822b943707c7f26b6777f2b227672e";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    attoparsec base containers mtl safe text time
  ];
  testHaskellDepends = [
    base hspec hspec-discover interpolatedstring-perl6 text
  ];
  testToolDepends = [ hspec-discover ];
  homepage = "https://github.com/hexresearch/fuzzy-parse";
  description = "Tools for processing unstructured text data";
  license = stdenv.lib.licenses.mit;
}
