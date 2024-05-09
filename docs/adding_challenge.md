# How to add a challenge

TODO
* Every challenge has its own directory in the [/challenges/](./../challenges/) directory
* Use a template at [/challenges/template](./../challenges/template/) to create a new challenge directory. Every challenge directory should contain:
    * `meta.json` file that is used by the dashboard server to show tasks' descriptions and to verify submitted flags
    * `auto_solve.sh` bash script that tests challenge functionality
    * `Dockerfile` that specifies an image used for the challenge
*  After challenge is implemented, add a record to:
    * [/docker-compose.yml](./../docker-compose.yml) file to include the challenge in the playground
    * add basic information about the challenge to challenges table in main repo README
 
