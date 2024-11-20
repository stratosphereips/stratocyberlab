# Leet Messenger

This challenge has 2 phases.

In the first one, students are told someone is trying to speak with them. They should start capturing packets. They should
notice there is a lot of TCP SYN packets coming to a port 1337 (leet). But there is no listener. After starting a TCP listener on
port 1337, they will get a payload. 

The payload has a custom protocol format. The format is

```
MAGIC_NUMBER (4 bytes) | VERSION (1 byte) | LEN_OF_MSG (8 bytes) | BASE_64_MSG_DATA | LEN_OF_DATA (8 bytes) | DATA
```

The base64 encoded message contains a first flag and also hint to keep digging.

The data section contains raw bytes which is a gz compressed ELF 64 bits executable file. Students should extract the
data, gunzip the file and reverse engineer the binary. By reversing the binary, students should find a correct input to the
binary which passes the implemented check. If they succeed, the binary prints that this is a correct input and that the input is
also a 2nd flag. 

Voilá.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

  TODO: write proper how to solve

  1. start ncat listener and pipe the received data to a file
```bash
root@hackerlab:~# nc -lnvp 1337 > received.data
Ncat: Version 7.93 ( https://nmap.org/ncat )
Ncat: Listening on :::1337
Ncat: Listening on 0.0.0.0:1337
Ncat: Connection from 172.20.0.67.
Ncat: Connection from 172.20.0.67:49948.
```

  2. decode the base64 encoded message to find 1st flag
```bash
root@hackerlab:~# strings received.data | head -n1 | base64 -d
Oh finally you hear me!!! This is your flag BSY{a!sk&fjlhý76S5F9OUILFNRQKJLRHIUFKHAS}. Now, you might be interested in the rest of the messagebase64: invalid input```
```

  3. install binwalk, use it to extract the gzip and find the binary. Then use your favorite disassembler (gdb, ida, ghidra, ...) to find the implementation of the check and figure out a correct input (the 2nd flag)
```bash
root@hackerlab:~# binwalk -e received.data --run-as=root

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
213           0xD5            gzip compressed data, has original file name: "binary", from Unix, last modified: 2024-11-20 22:56:19

root@hackerlab:~# ls
_received.data.extracted  received  received.data
root@hackerlab:~# gzip _received.data.extracted/binary^C
root@hackerlab:~# file _received.data.extracted/binary
_received.data.extracted/binary: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=7442f69752d03fa6c11be89b5427782a6879efd9, for GNU/Linux 3.2.0, not stripped
root@hackerlab:~# chmod +x ./_received.data.extracted/binary
root@hackerlab:~# ./_received.data.extracted/binary
Usage: ./_received.data.extracted/binary flag
root@hackerlab:~# ./_received.data.extracted/binary is_this_the_flag?
Incorrect flag. Try harder!
root@hackerlab:~# ./_received.data.extracted/binary iam-reverse-king 
You found it! You can submit the flag, good job :)
```

</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
