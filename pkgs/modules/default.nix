{
  self,
  AutoVirt,
}:

{
  imports = [
    (import ./vm.nix {
      inherit self AutoVirt;
    })
  ];
}
