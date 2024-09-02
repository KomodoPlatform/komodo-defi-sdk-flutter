#!/bin/bash

# Store path of the output file
output_file="all_files_combined.txt"

# Define included and excluded paths as variables
included_extensions=("*.dart" "*.md" "*.yaml")
excluded_paths=("./**/.dart_tool" "./**/build" "./**/.fvm")

# Check if at least one file or directory is passed as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file/directory> [<file/directory> ...]"
    exit 1
fi

# If the file exists and isn't empty, ask the user if they want to overwrite,
# append, or cancel (default).
if [ -s "$output_file" ]; then
    echo "The file $output_file already exists and is not empty."
    echo "Would you like to overwrite, append, or cancel (default)?"
    select option in "Overwrite" "Append" "Cancel"; do
        case $REPLY in
            1)  # Overwrite
                echo "Overwriting $output_file..."
                > "$output_file"  # Properly clears the file
                break
                ;;
            2)  # Append
                echo "Appending to $output_file..."
                break
                ;;
            3 | "")  # Cancel if option is 3 or input is empty
                echo "Exiting..."
                exit 0
                ;;
            *)  # Handle invalid input
                echo "Invalid option. Please choose again."
                ;;
        esac
    done
fi

# Process each file or directory passed as an argument
for input in "$@"; do
    if [ -d "$input" ]; then
        # Input is a directory, apply the find command
        find "$input" \
            \( -path "${excluded_paths[0]}" -o -path "${excluded_paths[1]}" -o -path "${excluded_paths[2]}" \) -prune -o \
            \( -name "${included_extensions[0]}" -o -name "${included_extensions[1]}" \) -type f -print | \
        while read -r file; do
            echo "===== $file =====" >> "$output_file"
            cat "$file" >> "$output_file"
            echo -e "\n" >> "$output_file"
        done
    elif [ -f "$input" ]; then
        # Input is a file, check its extension and process it
        for ext in "${included_extensions[@]}"; do
            if [[ "$input" == $ext ]]; then
                echo "===== $input =====" >> "$output_file"
                cat "$input" >> "$output_file"
                echo -e "\n" >> "$output_file"
                break
            fi
        done
    else
        echo "Warning: $input is not a valid file or directory. Skipping..."
    fi
done

echo "Processing complete. Output written to $output_file."
