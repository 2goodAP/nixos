# An overlay for the latest version of rofi-wayland.

self: super: {
  rofi-wayland-unwrapped = super.rofi-wayland-unwrapped.overrideAttrs (oldAttrs: {
    version = "1.7.5+wayland1";

    src = super.fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      rev = "9ec86220d55a72e89a60f357a71d3572f130f885";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  });
}
