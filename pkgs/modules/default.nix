{
  self,
  autovirt,
}:

{
  imports = [
    (import ./vm.nix {
      inherit self autovirt;
    })
  ];
}
