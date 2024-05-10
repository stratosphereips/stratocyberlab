# How to add a challenge

* Every challenge has its own directory in the [/challenges/](./../challenges/) directory
* Every challenge can have 1 to N tasks. Each task is solved by submitting an appropriate flag.
* To create a new challenge, use a template at [/challenges/template](./../challenges/template/) directory. Every challenge directory should contain:
    * `meta.json` file that specifies metadata of the challenge such as name, id, description, difficulty and all tasks with flags. The file is used by the dashboard server to show tasks' descriptions and to verify submitted flags.
    * `auto_solve.sh` bash script that tests challenge functionality. This script is automatically imported by the root [run_tests.sh](./../run_tests.sh) script and is run from the hackerlab container. The script should try to retrieve the flag and submit the flag in the dashboard via an API.
    * `Dockerfile` that specifies an image used for the challenge
    * `README.md` with simple description of the challenge and a section with steps how to solve the challenge
    * other source code files with the challenge logic
*  After a new challenge is implemented, add a record to:
    * [/docker-compose.yml](./../docker-compose.yml) file to include the challenge in the playground
    * add basic information about the challenge to challenges table in the root README.md file
 
