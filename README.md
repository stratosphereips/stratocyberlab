<h1 align="center">StratoCyberLab</h1>

<p align="center">
  <img src="https://github.com/stratosphereips/BSY-playground/assets/26445918/1898de8c-840f-46a5-ad73-fca0b9b84c14" alt="Logo" width="200"/>
</p>


StratoCyberLab is an offline security cyber range to test your knowledge and capabilities on cybersecurity. It was developed by the [Stratosphere Laboratory](https://www.stratosphereips.org/) with two primary goals:

* To setup local-only security environments for remote students of [Introduction to Security class](https://cybersecurity.bsy.fel.cvut.cz/) to follow weekly classes.
* To allow anyone to run local-only realistic cyber range to practice attacking & defending skills in the form of challenges (_think HackTheBox but local in your computer!_)

<br>


<p align="center">
  <img src="https://github.com/user-attachments/assets/842b6364-c682-4227-a012-d656694d91af" alt="Logo" width="800"/>
</p>

[See a demo video on Youtube!](https://www.youtube.com/watch?v=dkNBveT3Sqg) 

## Features
* Local-only. No internet is required after download. No cloud. No tracking. No login. No data collection.
* Many cybersecurity exercises in a form of 'challenges'.
* Predefined environments of networks and services for remote students of [Introduction to Security class](https://cybersecurity.bsy.fel.cvut.cz/)
* The lab runs using docker containers on a shared virtual network(s)
* A container is created for the user to start from. You can install any tool you want without modifying your own host computer.
* A web interface to manage the challenges and play.
* All the challenges can be played from the web interface using the built-in WebSSH terminal.
* AI-assisted. The web interface has a local LLM (using _ollama_) to assist in your hacking. You can change the model used.

## Requirements

### Hardware
Resource consumption depends a lot on the user actions. We do not recommend starting all challenges at once
as this may require a lot compute by generating a lot of network traffic and starting many services.

However, we estimate the minium requirements to be **3GB of disk** space and **2GB of spare RAM**. (Note that downloading the LLM model will require extra 5GB of disk space)   

### Software
The only requirement to run StratoCyberLab is to have `docker (v>20.10)` installed.

## How to start



To start the lab do:
```bash
git clone https://github.com/stratosphereips/stratocyberlab.git
cd stratocyberlab
docker compose up
```

This uses the already prepared [docker-compose.yml](./docker-compose.yml) file.


After the lab bootstraps, navigate in your browser to [http://127.0.0.1/](http://127.0.0.1/) to access a lab's dashboard. 

The dashboard contains:
* Predefined environments for each weekly class of [Introduction to Security class](https://cybersecurity.bsy.fel.cvut.cz/) for remote students
* List of standalone hacking challenges 
    * Challenges are divided by difficulty into 3 categories `EASY`, `MEDIUM`, `HARD`
    * Each challenge has multiple tasks. 
    * Tasks are solved by finding a flag (usually in a format `BSY{...}`) and submitting the flag in the dashboard.
    * Each challenge must be individually started from the dashboard before playing
* Chat with a local AI assistant using `llama3` model
    * Usage and downloading of the model is optional and can be initiated from the dashboard. By default no model is downloaded.
* Built-in SSH web shell to interact with deployed services in the lab
    * The SSH connection is made to a `hackerlab` container. 
    * If preferred, you can connect directly using SSH from your terminal to the `hackerlab` container with command
`ssh root@127.0.0.1 -p 2222` and password `ByteThem123`


### Troubleshooting

**Q: I pulled new updates but the lab is running the old version.**

**A:** Depending on the changes, sometimes it's required to force docker to re-build the containers. Please run the lab using a command `docker compose up --build` 


**Q: I see _REMOTE HOST IDENTIFICATION_ warning when trying to SSH into the hackerlab container**

**A:** The ID of hackerlab container is re-generated when the container is recreated. Add `-o UserKnownHostsFile=/dev/null` option to your SSH command to fix the issue.

## Development

We appreciate all **PRs** with **new challenges** or bug fixes.

Please refer to a separate Development documentation at [./docs/development.md](./docs/development.md).

## Documentation on adaptations

If you want to use a new LLM model follow the instructions [here](https://github.com/stratosphereips/stratocyberlab/blob/main/docs/add-new-llm-model.md)
