# Island

A HyprFlux × impasto desktop shell for Hyprland, packaged as a Nix flake.

The shell itself is a [fork of impasto](https://github.com/keewai704/impasto)
(GPL-3.0): the black island in the bar that becomes the launcher, control
centre, notifications, notes and task board; desktop widgets under the
windows; and a palette taken from the wallpaper. Island pins the fork as a
flake input. Shell changes live directly in the fork; this repository handles
NixOS packaging:

- `/usr/share` lookups (Papirus tray icons, emoji data, country codes, xkb
  layouts) point at their nixpkgs store paths.
- Every program the shell calls is on its `PATH`, so nothing has to be
  installed system-wide.

The fork also leaves configuration files that Home Manager links into the Nix
store alone when writing the palette.

The dock along the bottom edge is left out; its pins still order the launcher.
The built-in games and pets are removed from the fork.
Two upstream issues are fixed on the way: lists exposed over
IPC, and tray icons probed in the Papirus panel set when it has no such icon.
These changes are maintained in the fork rather than applied as build-time
patches.

Brightness goes through [hypr-brightness](https://github.com/keewai704/hypr-brightness)
instead of brightnessctl and ddcutil. The shell keeps one connection to its
socket: the brightness keys, the control centre slider and `islandctl brightness`
send levels there, and levels set elsewhere (the `hypr-brightness` CLI, for one)
come back as events and show the OSD.

From [HyprFlux](https://github.com/ahmad9059/HyprFlux) (MIT) comes the
ImageMagick wallpaper effects, selected in the island's appearance panel
(`island-wallpaper-effect` opens it too). Effects are applied to the original
picture, and No Effects restores it, so switching effects does not stack them.
The palette follows the processed picture.

## Use

```nix
inputs.island = {
  url = "git+https://github.com/keewai704/Island.git?ref=main";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
# NixOS: NetworkManager, Bluetooth, UPower, power profiles, PipeWire
imports = [ inputs.island.nixosModules.default ];
programs.island.enable = true;

# Home Manager: the shell and awww as user services, fonts, impasto's paintings
imports = [ inputs.island.homeManagerModules.default ];
programs.island.enable = true;
```

```nix
# hypr-brightness, which Island talks to but does not import
inputs.hypr-brightness = {
  url = "git+https://github.com/keewai704/hypr-brightness.git?ref=main";
  inputs.nixpkgs.follows = "nixpkgs";
};
# NixOS: I2C access for monitors
imports = [ inputs.hypr-brightness.nixosModules.default ];
services.hypr-brightness.enable = true;
# Home Manager: the daemon and its socket
imports = [ inputs.hypr-brightness.homeManagerModules.default ];
services.hypr-brightness.enable = true;
```

Island replaces other bars, notification daemons, polkit agents and wallpaper
daemons, so disable those it would compete with.

### Settings

Anything left unset here stays as you change it in the shell's Settings;
anything set is written over `~/.local/state/quickshell/settings.json` before
the shell starts, so a Home Manager switch restarts it with the new values.

```nix
programs.island = {
  enable = true;
  wallpaper = ./fuji.jpg;      # shown until another is picked
  palette = "adaptive";        # or tokyo_night, nord, gruvbox_dark, ...
  bar = {
    style = "grouped";         # grouped | spread | island
    height = 32;
    chips.shape = "icon";      # icon | ring (gauges)
    chips.figure = "on";       # off | hover | on
    workspaces = { style = "dots"; count = 5; };
    left = [ "workspaces" ];
    right = [ "tray" "notifications" "network" "volume" { id = "stats"; figure = "on"; } ];
  };
  clock = { format = "HH:mm"; date = true; seconds = false; };
  font.family = "Inter";
  weather.place = "Tokyo";
  idle = { lock = 0; screen = 10; suspend = 0; };   # minutes, 0 never
  nightLight = { enable = true; temperature = 4000; };
  desktop.theme = "modern";    # modern | analogue | sticker
  settings.notificationTimeout = 8000;   # any other settings.json key
};
```

For a Lua Hyprland config, the Home Manager module renders the keybinds and
window rules as `config.programs.island.hyprland.config`; put that text into
`hyprland.lua` before your own binds. `hyprland.look` applies impasto's gaps,
rounding and blur, `hyprland.binds = false` keeps only the rules, and
`hyprland.lockKey` binds a lock key. `programs.island.wallpaper` is shown until
another wallpaper is picked.

| Key | |
| --- | --- |
| `SUPER + Space` | Launcher (`=` sums, `@` windows, `'` clipboard, `:` emoji, `>` shell) |
| `SUPER + SHIFT + Space` | Wallpapers |
| `SUPER + SHIFT + W` | Wallpaper effects in the island (Left/Right to select, Enter to apply) |
| `SUPER + SHIFT + T` | Palette |
| `SUPER + I` | Control centre and notifications |
| `SUPER + D` | Workspace overview |
| `SUPER + V` | Clipboard |
| `SUPER + S` / `B` / `U` | Notes / task board / statistics |
| `SUPER + CTRL + B` / `W` | Hide the bar / the desktop widgets |
| `SUPER + ALT + C` | Session menu |
| `SUPER + F1` | Every key |
| `Print`, `SHIFT + Print`, `CTRL + Print` | Capture surface, screen, window |

`islandctl <target> <function> [args]` calls the shell's IPC, for example
`islandctl wallpaper set ~/Pictures/fuji.jpg`.
`islandctl wallpaper effects` lists the effects and the active one;
`islandctl wallpaper effect sepia-tone` applies one, and `none` restores the
original. Image processing runs in the background while the island stays usable.

## Packages

| Output | |
| --- | --- |
| `packages.<system>.island` | `island`, `islandctl`, `island-wallpaper-effect` |
| `homeManagerModules.default` | `programs.island.{enable,package,wallpapers,wallpaper,hyprland}` |
| `nixosModules.default` | `programs.island.enable` |

## License

GPL-3.0, as a work based on impasto.
