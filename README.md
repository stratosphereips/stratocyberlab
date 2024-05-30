<h1 align="center">BSY-playground </h1>

<p align="center">
  <img src="https://github.com/stratosphereips/BSY-playground/assets/26445918/1898de8c-840f-46a5-ad73-fca0b9b84c14" alt="Logo" width="200"/>
</p>



The goal of the BSY Playground is to allow students to download and locally use security environments to test their skills and tools in the form of challenges.

[See a demo video on Youtube!](https://www.youtube.com/watch?v=dkNBveT3Sqg) 

## Challenges


| Challenge name                                       | Difficulty | IP address    | Tags  |
|------------------------------------------------------|------------|---------------|-------|
| [Hello world](./challenges/hello-world/)             | Easy       | `172.20.0.5`  |       |
| [Famous Quotes LFI](./challenges/famous-quotes-lfi/) | Medium     | `172.20.0.10` |       |
| [What's the date?](./challenges/what-is-the-date/)   | Hard       | `172.20.0.30` |       |


## Requirements

* Docker (v>20.10)
* Bash _(just for testing)_

## How to play

* Start the playground using `docker compose up` command 
* Access the dashboard to find challenges' descriptions by navigating to your browser to [http://172.20.0.3/](http://172.20.0.3/)
* Use dashboard SSH terminal or connect directly to the hackerlab using SSH with `ssh root@172.20.0.2` and password `ByteThem123`
* Search for flags in format `bsy{...}` if not specified otherwise in challenge description
* Have fun!

The BSY Playground Network is `172.20.0.0/24`, and all the services and challenges are in the same network.

#### Troubleshooting

##### I get _REMOTE HOST IDENTIFICATION_ warning when trying to SSH into the hackerlab container
* add `-o UserKnownHostsFile=/dev/null` flag to your SSH command

## Development

### Adding a challenge

Please refer to a How to add a challenge doc [./docs/adding_challenge.md](./docs/adding_challenge.md)

### Testing

To test all challenges, use script `run_tests.sh`. The script fires up all challenges and runs all existing auto-solve.sh scripts.
