# The Seedbox Migration Project

A rundown of what it took to move my seedbox from a Raspberry Pi 3B to a proper x86 mini PC and turn it into a full media server. Spoiler: :gunmouth:

## Starting Point
- Raspberry Pi 3B running Deluge with 1,431 torrents
- 1TB microSD card as storage, years old and suffering
- SMB transfers off the Pi capped at around 10 MB/s (we used to think usb 2.0 was fast!)
- Goal: move to faster hardware, add a media server, keep all the torrent seeding history intact without being branded a leech on every private tracker I'm on

## Hardware Selection
- Considered some options: Pi 5 with SATA HAT, UGREEN NAS, maybe custom Mini-ITX build?
- Realized I already had a Dell OptiPlex 3080 Micro sitting around, plus a Lenovo M70q and three M910qs in the basement.
- Picked the Dell 3080 Micro: 10th gen i5, Intel QuickSync for hardware transcoding, slightly quieter fan than the Lenovo
- 32GB RAM, 512GB NVMe for OS, 2TB SSD for storage
- Wall-mounted next to the router on the wall. 3d printed and painted a nice little cubby for it.

## OS Installation
- Installed Debian 13 "Trixie" (current stable)
- Did the full install because I wasn't paying attention
- Forgot to check the SSH server box in tasksel. Classic
- Spent a full two hours trying to get VNC working
- Turns out GNOME on Wayland hates every open-source VNC solution ever made
- TigerVNC broke. x11vnc broke. XFCE-as-fallback broke
- Finally installed RealVNC, which worked immediately...
- Dell's power button started doing a weird blink pattern at some point. Ignored it. Probably the CMOS battery. But then the Dell wouldn't autoboot, since it kept getting stuck at POST saying the time was wrong. Replaced that. 

## Docker Stack Setup
- Built a docker-compose stack with five containers to start
- **gluetun** for PIA VPN (kill switch built in via container networking)
- **Deluge** routing all traffic through gluetun
- **Jellyfin** on host network with GPU passthrough for QuickSync
- **Samba** on the host for Windows SMB shares
- Custom **port-sync sidecar** I wrote in Python to hot-update Deluge's listen port via JSON-RPC whenever PIA's forwarded port rotates

## Issues During Setup
- PIA no longer supports WireGuard through gluetun, had to use OpenVPN (which is funny cause a few weeks ago i just switched from OpenVPN to WireGuard on the RasbPi)
- Gluetun API endpoint got renamed mid-project (301 redirect was a fun surprise)
- YAML indentation broke the compose file approximately 47 times
- Jellyfin's GPU passthrough required a "render" group that didn't exist on the host. Used numeric GIDs to brute-force past it
- Deluge's AutoAdd plugin crashed the daemon on first boot. Disabled it, re-enabled later, works fine now. -shrug-

## The Storage Mistake
- Built the entire Docker stack pointing at `/mnt/storage`
- Everything working beautifully for two days
- Then noticed the 2TB SSD was never actually formatted or mounted
- All my configs had been writing to a regular folder on the 444GB NVMe boot drive the whole time
- If I'd started the 828GB data migration before catching this, the drive would have filled up mid-copy
- Caught it, formatted the SSD, mounted it, moved the empty folder structure. 

## Data Migration
- Pulled SD card from Pi, plugged into Dell via USB-C reader, mounted read-only
- Started rsync on 828GB of torrent data
- Estimated time: 5 hours
- Actual throughput: 10 MB/s
- Actual time: 23 hours
- The SD card is old. It was never going to be fast. But it read every byte without a single error, which is the important part
- Again, running on USB 2.0, the adapater I had was cheap.
- Imported the Pi's Deluge state files into the new containerized Deluge
- **All 1,431 torrents resumed without rehashing**. This was the biggest single win of the whole project, and the part I was most afraid about. No re-seed penalty on any tracker!

## The Port Number That Ate An Hour
- New Deluge web UI completely unreachable after migration
- Turned out the Pi had been running Deluge on port 58847
- Literally every other Deluge on earth uses 58846
- I do not know why Past Me did this. I will never know
- One character fix. Thirty minutes of confused debugging to find it

## Media Server Configuration
- Jellyfin's first scan auto-created a Music library and started analyzing 10,744 audio files
- Fan audibly spun up, CPU at 400%+
- Deleted the music library, computer chilled out
- Added Sonarr and Radarr for automatic file organization
- Set up watch folders in Deluge: `watch-movies` and `watch-tv`
- Configured per-folder "move completed" paths so downloads auto-sort by type
- Sonarr and Radarr hardlink from `completed-*` into `/media/tv` and `/media/movies`
- Source files stay put, seeding continues, media library gets clean organized names for Jellyfin to match metadata against

## Learning Sonarr's Moods
- Sonarr refused to auto-import manually-added torrents: *"Download wasn't grabbed by Sonarr and not in a category, Skipping"*
- Fix: Deluge labels + matching categories in the Sonarr/Radarr download client config
- Correct workflow took a while to learn: add series in Sonarr first, then drop the torrent in the watch folder, then it all works automatically
- Manual Import UI in Sonarr v4 is hidden at `/wanted/manualimport` and I spent a genuinely unreasonable amount of time looking for it

## Final State
- Six containers running: gluetun, deluge, deluge-port-sync, jellyfin, sonarr, radarr
- Samba serves network shares to Windows
- 903GB used of 1.8TB available
- `/media/tv` contains 302GB of organized TV content
- `/media/movies` contains 18GB of organized movie content
- Only 65GB of actual disk usage growth from the organization layer. The rest is hardlinks. **255GB saved.**
- Full workflow: drop `.torrent` into the correct watch folder, content appears in Jellyfin automatically. Chef's kiss

## Still TODO
- Replace stock Dell fan with a Noctua NF-A6x15 (ordered, the stock fan has a tone that is driving me insane)
- Set up some system so friends can stream from Jellyfin remotely


Hopefully I'll never have to do this again. Upgrading in the future should be a lot easier though. 