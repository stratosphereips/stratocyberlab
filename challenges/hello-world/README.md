# Hello-world

Simple initial challenge to verify that the environment is working correctly.

### Task
Find an HTTP server at IP address `172.20.0.5` and retrieve a flag.

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>


1. Use `nmap` to find opened ports:
```bash
root@hackerlab:~# nmap -sS -n -v 172.20.0.5   
...
PORT     STATE SERVICE
8000/tcp open  http-alt
MAC Address: 02:42:AC:14:00:03 (Unknown)
...
```

2. Discover opened port 8000 and try to send an HTTP request
```bash
root@hackerlab:~# curl 172.20.0.5:8000 
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello world</title>
</head>
<body>
    Congratulations, you found a flag for the hello-world challenge. 
    Your setup seems to be working, happy hacking!
    
    BSY{simple-hello-world-flag}
</body>
</html>
```


</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
