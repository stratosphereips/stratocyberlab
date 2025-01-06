# Development

## How to implement a new challenge

* Every challenge has its own directory in the [/challenges](./../challenges/) directory
* Every challenge has at-least 1 task. Each task is solved by submitting a correct flag.

### Adding a challenge

* Create a new directory in the [/challenges](./../challenges/) directory (preferably copy and update a prepared
  challenge template located at [/challenges/template](./../challenges/template/))
* Create/update mandatory files:
    * `meta.json` specifies metadata of the challenge such as name, id, description, difficulty and all tasks with
      appropriate flags. The file is used by the dashboard server to show tasks' descriptions and to verify submitted
      flags.
    * `docker-compose.yml` defines services started for the challenge when user starts the challenge from the dashboard
        * Use external network `playground-net` to connect a container to the base lab network
        * Assign a static IP address to every service. Look below to a table of IP allocations, choose free IP and add a
          record to the table.
        * Ideally set `stop_grace_period: 0s` for all services to speed-up stopping of containers
    * `README.md` with simple description of the challenge and a section with steps how to solve the challenge
    * `auto_solve.sh` bash script that tests challenge functionality. This script is automatically imported by the
      root [run_tests.sh](./../run_tests.sh) script and is executed from the hackerlab container. The script should
      ideally perform all required steps to solve all tasks and submit the flags in the dashboard via an API.
    * optional other source code, data or docker files for the challenge
* To test the new challenge, run the lab using command `docker compose up --force-recreate` so the dashboard loads the
  new challenge information

## How to add a new class environment

* Create a new class directory in the [/classes](./../classes/) directory
* Create files:
    * `meta.json` specifies metadata such as name, id and a description shown to the user in the web dashboard
    * optional `docker-compose.yml` file
        * if present, the dashboard offers to start the defined services
        * Use external network `playground-net` to connect a container to the base lab network
        * Assign a static IP address to every service. Look below to a table of IP allocations, choose free IP and add a
          record to the table.
        * Ideally set `stop_grace_period: 0s` for all services to speed-up stopping of containers
    * optional other source code, data or docker files needed for the class

## Networking

| Network        | Subnet        |
|----------------|---------------|
| playground-net | 172.20.0.0/24 |  

#### IP allocations

