{ inputs, config, ... }: {
  imports = [ inputs.nixcord.homeModules.nixcord ]; 
  programs.nixcord = {
	enable = true;
  discord.vencord.enable = true;
};  
}
