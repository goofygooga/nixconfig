{
  self,
  autovirt,
}:

{
  imports = [
    (import ./vm.nix {
      inherit self autovirt;
    })
    (import ./looking-glass.nix)
  ];
}