| Network        | IP address     | Used By                                                                                  | 
|----------------|----------------|------------------------------------------------------------------------------------------|
| playground-net | `172.20.0.5`   | Challenge [Hello world](./../challenges/hello-world/)                                    |
| playground-net | `172.20.0.10`  | Challenge [Famous Quotes LFI](./../challenges/famous-quotes-lfi/)                        |
| playground-net | `172.20.0.30`  | Challenge [What's the date?](./../challenges/what-is-the-date/)                          |
| playground-net | `172.20.0.35`  | Challenge [What's that noise?](./../challenges/what-is-that-noise/)                      |
| playground-net | `172.20.0.39`  | Challenge [Shockwave Report](./../challenges/shockwave-report)                           |
| playground-net | `172.20.0.41`  | Challenge [Intrusion](./../challenges/intrusion)                                         |
| playground-net | `172.20.0.45`  | Challenge [Jump Around](./../challenges/jump-around)                                     |
| playground-net | `172.20.0.47`  | Challenge [Jump Around](./../challenges/jump-around)                                     |
| playground-net | `172.20.0.49`  | Challenge [Jump Around](./../challenges/jump-around)                                     |
| playground-net | `172.20.0.67`  | Challenge [Leet Messenger](./../challenges/leet-messenger)                               |
| playground-net | `172.20.0.52`  | Challenge [Cybernet](./../challenges/cybernet)                                           |
| playground-net | `172.20.0.88`  | [Class02](./../classes/class02)                                                          |                                                
| playground-net | `172.20.0.90`  | [Class03](./../classes/class03)                                                          |                                                
| playground-net | `172.20.0.95`  | [Class03](./../classes/class03)                                                          |  
| playground-net | `172.20.0.98`  | [Class06](./../classes/class06)                                                          |  
| playground-net | `172.20.0.99`  | [Class06](./../classes/class06)                                                          |  
| playground-net | `172.20.0.108` | [Class07](./../classes/class07)                                                          |
| playground-net | `172.20.0.110` | [Class07](./../classes/class07)                                                          |
| playground-net | `172.20.0.115` | [Class08](./../classes/class08)                                                          |
| playground-net | `172.20.0.120` | [Class09](./../classes/class09)                                                          |
| playground-net | `172.20.0.125` | [Class10](./../classes/class10)                                                          |
| playground-net | `172.20.0.130` | [Class10](./../classes/class10)                                                          |
| playground-net | `172.20.0.131` | [Class10](./../classes/class10)                                                          |
| playground-net | `172.20.0.132` | [Class10](./../classes/class10)                                                          |
| playground-net | `172.20.0.101` | [Class11](./../classes/class11)                                                          |  
| playground-net | `172.20.0.102` | [Class12](./../classes/class12)                                                          |  
| playground-net | `172.20.0.103` | [Class12](./../classes/class12)                                                          |  
| playground-net | `172.20.0.104` | [Class12](./../classes/class12)                                                          |  
| playground-net | `172.20.0.105` | [Class12](./../classes/class12)                                                          |  
| playground-net | `172.20.0.106` | [Class13](./../classes/class13)                                                          |  
| playground-net | `172.20.0.107` | [Class13](./../classes/class13)                                                          |
| playground-net | `172.20.0.108` | [Class13](./../classes/class13)                                                          |
| playground-net | `172.20.0.109` | [Class13](./../classes/class13)                                                          |
| playground-net | `172.25.0.1`   | [Class13](./../classes/class13)                                                          |
| playground-net | `172.25.0.2`   | [Class13](./../classes/class13)                                                          |
| playground-net | `172.25.0.3`   | [Class13](./../classes/class13)                                                          |
| playground-net | `172.25.0.4`   | [Class13](./../classes/class13)                                                          |
| playground-net | `172.20.0.110` | [Class14](./../classes/class14)                                                          |
| playground-net | `172.20.0.134` | [ssh-server](./../classes/class14/ssh-server)                                            |
| playground-net | `172.20.0.133` | [attacker](./../classes/class14/attacker)                                                |
| playground-net | `172.20.0.200` | Reserved for campaign [miro](./../campaigns/miro)                                        |
| playground-net | `172.20.0.201` | Campaign challenge [miro/bearific](./../campaigns/miro/bearific)                         |
| playground-net | `172.20.0.202` | Campaign challenge [miro/bearific](./../campaigns/miro/bearific)                         |
| playground-net | `172.20.0.203` | Campaign challenge [miro/forgot-your-password](./../campaigns/miro/forgot-your-password) |
| playground-net | `172.20.0.204` | Campaign challenge [miro/forgot-your-password](./../campaigns/miro/forgot-your-password) |
| playground-net | `172.20.0.205` | Campaign challenge [miro/meme-jpeg](./../campaigns/miro/meme-jpeg)                       |
| playground-net | `172.20.0.231` | Campaign challenge [miro/corporate-retreat](./../campaigns/miro/corporate-retreat)       |
| playground-net | `172.20.0.239` | Campaign challenge [miro/corporate-retreat](./../campaigns/miro/corporate-retreat)       |
| playground-net | `172.20.0.249` | Campaign challenge [miro/by-the-pool](./../campaigns/miro/by-the-pool)                   |
| playground-net | `172.20.0.250` | Campaign challenge [miro/by-the-pool](./../campaigns/miro/by-the-pool)                   |


## Testing

To run all tests, use script `run_tests.sh`. The script starts the lab, fires up all challenges and runs all existing
`auto-solve.sh` scripts from within the hackerlab container.

## Code quality

We use linters and auto formatters to maintain code quality in this repository.
Currently, this is only the case for the dashboard (client and server).
Please refer to the READMEs in the respective directories for instructions.

When introducing new code for challenges or classes, we recommend following the same guidelines.
