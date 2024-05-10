# BSY-playground

The goal of the BSY Playground is to allow students to download and locally use security environments to test their skills and tools in the form of challenges.

## Challenges


| Challenge name                                       | Difficulty | IP address    | Tags  |
|------------------------------------------------------|------------|---------------|-------|
| [Hello world](./challenges/hello-world/)             | Easy       | `172.20.0.5`  |       |
| [Famous Quotes LFI](./challenges/famous-quotes-lfi/) | Medium     | `172.20.0.10` |       |
| [What's the date?](./challenges/what-is-the-date/)   | Hard       | `172.20.0.30` |       |


## Requirements

* Docker
* Bash _(just for testing)_

## How to play


The BSY Playground Network is `172.20.0.0/24`, and all the services and challanges are in the same network.

* Start the playground using `docker-compose up` 
* Connect to your hackerlab via SSH to solve the challenges: `ssh root@172.20.0.2`, password `ByteThem123`
* Access the dashboard to find challenges' descriptions by navigating to your browser to [http://172.20.0.3/](http://172.20.0.3/)
* Search for flags in format `bsy{...}` if not specified otherwise in challenge description
* Have fun!

#### Troubleshooting

##### I get _REMOTE HOST IDENTIFICATION_ warning when trying to SSH into the hackerlab container
* add `-o UserKnownHostsFile=/dev/null` flag to your SSH command

## Development

### Adding a challenge

Please refer to a How to add a challenge doc [./docs/adding_challenge.md](./docs/adding_challenge.md)

### Testing

To test all challenges, use script `run_tests.sh`. The script fires up all challenges and runs all existing auto-solve.sh scripts.
