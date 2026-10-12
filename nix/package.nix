{
  lib,
  stdenvNoCC,
  makeWrapper,
  impasto,
  quickshell,
  python3,
  awww,
  bluez,
  brightnessctl,
  cava,
  cldr-annotations,
  dbus,
  ddcutil,
  fontconfig,
  grim,
  gtk3,
  hyprland,
  hyprpicker,
  hyprsunset,
  imagemagick,
  isocodes,
  jq,
  libnotify,
  mpvpaper,
  networkmanager,
  papirus-icon-theme,
  playerctl,
  power-profiles-daemon,
  pulseaudio,
  rofi,
  satty,
  slurp,
  systemd,
  tesseract,
  unicode-emoji,
  wf-recorder,
  wireplumber,
  wl-clipboard,
  wl-screenrec,
  xdg-user-dirs,
  xdg-utils,
  xkeyboard_config,
}:
let
  runtime = [
    python3
    awww
    bluez
    brightnessctl
    cava
    dbus
    ddcutil
    fontconfig
    grim
    gtk3
    hyprland
    hyprpicker
    hyprsunset
    imagemagick
    libnotify
    mpvpaper
    networkmanager
    playerctl
    power-profiles-daemon
    pulseaudio
    satty
    slurp
    systemd
    tesseract
    wf-recorder
    wireplumber
    wl-clipboard
    wl-screenrec
    xdg-user-dirs
    xdg-utils
  ];
in
stdenvNoCC.mkDerivation {
  pname = "island";
  version = "0.1.0-impasto-${lib.substring 0 7 (impasto.rev or "dirty")}";
  src = impasto;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];
  dontBuild = true;

  postPatch = ''
    shell=home/.config/quickshell
    patch -p1 -d "$shell" < ${../patches/nix-managed-targets.patch}
    patch -p1 -d "$shell" < ${../patches/upstream-fixes.patch}
    patch -p1 -d "$shell" < ${../patches/duo-status-marks.patch}
    patch -p1 -d "$shell" < ${../patches/no-dock.patch}
    substituteInPlace "$shell/components/TrayIcon.qml" \
      --replace-fail /usr/share/icons/Papirus-Dark ${papirus-icon-theme}/share/icons/Papirus-Dark
    {
      echo ".pragma library"
      echo "var names = {"
      for icon in ${papirus-icon-theme}/share/icons/Papirus-Dark/22x22/panel/*.svg; do
        name=''${icon##*/}
        echo "  \"''${name%.svg}\": true,"
      done
      echo "}"
    } > "$shell/components/panel-icons.js"
    substituteInPlace "$shell/scripts/emoji.py" \
      --replace-fail /usr/share/unicode/emoji ${unicode-emoji}/share/unicode/emoji \
      --replace-fail /usr/share/unicode/cldr ${cldr-annotations}/share/unicode/cldr \
      --replace-fail /usr/share/iso-codes ${isocodes}/share/iso-codes
    substituteInPlace "$shell/scripts/compositor.py" \
      --replace-fail /usr/share/X11/xkb/rules ${xkeyboard_config}/share/xkeyboard-config-2/rules
  '';

  installPhase = ''
    runHook preInstall
    shell="$out/share/quickshell/island"
    mkdir -p "$shell" "$out/bin" "$out/share/island"
    cp -r home/.config/quickshell/. "$shell/"
    chmod +x "$shell"/scripts/*.py
    cp -r home/.local/share/wallpapers "$out/share/island/wallpapers"
    mkdir -p "$out/share/fonts/truetype"
    install -m644 home/.local/share/fonts/*.ttf "$out/share/fonts/truetype/"
    install -Dm644 ${./hyprland.lua} "$out/share/island/hyprland.lua"
    install -Dm755 ${../scripts/wallpaper-effect.sh} "$out/libexec/island-wallpaper-effect"
    install -Dm755 ${../scripts/apply-settings.py} "$out/libexec/island-apply-settings"

    makeWrapper ${lib.getExe quickshell} "$out/bin/island" \
      --add-flags "--path $shell" \
      --prefix PATH : ${lib.makeBinPath runtime} \
      --set-default QS_ICON_THEME Papirus-Dark \
      --set-default QSG_RENDER_LOOP threaded \
      --suffix XDG_DATA_DIRS : ${papirus-icon-theme}/share \
      --run 'if [ -z "''${TZDIR-}" ] && [ -d /etc/zoneinfo ]; then export TZDIR=/etc/zoneinfo; fi'
    makeWrapper ${lib.getExe quickshell} "$out/bin/islandctl" \
      --add-flags "--path $shell ipc call"
    makeWrapper "$out/libexec/island-wallpaper-effect" "$out/bin/island-wallpaper-effect" \
      --prefix PATH : ${
        lib.makeBinPath [
          imagemagick
          jq
          libnotify
          rofi
        ]
      }:"$out/bin"
    runHook postInstall
  '';

  passthru = { inherit quickshell; };

  meta = {
    description = "impasto's Quickshell island shell for Hyprland, packaged for Nix";
    homepage = "https://github.com/keewai704/Island";
    license = lib.licenses.gpl3Only;
    mainProgram = "island";
    platforms = lib.platforms.linux;
  };
}
