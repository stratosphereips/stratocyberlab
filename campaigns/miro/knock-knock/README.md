# Knock Knock

This challenge focuses on **forensics and analysis** to investigate suspicious activity.
Students must analyze a packet capture to identify an inbound connection and examine logs to determine when _critical_ files were accessed or modified.

## Skills Used

1. **Packet Capture Analysis**: Using Wireshark/tshark to analyze network traffic and identify connections and their origins
1. **Log File Analysis**: Parsing filesystem monitoring logs to extract file operation timestamps

## Learning Objectives

- Develop skills in **network traffic analysis** using packet capture tools
- Learn to **extract forensic evidence** from network and filesystem logs
- Understand how to **correlate events** across different data sources
- Practice **incident investigation** techniques using real-world artifacts

## How to solve

<details>
  <summary>Click to reveal how to solve steps</summary>
1. Download both files linked from the `http://repository/dashboard`
2. From the pcap, find the IP address initiating the SSH connection
3. From the fs log, find the timestamp of `file.txt` being written
</details>
