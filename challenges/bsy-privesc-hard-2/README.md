# Blackglass Build Node

Blackglass Dynamics' overnight build server is still humming after a release run went sideways. You have ordinary account access to the machine; the release authorization token and its integrity marker are reserved for the root operator.

Your goal is to reach root, recover the token, and verify the paired marker. This challenge runs on the lab network at `172.20.0.147`. Scan `172.20.0.0/24`; challenge hosts are in `172.20.0.141-199`. SSH credentials are provided in the challenge access details.

The build logs are quiet. The host's permissions may tell a louder story.
