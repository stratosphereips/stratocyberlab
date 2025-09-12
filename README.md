<h1 align="center">StratoCyberLab</h1>

<p align="center">
  <img src="https://github.com/stratosphereips/BSY-playground/assets/26445918/1898de8c-840f-46a5-ad73-fca0b9b84c14" alt="Logo" width="200"/>
</p>


StratoCyberLab (SCL) is a local cyber range to test and practice your offensive and defensive cybersecurity skills. It was developed by the [Stratosphere Laboratory](https://www.stratosphereips.org/) with two primary goals:

* To allow anyone to run local capture the flag challenges (_think HackTheBox but local in your computer!_)
* To setup local security environments for students of [Introduction to Security class](https://cybersecurity.bsy.fel.cvut.cz/) to follow weekly classes and practice hacking.

<br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/d0164304-c7b2-4f3a-8ac9-2bfcbc52e573" alt="Logo" width="800"/>
</p>

[See a demo video on Youtube!](https://www.youtube.com/watch?v=dkNBveT3Sqg) 

## Features
* Local-only. No cloud. No tracking. No login. No data collection.
* Many cybersecurity exercises in a form of CTF 'challenges'.
* Predefined environments of networks and services for students of [Introduction to Security class](https://cybersecurity.bsy.fel.cvut.cz/)
* The lab runs using docker containers on a shared virtual network(s)
* A container is created for the user to start from. You can install any tool you want without modifying your own host computer.
* A web interface to manage the challenges and play.
* All the challenges can be played from the web interface using the built-in WebSSH terminal.
* AI-assisted. The web interface has a local LLM chat (using _ollama_) to assist in your hacking. You can choose any ollama model.

## Requirements

### Hardware
Resource consumption depends a lot on the user actions. We do not recommend starting all challenges at once
as this may require a lot compute by generating a lot of network traffic and starting many services.

However, we estimate the minium requirements to be **3GB of disk** space and **2GB of spare RAM**. (Note that downloading the LLM model will require extra disk space depending on the model)   

### Software
The only requirement to run SCL is to have `docker (v>20.10)` installed.

## How to start

1.  To start the lab do:
```bash
git clone https://github.com/stratosphereips/stratocyberlab.git
cd stratocyberlab
docker compose up
```

This uses the already prepared [docker-compose.yml](./docker-compose.yml) file to start 3 services:
* hackerlab - a container with SSH and core utilities for hacking
* dashboard - a web interface to start/stop challenges, submit flags, control ollama, etc.
* ollama - a container that optionally handles the local LLM models

2. After the lab bootstraps, navigate in your browser to [http://127.0.0.1/](http://127.0.0.1/) to access a lab's dashboard. 

3. Read the welcome message and solve a hello world challenge to verify your setup is working correctly.

4. Hack the world!

### Troubleshooting

**Q: I pulled new updates but the lab is running the old version.**

**A:** Depending on the changes, sometimes it's required to force docker to re-build and/or restart the containers. Please run the lab using a command `docker compose up --build --force-recreate`.  

**Q: I see _REMOTE HOST IDENTIFICATION_ warning when trying to SSH into the hackerlab container**

**A:** The ID of hackerlab container is re-generated when the container is recreated. Add `-o UserKnownHostsFile=/dev/null` option to your SSH command to fix the issue.

**Q: I have a windows OS and the challenges are not working correctly for me**

**A:** Git for Windows puts _CRLF_ line endings to checkout files by default which may break some desinged functionality. Please either replace all the _CRLF_ line endings with _LF_ or set this behaviour globally to your git using these commands (note that you have to re-clone the repository again after making this change to take effect)
```bash
git config --global core.autocrlf false
git config --global core.eol lf
```

## Development

We appreciate all **PRs** with **new challenges** or bug fixes.

Please refer to a separate Development documentation at [./docs/development.md](./docs/development.md).

## Connection Architecture

Diagram WIP
