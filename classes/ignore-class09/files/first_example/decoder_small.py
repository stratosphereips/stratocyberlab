import gzip

def find_sizes(line: bytes):

    # Find the first occurence of the zero byte
    off1 = line.find(b"\x00")

    # Convert the bytes to an integer
    size1 = int(line[:off1])

    # Find the second occurence of the zero byte
    off2 = line[off1 + 1:].find(b"\x00")

    # Convert the bytes to an integer
    size2 = int(line[off1 + 1 : off1 + 1 + off2])

    # Calculate the offset of the first part
    offset = off1 + off2 + 2
    return size1, size2, offset

# Read the log one line at a time
with open("small_data.log", "r") as f:
    log_data = f.readlines()

# Go through each line (packet) and gunzip its contents
for line in log_data:
    # Convert hex string to byte array
    byte_stream = bytes.fromhex(line.strip())

    try:
        # Calculate the sizes of the two parts and the offset of the first part
        size1, size2, offset = find_sizes(byte_stream)

        # Store the bytes of each part
        part1 = byte_stream[offset:offset + size1]
        part2 = byte_stream[offset + size1:offset + size1 + size2]

        # Decompress the gzip parts and print them
        print(f"Part 1: {gzip.decompress(part1)}")
        print(f"Part 2: {gzip.decompress(part2)}")
    except:
        # Maybe some of the packets do not follow the pattern
        print("Not gzipped")
