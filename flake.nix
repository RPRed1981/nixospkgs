{
  description = "Rory nixpkgs";

  outputs = { self }: {
    foo2zjs = import ./foo2zjs/default.nix;
  };
}
