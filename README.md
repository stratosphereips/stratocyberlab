# BSY-playground

TODO: write about section

## Challenges


| Challenge name                                      | Difficulty  | IP address    | Tags  |
|-----------------------------------------------------|-------------|---------------|-------|
| [Hello world](./challenges/hello-world/)            |  Very easy  | `172.20.0.5`  |       |
| [Famous Quotes LFI](./challenges/famous-quotes-lfi/) |  Easy       | `172.20.0.10` |       |


## Requirements

* Docker
* Bash _(just for testing)_

## How to play

TODO 

* Start the playground using `docker-compose up` 
* Network (`172.20.0.0/24`) of services is created with challenges and also 2 special containers:
    * Submission server with simple website and challenges' descriptions - navigate to your browser to [http://172.20.0.3/](http://172.20.0.3/)
    * Your hackerlab to which you can connect via SSH to solve the challenges - `ssh root@172.20.0.2`, password `ByteThem123`
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
