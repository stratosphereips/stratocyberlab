# Build Orbit: ghost in the pipeline

A megacorp build server has been recovered after an intrusion alert. The overnight crew says the machine still builds, but its records may not tell the whole story.

Log in to the compromised host and reconstruct what happened. Your goal is to recover the flag from the intruder's genuine planted artifact. Treat the host as evidence: compare user activity, logs, scheduled work, and file metadata before drawing conclusions.

This challenge runs on the lab network. Scan **172.20.0.0/24**; challenge hosts are in **172.20.0.141-199**.

SSH access:

- Host: `172.20.0.147`
- User: `root`
- Password: `OrbitGlass-44`

No exploit is needed. The box is already accessible for forensic inspection.
