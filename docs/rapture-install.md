# Rapture — Install Runbook

Installing `rapture` from a NixOS installer ISO, alongside an existing Windows
install on the same disk.

Filesystems are pinned by label, so this repo needs **no edits** — provided you
label the partitions exactly as [Step 4](#step-4-create-the-nixos-partition) and
[Step 6](#step-6-label-the-esp) describe.

## Before you start

- A NixOS installer ISO. Any recent release; the flake pins its own nixpkgs.
- Wired network. The install pulls several GB.
- A while: Hyprland and everything from nixpkgs come from cache.nixos.org,
  but **caelestia and quickshell have no binary cache and compile from
  source**.
- The LUKS passphrase you want. It is prompted for, never stored in the repo.

## Prepare Windows first

Do all three of these **from inside Windows**, before booting the installer.

1. **Suspend BitLocker.** It seals its encryption key to the TPM, bound to
   measurements of the firmware settings, partition layout and bootloader.
   Repartitioning and disabling Secure Boot both change those, so the TPM stops
   releasing the key and Windows boots to a 48-digit recovery-key prompt
   instead of your desktop.

   On Windows 11 Home this is branded *Device Encryption* and is often on by
   default with no BitLocker entry in Control Panel. Check from an admin
   PowerShell — this works on Home too:

   ```powershell
   manage-bde -status          # look for "Protection Status: Protection On"
   ```

   **Save the recovery key before anything else.** It is also usually at
   `account.microsoft.com/devices/recoverykey`:

   ```powershell
   manage-bde -protectors -get C:
   ```

   Then suspend it:

   ```powershell
   Suspend-BitLocker -MountPoint "C:" -RebootCount 0
   ```

   `-RebootCount 0` keeps it suspended until you explicitly resume. The default
   of `1` re-arms after a single reboot — in the middle of the install.

   Suspending does not decrypt the disk; it parks the key so the TPM seal is not
   consulted, and re-seals against the new measurements on resume. Resume with
   `Resume-BitLocker -MountPoint "C:"` once NixOS is installed, Secure Boot is
   settled, and Windows has booted successfully at least once.
2. **Disable Fast Startup** (Control Panel → Power Options → Choose what the
   power buttons do → Uncheck *Turn on fast startup*). Fast Startup hibernates
   rather than shutting down, leaving the NTFS filesystem dirty and the disk
   in a state Linux must not touch.
3. **Shrink the Windows partition** from Disk Management (`diskmgmt.msc`) →
   right-click the Windows volume → *Shrink Volume*. Leave as much free space as
   you want NixOS to have. Use Windows' own tool — it understands NTFS metadata
   and moves things safely in a way third-party tools may not.

Then shut down **fully** (Shift + click Restart, or `shutdown /s /t 0`).

You may also need to **disable Secure Boot** in firmware. NixOS does not support
it out of the box; enabling it would leave the machine booting only Windows.

### If the partition was already resized from Linux

If the shrink was done with GParted or similar rather than from Windows, two
things are already known good: GParted cannot resize a BitLocker-encrypted
volume (it reads as an unknown filesystem), and `ntfsresize` refuses a
hibernated or dirty volume. A successful resize means neither was in the way.

What is *not* guaranteed is the boot configuration. Shrinking from the end is
safe; moving a partition's start offset can leave the BCD pointing at the wrong
place.

**Boot Windows once and confirm it works before continuing.** If it does not,
repair it from Windows Recovery → Command Prompt before installing anything:

```
bootrec /fixboot
bootrec /rebuildbcd
```

Fixing this is far easier before a second bootloader is in the picture.

## Step 1: Clone the repo

```bash
nix-shell -p git
git clone https://github.com/arthurgeek/nix-config /tmp/nix-config
cd /tmp/nix-config
```

No credentials needed — the repo is public.

If the work you are installing lives on a branch, check it out — `git clone`
leaves you on `main`:

```bash
git checkout feat/hyprland-caelestia
```

Building the wrong ref fails loudly at evaluation (a missing package, a module
error), not subtly — so if `nixos-install` errors before building anything,
check `git log --oneline -1` against the branch you meant first.

To update the clone later (the branch may have been force-pushed):

```bash
git fetch origin
git reset --hard origin/feat/hyprland-caelestia
```

## Step 2: Identify the disk

```bash
lsblk -o NAME,SIZE,FSTYPE,PARTLABEL,LABEL,MOUNTPOINT
```

Note two things:

- The **ESP** — a small (typically 100–500 MB) `vfat` partition, usually
  `nvme0n1p1`. **You will reuse this. Never reformat it.**
- The **free space** you created by shrinking Windows.

Windows normally occupies several partitions (recovery, MSR, the C: volume).
Leave every one of them alone.

## Step 3: Find where the free space starts

```bash
sudo parted /dev/nvme0n1 -- unit GiB print free
```

```
Number  Start        End          Size        File system  Name                 Flags
        0.02MiB      1.00MiB      0.98MiB     Free Space
 1      1.00MiB      201MiB       200MiB      fat32                             boot, esp
 2      201MiB       217MiB       16.0MiB                  Microsoft reserved   msftres
 3      217MiB       1639941MiB   1639724MiB  ntfs         Basic data partition msftdata
        1639941MiB   1906873MiB   266932MiB   Free Space        <-- this row
 4      1906873MiB   1907728MiB   855MiB      ntfs                              hidden, diag
        1907728MiB   1907729MiB   1.07MiB     Free Space
```

Note **both the Start and the End** of the large `Free Space` row.

Ignore the tiny free blocks at either end of the disk — those are alignment
padding, not your space.

**Do not assume the free space runs to the end of the disk.** Windows commonly
places its recovery partition last, *after* the C: volume, as partition 4 does
above. Shrinking C: then leaves a gap in the middle, not a tail.

## Step 4: Create the NixOS partition

`parted mkpart` takes `NAME START END`, where **start and end are absolute
offsets from the beginning of the disk** — not sizes, and not how much free
space you have. Passing a size here would start the partition in the middle of
Windows.

> **This is the step that can destroy Windows.** Use the Start and End you read
> in Step 3, verbatim.

```bash
sudo parted /dev/nvme0n1 -- mkpart nixos-luks 1639941MiB 1906873MiB
#                                             ^^^^^^^^^^ ^^^^^^^^^^
#                                             Start      End, both from Step 3
```

Always give both bounds explicitly, copied from the `Free Space` row. Anything
that follows the gap — a recovery partition, say — must stay untouched, and an
explicit end is what guarantees that.

If parted warns the partition is not properly aligned, answer `Cancel`, round
the start up to the next whole MiB, and retry.

The name **must be `nixos-luks`** — that is the GPT partition label
`hardware-configuration.nix` pins the LUKS container by.

Verify before continuing:

```bash
lsblk -o NAME,SIZE,PARTLABEL,FSTYPE /dev/nvme0n1
```

The new partition should show `PARTLABEL` `nixos-luks` with no filesystem, and
**every Windows partition must still be listed**. If one is missing, stop and do
not write anything further to the disk.

## Step 5: Encrypt and create the filesystem

```bash
sudo cryptsetup luksFormat /dev/disk/by-partlabel/nixos-luks
sudo cryptsetup open /dev/disk/by-partlabel/nixos-luks cryptroot
sudo mkfs.btrfs /dev/mapper/cryptroot
```

The mapping **must be named `cryptroot`** — the config mounts
`/dev/mapper/cryptroot` as `/`.

Now create the subvolumes. Mount the filesystem's top level, make them, and
unmount again:

```bash
sudo mount /dev/mapper/cryptroot /mnt
sudo btrfs subvolume create /mnt/@root
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@snapshots
sudo btrfs subvolume create /mnt/@games
sudo umount /mnt
```

The five names are the contract — `hardware-configuration.nix` mounts each by
`subvol=`, so a typo here surfaces as a boot failure rather than an error now.

## Step 6: Label the ESP

The config finds `/boot` by the FAT volume label `NIXBOOT`:

```bash
sudo fatlabel /dev/nvme0n1p1 NIXBOOT      # substitute your ESP
```

This writes only the volume-label field. Windows boots from UEFI NVRAM entries
that reference the partition GUID and `\EFI\Microsoft\Boot\bootmgfw.efi`, so the
label is invisible to it.

If you would rather not touch it at all, leave the label alone and change
`fileSystems."/boot".device` in `hosts/rapture/hardware-configuration.nix` to the
ESP's UUID from `blkid` — at the cost of a machine-specific value in the repo.

## Step 7: Mount

Each subvolume is mounted with the options the config declares, so the installed
system and the installer agree:

```bash
sudo mount -o subvol=@root,compress=zstd,noatime /dev/mapper/cryptroot /mnt

sudo mkdir -p /mnt/home /mnt/nix /mnt/boot
sudo mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
sudo mount -o subvol=@nix,compress=zstd,noatime  /dev/mapper/cryptroot /mnt/nix

sudo mkdir -p /mnt/home/.snapshots
sudo mount -o subvol=@snapshots,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home/.snapshots

sudo mkdir -p /mnt/home/arthur/Games
sudo mount -o subvol=@games,nodatacow,noatime /dev/mapper/cryptroot /mnt/home/arthur/Games

sudo mount -o umask=0077 /dev/disk/by-label/NIXBOOT /mnt/boot
```

`@games` is mounted `nodatacow`: game assets are already compressed, and their
large random writes fragment a copy-on-write filesystem badly. That also turns
off checksums and compression for that subvolume alone.

The `umask=0077` matches how the installed system mounts the ESP, and keeps
systemd-boot from warning that the random-seed file it writes there is
world-readable.

Check the result:

```bash
findmnt -R /mnt
```

Sanity-check that `/mnt/boot` contains an `EFI/Microsoft` directory. If it does
not, you have mounted the wrong partition — stop and recheck.

## Step 8: Install

`env "PATH=$PATH"` matters: some flake inputs are locked as raw git URLs
(quickshell, for one), and fetching those at evaluation needs the `git`
binary — which plain `sudo` can drop from PATH.

```bash
sudo env "PATH=$PATH" nixos-install --flake /tmp/nix-config#rapture
```

It prompts for a **root** password at the end. Set one — it is a recovery path.

## Step 9: Put the repo in place

`programs.nh.flake` points at `/home/arthur/nix-config`.

```bash
sudo mkdir -p /mnt/home/arthur
sudo cp -r /tmp/nix-config /mnt/home/arthur/nix-config
sudo chown -R 1000:100 /mnt/home/arthur
reboot
```

After first boot, `make nixos-rebuild` is all future rebuilds need.

---

## First boot

### 1. Both operating systems are offered

systemd-boot should list NixOS **and** Windows Boot Manager — it scans the ESP
and picks up `\EFI\Microsoft\Boot\bootmgfw.efi` on its own.

If Windows is missing, `/boot` is probably not the ESP Windows uses. Check that
`/boot/EFI/Microsoft` exists.

Boot Windows once to confirm it still works before going further.

### 2. Log in

regreet (a graphical greeter) should offer exactly **two** sessions in its
dropdown: `Hyprland` and `Niri`. It remembers your last user and session on
its own.

The bootstrap password is `nixos`. **Change it immediately:**

```bash
passwd
```

It is declared as `initialHashedPassword`, so it applies only at account
creation and your new password will stick. The SSH keys in
`modules/nixos/common/default.nix` are the real access path — if the password
ever fails you, `ssh arthur@rapture` still works.

### 3. Per-session isolation

Exactly one shell per session. Under **Hyprland**:

```bash
systemctl --user is-active caelestia        # active
systemctl --user is-active noctalia-shell   # inactive / not loaded
hyprctl version | head -1                   # the nixpkgs hyprland version
ls ~/.config/hypr/                          # hyprland.lua + 5 lua files
```

Log out, pick **Niri**:

```bash
pgrep -a noctalia-shell                     # running
systemctl --user is-active caelestia        # inactive
```

Both halves must pass. Caelestia running under niri means its
`systemd.target = "hyprland-session.target"` binding is not taking effect.

### 4. Lock screen — highest risk, read first

Caelestia reads PAM from its own bundled `assets/pam.d` rather than
`/etc/pam.d`, relying on the setuid `/run/wrappers/bin/unix_chkpwd`. If that
does not line up, a correct password is rejected and you are locked out of the
running session.

**Open a TTY first** (Ctrl+Alt+F2), log in there, and leave it. greetd occupies
tty1 only, so tty2–tty6 always have a getty. Then press `SUPER + L` in Hyprland.

If it fails, from the TTY run `pkill -f caelestia-shell`, then add to
`modules/nixos/desktop/hyprland/default.nix`:

```nix
  security.pam.services.caelestia = { };
```

and rebuild.

### 5. Scrolling layout

Open three terminals with `SUPER + T`. They should lay out on a horizontal tape,
not tile into quadrants.

```
SUPER + left / right     focus scrolls between columns, wrapping at the ends
SUPER + A                column width cycles 0.5 -> 0.66667 -> 1.0
SUPER + bracketright     pulls the next window into the current column
SUPER + G                promotes it back out into its own column
SUPER + O                fits all visible columns on screen
```

### 6. Named workspaces

Steam's rules send it to a *named* workspace. Named workspaces get negative ids
that plain `+1`/`-1` cycling cannot reach, which is why the binds use
`m+1`/`m-1`:

```
launch steam                    window moves to the "steam" workspace
SUPER + mouse wheel             cycles onto it and back off
CTRL + SUPER + Right / Left     same, by keyboard
```

If the wheel skips past it, the window is unreachable.

### 7. Caelestia shortcuts

```
tap and release SUPER alone    launcher opens
hold SUPER, press T            terminal opens, launcher does NOT
SUPER + N                      sidebar
CTRL + ALT + Delete            session menu
```

If the bar is visible but keys do nothing, Hyprland parsed the binds before the
shell registered its global shortcuts. `systemctl --user restart caelestia` and
retry.

### 8. Niri is unharmed

Log into niri and use it briefly — noctalia's bar, its launcher (`Mod+Space`),
window management.

---

## Restoring what the repo does not carry

- **Caelestia's colour scheme** lives in `~/.local/state/caelestia/scheme.json`,
  mutable runtime state rather than config. It defaults to catppuccin *mocha*;
  match the rest of the system with:
  ```bash
  caelestia scheme set -n catppuccin -f macchiato
  ```
- **SSH and GPG private keys.** The public keys are declared; the private halves
  are not and cannot be.
- **1Password sign-in.** The app, its CLI, the polkit policy and the
  `1Password-BrowserSupport` setgid helper are all installed declaratively, so
  there is nothing to set up — but you still have to sign in, and enable
  **Settings → Developer → Use the SSH agent**. That toggle is app state, not
  config, so it cannot be declared.

  Commits here are signed with `op-ssh-sign` and `commit.gpgsign = true`, so git
  will refuse to commit until the agent is running.

  The install clones over https. Once the agent is up, switch `origin` to SSH so
  pushes use a key rather than prompting for a token:
  ```bash
  git -C ~/nix-config remote set-url origin git@github.com:arthurgeek/nix-config.git
  ```
- Wallpapers and anything else under `~`.

## Notes

- **The ESP is shared with Windows and is small.**
  `boot.loader.systemd-boot.configurationLimit = 5` caps how many generations
  keep a kernel there. If rebuilds start failing with no space left on device,
  that is why — lower it, or `nix-collect-garbage` and rebuild.
- **Editing the Lua does not take effect on rebuild.** Because
  `wayland.windowManager.hyprland.package = null` (Hyprland is installed by the
  NixOS module), home-manager's reload hook is gated off. After changing a
  `.lua` file, run `hyprctl reload` or re-login.
- **Snapshots.** snapper takes hourly snapshots of `/home` (24 hourly / 7
  daily / 4 weekly kept) into `/home/.snapshots`. To recover a file:
  ```bash
  snapper -c home list
  cp /home/.snapshots/<n>/snapshot/arthur/path/to/file ~/path/to/file
  ```
  The system itself has no snapper config — NixOS generations cover it.
- **The three labels are the contract.** `nixos-luks` (GPT partition label),
  `cryptroot` (LUKS mapping name) and `NIXBOOT` (FAT volume label) are what let
  this repo stay machine-independent. Reuse them on any future reinstall and
  nothing here needs editing.
- **Recovery.** Ctrl+Alt+F2 for a getty, `ssh arthur@rapture` with any declared
  key, or boot the previous generation from the systemd-boot menu.
