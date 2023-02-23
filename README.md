# WoW CSV From DB2

DB2 files are the client side databases containing data about items, NPCs, environment, world and a lot more.

This repository contains the raw DB2 files their respective CSV version efficient use by WoW meta tooling.

# Usage: Adding a New Version

To add a new build version to this repository, first clone this repository and then follow these steps:

1. Create a new directory with the name of the build version (e.g. `10.0.5.48069/`) under `versions/`.
2. Create a directory named `db2/` under that specific version and populate this with the DB2 files of the build. I use [wow.export](https://github.com/Kruithne/wow.export) to do this.
3. Copy the latest hotfix file (`DBCache.bin`) to the `db2/` directory. The hotfix file can be found in your local installation under `<path_to_your_local_installation>/World of Warcraft/_retail_/Cache/ADB/enUS/DBCache.bin`.
4. To summarize so far, there should be a new directory under `versions/` with a subdirectory `db2` that contains the DB2 files and the hotfix file.
5. Call the script `./add-new-version/generate-csvs.sh <build_name>` where build name is the name of the new directory. Example: `./add-new-version/generate-csvs.sh <build_name> 10.0.5.48069`.
6. The script will check out the latest versions of the submodules, build the submodules and start generating the CSV files.
7. Commit the changes.

# Acknowledgements

This repository would not be possible without the following tools:

* https://github.com/Kruithne/wow.export
* https://github.com/Marlamin/DBC2CSV

# Disclaimer

This repository is maintained by an enthousiastic WoW player and there are no guarantees this will be 100% up-to-date forever, although it is my aim.

Feel free to contribute by opening issues and creating PRs.
