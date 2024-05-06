# BSY-playground

TODO: write about section

## Challenges


| Challenge name                            | ID            |  Difficulty  | IP address   | Tags  |
|-------------------------------------------|---------------|--------------|--------------|-------|
| [Hello world](./challenges/hello-world/)  | hello-world   | Very easy    | `172.20.0.3` |       |
| [Famous Quotes LFI](./challengesfamous-quotes-lfi/)  | famous-quotes-lfi   | Easy    | `172.20.0.10` |       |


## Requirements

* Bash
* Docker

## Usage

TODO

* Flag format `bsy{...}`
* SSH root credentials to hackerlab `root:ByteThem123`
* network is `172.20.0.0/24`
* run via `docker-compose up`

## Development

### Adding a challenge

Please refer to a How to add a challenge doc [./docs/adding_challenge.md](./docs/adding_challenge.md)

### Testing

To test all challenges, use script `run_tests.sh`. The script fires up all challenges and runs all existing auto-solve.sh scripts.
