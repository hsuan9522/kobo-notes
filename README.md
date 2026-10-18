# kobo-notes

Export Kobo highlights and annotations to Markdown, show recent highlights from NickelMenu, and toggle a plain-text copy in the Kobo library.

## Build an install package

The package is a `KoboRoot.tgz` archive for a Kobo device. It installs Notes into `.adds/nickel-hs/notes/` and adds its NickelMenu configuration to `.adds/nm/hsNotes`.

Notes uses the shared database, SQLite runtime, and bookmark-sync script from [hs-kobo-backup](https://github.com/hsuan9522/hs-kobo-backup). By default, `build.sh` uses `../hs-kobo-backup`; set `BACKUP_SOURCE` to use a different checkout:

```sh
./build.sh
# or
BACKUP_SOURCE=/path/to/hs-kobo-backup ./build.sh
```

The output is `dist/KoboRoot.tgz`. Copy it to the Kobo's `.kobo/` directory and safely eject the device. Kobo installs the package and restarts. This archive can be used for both a first install and an upgrade. It preserves `.adds/nickel-hs/HsKobo.sqlite`, `/mnt/onboard/note/notes.md`, and other exported note files.

The package includes the shared database template and bookmark sync dependency, so it can be installed directly. If hs-kobo-backup is already installed, the shared runtime files are updated to the bundled version while the existing database remains intact.

## NickelMenu entries

The package installs these entries through `.adds/nm/hsNotes`:

- Main menu: toggle `筆記.txt` in the library from `notes.md`.
- Reader and selection menus: show the four latest highlights.
- Selection menu: sync the selected bookmark into the shared database and regenerate Markdown, or delete the latest saved note.

NickelMenu must be installed. The Notes package bundles the shared database, SQLite runtime, and bookmark-sync command it needs. Install [hs-kobo-backup](https://github.com/hsuan9522/hs-kobo-backup) separately if you also want its full backup features.

## Uninstall

Delete `.adds/nickel-hs/notes/` and `.adds/nm/hsNotes`. Keep the shared `.adds/nickel-hs/HsKobo.sqlite`, `sqlite3`, `lib/`, and `backup/` files if hs-kobo-backup or another HS Kobo tool uses them. Exported files under `/mnt/onboard/note/` are user data and can be removed separately.
