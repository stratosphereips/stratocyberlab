from math import floor
from random import random
import re
import os
from sys import exit

import netmiko

HOST = os.getenv('HOST')
PORT = int(os.getenv('PORT'))
FLAG = "M1r0{fGeeeyhxF399xyjItxBRDKel1QxvuVhVfbVE7CEUUVdFAz4WLXmie2nm0ugs}"
FLAG_LOCATION = "/root/.flag"


def connect(user: str, pwd: str) -> netmiko.BaseConnection:
    return netmiko.ConnectHandler(**{
        'device_type': 'linux',
        'ip': HOST,
        'username': user,
        'port': PORT,
        'password': pwd
    })


is_honeypot_msgs = [
    'Smells like a honeypot.',
    'This can\'t be a real machine!'
]

# mocking messages, printed only sometimes
mocking_msgs = [
    'Are you even trying?'
]


def rand(min, max):
    return floor(random() * (max - min) + min)


def get_honeypot_msg(msg: str):
    return (
        f'echo "{is_honeypot_msgs[rand(0, len(is_honeypot_msgs))]}'
        ' '
        f'{msg}'
        f'{" " + mocking_msgs[rand(0, len(mocking_msgs))] if random() >= 0.5 else ""}"'
    )


def try_login(user, password, msg):
    try:
        print(f'Trying to log in as {user}:{password}')
        c = connect(user, password)
        c.send_command("echo hello")

        echo_msg = get_honeypot_msg(msg)
        print("Succeeded, but shouldn't have!")
        c.send_command(echo_msg)
        # c.disconnect()
        exit(1)
    except netmiko.exceptions.NetmikoAuthenticationException:
        print('Failed (as expected)')


ansi_re = re.compile(r'(?:\x1B[@-_]|[\x80-\x9F])[0-?]*[ -/]*[@-~]')


def run_command(cmd: str):
    print(f'Running {cmd}:')
    out = conn.send_command(cmd)
    # print(bytes(out, 'utf8'))
    out = ansi_re.sub('', out.strip())
    print(out)
    print()
    return out


def try_command(cmd: str, expected_output: str | re.Pattern, error_msg: str, negate=False):
    out = run_command(cmd)
    # print(bytes(expected_output, 'utf8'))

    def check():
        if isinstance(expected_output, re.Pattern):
            val = re.search(expected_output, out)
        else:
            val = expected_output.strip() == out

        if negate:
            return not val
        return val

    if check():
        # print("ok")
        return

    # print("nok")
    conn.send_command(get_honeypot_msg(error_msg))
    exit(1)

#  _ _                            _ _                     _            _   _       _
# ( | )                          ( | )                   | |          | | (_)     | |
#  V V___  ___  ___ _   _ _ __ ___V V    ___ _ __ ___  __| | ___ _ __ | |_ _  __ _| |___
#    / __|/ _ \/ __| | | | '__/ _ \     / __| '__/ _ \/ _` |/ _ \ '_ \| __| |/ _` | / __|
#    \__ \  __/ (__| |_| | | |  __/    | (__| | |  __/ (_| |  __/ | | | |_| | (_| | \__ \
#    |___/\___|\___|\__,_|_|  \___|     \___|_|  \___|\__,_|\___|_| |_|\__|_|\__,_|_|___/


try_login('root', '', 'Empty password on root?')
try_login('root', 'alpine', 'Default credentials?')
# try_login('anonymous', 'anonymous', 'This is not FTP')
try_login('debian', '', 'Who allows empty passwords?')
try_login('debian', 'debian', 'Username and password cannot be the same')
try_login('debian', '1234', 'Bad password: too short')
try_login('debian', 'abcdef', 'Bad password: too weak')
try_login('debian', 'aaaaaaaaaaaaaaaaaa',
          'Bad password: too many similar characters')

# password 'with sufficient entropy'
conn = connect('debian', '345gs5662d34')


#  _               _        _                                        _          _               _
# | |             (_)      | |                                      | |        | |             | |
# | |__   __ _ ___ _  ___  | |__   ___  _ __   ___ _   _ _ __   ___ | |_    ___| |__   ___  ___| | __
# | '_ \ / _` / __| |/ __| | '_ \ / _ \| '_ \ / _ \ | | | '_ \ / _ \| __|  / __| '_ \ / _ \/ __| |/ /
# | |_) | (_| \__ \ | (__  | | | | (_) | | | |  __/ |_| | |_) | (_) | |_  | (__| | | |  __/ (__|   <
# |_.__/ \__,_|___/_|\___| |_| |_|\___/|_| |_|\___|\__, | .__/ \___/ \__|  \___|_| |_|\___|\___|_|\_\
#                                                   __/ | |
#                                                  |___/|_|

# hostname check
try_command('hostname', 'svr04',
            "I've seen that hostname before.", negate=True)
try_command('uname -a', re.compile('.*svr04.*'),
            "I've seen that hostname before.", negate=True)

# ping to a non-routed ip, as per https://stackoverflow.com/a/10456065
try_command('ping -c1 203.0.113.1', re.compile('.*\\n\\d+ bytes from .* (.*): icmp_seq=1 ttl=\\d+ time=\\d+(\\.\\d+)? ms.*'),
            'That IP should not be routed anywhere...', negate=True)

# check fs consistency
conn.send_command('mkdir test')
conn.send_command('echo "hello" > test/test.txt')
try_command('ls -R', re.compile('.*test\\.txt.*'),
            'I just wrote a file... Where did it go?')

try_command('cat test/test.txt', 'hello',
            'I just wrote that file!')  # should pass

# TODO sed, grep

# TODO more from Muris

# TODO https://github.com/boscutti939/Cowrie_Detect

#            _     _
#           (_)   | |
#  ___ _   _ _  __| |
# / __| | | | |/ _` |
# \__ \ |_| | | (_| |
# |___/\__,_|_|\__,_|
# (includes flag writing)

# should pass, but if not, then it's not proof that the system is a honeypot! TODO
try_command('which find', '/usr/bin/find', "I need to use find!")
find_out = run_command('find / -perm -u=s -type f -name "*sh"')
if re.search(".*command not found.*", find_out):
    run_command(get_honeypot_msg(
        'which just told me that /usr/bin/find exists...'))
    exit(1)
sh_match = re.search(".*/.*(?<!ch)sh$", find_out)  # filter out chsh
if not sh_match:
    # run_command('echo "This system is boring. If only there was a shell to run..."')
    exit(1)

shell = sh_match.group(0)
run_command(f"echo 'echo \"{FLAG}\" > {FLAG_LOCATION}' | {shell} -p")

# TODO: whoami uid verification

flag_for_verification = run_command(f'cat {FLAG_LOCATION}')
if flag_for_verification != FLAG:
    run_command(get_honeypot_msg("File write inconsistency :("))
