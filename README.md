# Island

A HyprFlux × impasto desktop shell for Hyprland, packaged as a Nix flake.

The shell itself is [impasto](https://github.com/andreumassanet/impasto)
(GPL-3.0): the black island in the bar that becomes the launcher, control
centre, notifications, games, notes and task board; desktop widgets under the
windows; and a palette taken from the wallpaper. Island pins it as a flake input
instead of copying it, and adds only what NixOS needs:

- `/usr/share` lookups (Papirus tray icons, emoji data, country codes, xkb
  layouts) point at their nixpkgs store paths.
- The palette writer leaves configuration files that Home Manager links into
  the Nix store alone instead of replacing them.
- Every program the shell calls is on its `PATH`, so nothing has to be
  installed system-wide.

From [HyprFlux](https://github.com/ahmad9059/HyprFlux) (MIT) comes the
ImageMagick wallpaper effects menu (`island-wallpaper-effect`), applied through
the shell so the palette follows the processed picture.

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

Island replaces other bars, notification daemons, polkit agents and wallpaper
daemons, so disable those it would compete with.

Keybinds and window rules for a Lua Hyprland config:

```lua
dofile(island_package .. "/share/island/hyprland.lua")({
    package = island_package,
    modifier = "SUPER",
    look = true,
})
```

`look` applies impasto's gaps, rounding and blur; `binds = false` keeps only the
rules. `SUPER + Space` opens the launcher, `SUPER + A` the control centre,
`SUPER + T` the wallpapers, `SUPER + SHIFT + W` the wallpaper effects and
`SUPER + H` lists every key.

`islandctl <target> <function> [args]` calls the shell's IPC, for example
`islandctl wallpaper set ~/Pictures/fuji.jpg`.

## Packages

| Output | |
| --- | --- |
| `packages.<system>.island` | `island`, `islandctl`, `island-wallpaper-effect` |
| `homeManagerModules.default` | `programs.island.{enable,package,wallpapers}` |
| `nixosModules.default` | `programs.island.enable` |

## License

GPL-3.0, as a work based on impasto.
