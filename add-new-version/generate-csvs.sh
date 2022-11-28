#!/bin/bash

script_location=$(readlink -f "$0")
script_dir=$(dirname "$script_location")

# Check presence of arguments
version=$1
if [ -z "$version" ]; then
    printf "No version name passed.\n\n"
    printf "Usage:\n"
    printf "\t./generate-csvs.sh <version_name>\n"
    printf "Example:\n"
    printf "\t./generate-csvs.sh 10.0.2.46801"
    exit
fi

# Check if version directory exists
version_dir="$script_dir/../versions/$version"
if [ ! -d "$version_dir" ]; then
    printf "Directory $version_dir does not exist.\n\n"
    printf "Create the directory for version $version and a db2/ directory manually,\n"
    printf "populate the db2/ directory with .db2 files and then use this script again."
    exit
fi

# Check if db2/ subdir exists
db2_dir="$version_dir/db2"
if [ ! -d "$db2_dir" ]; then
    printf "Version $version does not have a db2 subdirectory.\n\n"
    printf "Create a subdirectory db2/ under version $version manually,\n"
    printf "populate it with the .db2 files and then use this script again."
    exit
fi

# Check if any .db2 files are present
db2_file_count=`ls -1 $db2_dir/*.db2 2>/dev/null | wc -l`
if [ "$db2_file_count" -eq "0" ]; then
    printf "There are no *.db2 files in the db2/ directory of version $version.\n\n"
    printf "Manually populate the db2/ directory of version $version with .db2 files and then use this script again."
    exit
fi

# Create csv/ directory if it does not yet exist
csv_dir="$version_dir/csv"
if [[ ! -e "$csv_dir" ]]; then
    mkdir $csv_dir
    printf "Created csv/ directory for version $version.\n"
fi

# Check if csv files are already present and ask to overwrite
csv_file_count=`ls -1 $db2_dir/*.db2 2>/dev/null | wc -l`
if [ ! "$csv_file_count" -eq "0" ]; then
    printf "There are already CSV files in the csv/ directory of version $version.\n"

    read -p "Are you sure you want to overwrite the CSV files (y/n)? " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit
    fi
fi

# Pull latest versions of submodules
git submodule update --init --recursive
git submodule update --remote --merge
git submodule update --init --recursive

# Build DBC2CSV
printf "Building DBC2CSV..."
dbc2csv_build_output=$(dotnet build "$script_dir/DBC2CSV/DBC2CSV.sln")

if [[ $dbc2csv_build_output == *"Build succeeded."* ]]; then
    printf "DONE\n"
else
    printf "\n"
    printf "Failed building DBC2CSV.\n"
    printf "Output:\n\n"
    echo "$dbc2csv_build_output"
    exit
fi

# Check if bin exists, sanity check
dbc2csv_dir="$script_dir/DBC2CSV/DBC2CSV/bin/Debug/net7.0"
if [ ! -d "$dbc2csv_dir" ]; then
    printf "Error: Unable to find directory with DBC2CSV executable"
    exit
fi

# Overwrite definitions
printf "Overwriting DBC2CSV definitions with latest..."
definitions_dir="$script_dir/WoWDBDefs/definitions"

if [ ! -d "$definitions_dir" ]; then
    printf "\n"
    printf "Error: Unable to find directory with latest definitions.\n\n"
    printf "It should be located at $definitions_dir"
    exit
fi

overwrite_defs_output=$(cp "${definitions_dir}"/*.dbd "$dbc2csv_dir/definitions/")
if [ -z "$overwrite_defs_output" ]; then
    printf "DONE\n"
else
    printf "\n"
    printf "Failed overwriting definitions.\n"
    printf "Output:\n\n"
    echo "$overwrite_defs_output"
    exit
fi

# Run DBC2CSV
printf "Starting DBC2CSV executable...\n\n"
echo "-------DBC2CSV OUTPUT BEGIN-------"
"$dbc2csv_dir"/DBC2CSV.exe "$db2_dir" | sed 's/^/    /'
echo "--------DBC2CSV OUTPUT END--------"
echo ""

# Move CSV files
printf "Moving CSV files..."
move_csv_files_output=$(mv "$db2_dir"/*.csv "$csv_dir/")

if [ -z "$move_csv_files_output" ]; then
    printf "DONE\n"
else
    printf "\n"
    printf "Failed moving CSV files.\n"
    printf "Output:\n\n"
    echo "$move_csv_files_output"
    exit
fi

printf "\nSuccessfully generated CSV files from DB2 files for version $version!"
