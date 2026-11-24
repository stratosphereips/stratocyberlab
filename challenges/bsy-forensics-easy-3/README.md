# Neon Runner: quiet after midnight

A CI runner in a neon corporate datacenter may have been compromised. You already have authorized access to the host; reconstruct what happened and recover the flag from the genuine planted artifact.

The challenge runs on the lab network. Scan `172.20.0.0/24`; challenge hosts are in `172.20.0.141-199`. Review the host's accounts, authentication and system logs, scheduled jobs, timestamps, sudo activity, and shell histories. Separate ordinary runner activity from the intrusion.