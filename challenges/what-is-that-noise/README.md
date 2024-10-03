# Challenge template

Challenge testing sniffing content of incoming packets

### Task

Find who is trying to communicate with you. What are they saying?

## How to solve
<details>
  <summary>Click to reveal how to solve steps</summary>

1. Somebody tries to communicate with us. We need to capture the traffic and see what's going on then.
```bash
root@hackerlab:~# tcpdump -i eth0 -n -s0 -v
...
```
2. We notice there is a lot of noise so we should try to capture TCP,UDP,ICMP separately. After capturing ICMP, we notice a weird pattern
```
root@hackerlab:~# tcpdump -i eth0 -n -s0 -v -A "icmp"
tcpdump: listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
09:57:07.755759 IP (tos 0xc0, ttl 64, id 37612, offset 0, flags [none], proto ICMP (1), length 56)
    172.20.0.2 > 172.20.0.35: ICMP 172.20.0.2 udp port 18837 unreachable, length 36
        IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto UDP (17), length 28)
    172.20.0.35.53 > 172.20.0.2.18837: domain [length 0 < 12] (invalid)
E..8....@..........#..Ud....E.......@."....#.....5I...].
09:57:07.875286 IP (tos 0xc0, ttl 64, id 37619, offset 0, flags [none], proto ICMP (1), length 56)
    172.20.0.2 > 172.20.0.35: ICMP 172.20.0.2 udp port 43898 unreachable, length 36
        IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto UDP (17), length 28)
    172.20.0.35.53 > 172.20.0.2.43898: domain [length 0 < 12] (invalid)
E..8....@..........#..Ud....E.......@."....#.....5.z....
09:57:09.333759 IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto ICMP (1), length 93)
    172.20.0.35 > 172.20.0.2: ICMP echo request, id 0, seq 0, length 73
E..]....@."R...#............OFL{l5egjrfqbvehsjrvbeqfghsbvrheqsbvqfhjr45423344255342343yyyyjj}
09:57:09.333797 IP (tos 0x0, ttl 64, id 37938, offset 0, flags [none], proto ICMP (1), length 93)
    172.20.0.2 > 172.20.0.35: ICMP echo reply, id 0, seq 0, length 73
E..].2..@.. .......#........OFL{l5egjrfqbvehsjrvbeqfghsbvrheqsbvqfhjr45423344255342343yyyyjj}
```
3. Pattern `OFL{l5egjrfqbvehsjrvbeqfghsbvrheqsbvqfhjr45423344255342343yyyyjj}` has 3 capital letters 
and curly brackets just as the format of flags. String `OFL` is just 13 characters shifted from `BSY` so this is rot13 encoding. After [decoding](https://gchq.github.io/CyberChef/#recipe=ROT13(true,true,false,13)&input=T0ZMe2w1ZWdqcmZxYnZlaHNqcnZiZXFmZ2hzYnZyaGVxc2J2cWZoanI0NTQyMzM0NDI1NTM0MjM0M3l5eXlqan0), we get a flag `BSY{y5rtwesdoirufweiordstufoieurdfoidsuwe45423344255342343llllww}`


</details>

## Testing

The script [auto-solve.sh](./auto-solve.sh) automatically verifies that the challenge can be solved.
