#!/bin/bash

input_file=$1
output_file="image_info.txt"

# Check if the file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: '$input_file' not found."
    exit 1
fi

# Get file information
file_name=$(basename "$input_file")
file_size=$(stat --format="%s" "$input_file")
size_in_mib=$(echo "scale=2; $file_size / 1048576" | bc)  # Convert bytes to MiB

# Calculate CRC32 using cksum
crc32=$(cksum "$input_file" | awk '{print $1}')

# Calculate SHA256
sha256=$(sha256sum "$input_file" | awk '{print $1}')

# Calculate SHA1
sha1=$(sha1sum "$input_file" | awk '{print $1}')

# Calculate MD5
md5=$(md5sum "$input_file" | awk '{print $1}')

# Calculate XXH64 (XXHash64)
xxh64=$(xxhsum -H64 "$input_file" | awk '{print $1}')

# Calculate SHA384
sha384=$(sha384sum "$input_file" | awk '{print $1}')

# Calculate SHA512
sha512=$(sha512sum "$input_file" | awk '{print $1}')

# Calculate SHA3-256
sha3_256=$(python3 -c "import hashlib; print(hashlib.sha3_256(open('$input_file', 'rb').read()).hexdigest())")

# BLAKE2sp - using Python script (install `hashlib` if needed)
blake2sp=$(python3 -c "import hashlib; print(hashlib.blake2b(open('$input_file', 'rb').read()).hexdigest())")

# Write to output file
{
    echo "Name: $file_name"
    echo "Size: $file_size bytes : $size_in_mib MiB"
    echo "CRC32: $crc32"
    echo "SHA256: $sha256"
    echo "SHA1: $sha1"
    echo "MD5: $md5"
    echo "XXH64: $xxh64"
    echo "SHA384: $sha384"
    echo "SHA512: $sha512"
    echo "SHA3-256: $sha3_256"
    echo "BLAKE2sp: $blake2sp"
} > "$output_file"

echo "Information saved to $output_file"
