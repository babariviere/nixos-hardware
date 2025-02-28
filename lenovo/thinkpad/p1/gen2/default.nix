{ config, lib, ... }:

with lib;

{
  imports = [
    ../.
  ];

  # Fixes an issue with incorrect battery reporting. See
  # https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Extreme_(Gen_2)#Invalid_Stats_Workaround
  boot.initrd.availableKernelModules = [ "battery" ];

  # New ThinkPads have a different TrackPoint manufacturer/name.
  # See also https://certification.ubuntu.com/catalog/component/input/5313/input%3ATPPS/2ElanTrackPoint/
  hardware.trackpoint.device = "TPPS/2 Elan TrackPoint";

  # Since the HDMI port is connected to the NVIDIA card.
  hardware.bumblebee.connectDisplay = true;

  nixpkgs.overlays = [
    (self: super: {
      bumblebee = super.bumblebee.override {
        extraNvidiaDeviceOptions = ''
          Option "AllowEmptyInitialConfiguration"
        '';
      };
    })
  ];

  # To support intel-virtual-output when using Bumblebee.
  services.xserver = mkIf config.hardware.bumblebee.enable {
    deviceSection = ''Option "VirtualHeads" "1"'';
    videoDrivers = [ "intel" ];
  };

  services.throttled.enable = lib.mkDefault true;
}
