# Knock Knock

Packet capture and log analysis.

TODO: there might be an issue with DNS resolutions.
The hackerlab seems to like the SCL dashboard more than the challenge one.
A hostname change might be worth it.

## How to solve

1. Download both files linked from the dashboard
2. From the pcap, find the IP address initiating the SSH connection
3. From the fs log, find the timestamp of `file.txt` being written
