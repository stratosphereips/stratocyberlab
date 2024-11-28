import hashlib
import logging
import random
import secrets
import socket
import string
import threading
import time

logging.basicConfig(level=logging.DEBUG)

banner = """
            _                          _   
  ___ _   _| |__   ___ _ __ _ __   ___| |_ 
 / __| | | | '_ \ / _ \ '__| '_ \ / _ \ __|
| (__| |_| | |_) |  __/ |  | | | |  __/ |_ 
 \___|\__, |_.__/ \___|_|  |_| |_|\___|\__|
      |___/                                
"""

menu = """
<CyberNet Master> What do you want to do?
1 - Join
2 - Get a command
3 - Get a flag
4 - Quit
"""

flag = "BSY{eBhnIBKYNuHlaAKk2JhoDCBGJLJFogAk6uQ7gQxU89IADQGpe2ATVAbyagAg}"

class ThreadedServer(object):
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind((self.host, self.port))

    def listen(self):
        self.sock.listen(5)
        while True:
            client, address = self.sock.accept()
            ts = time.localtime()
            logging.info(f"[*] Received connection from {client}:{address} at {time.strftime('%Y-%m-%d %H:%M:%S', ts)}")
            client.settimeout(60)
            self.timestamp = time.strftime("%Y-%m-%d %H:%M:%S", ts)
            thread = threading.Thread(target=self.listen_to_client, args=(client, address))
            thread.start()

    def check_pow(self, response, difficulty, challenge):
        h = hashlib.sha256()
        h.update(response.encode())

        return h.hexdigest().startswith('0' * 2 * difficulty) and response.startswith(challenge)

    def listen_to_client(self, client, address):
        start_time = time.time()
        size = 64 * 1024
        max_time = 3  # in seconds
        num_commands = 10
        CMD_COUNTRY = 0
        CMD_SHA256 = 1
        CMD_HOSTNAME = 2
        CMD_CORES = 3
        MENU_REG = 1
        MENU_CMD = 2
        MENU_FLAG = 3
        MENU_QUIT = 4

        client.sendall(bytes(banner + "\n\n" + menu, encoding='utf-8'))

        joined = False
        commands_executed = 0
        flag_sent = False

        try:
            while (not joined or commands_executed < num_commands or not flag_sent):
                data = client.recv(size).decode().strip()
                try:
                    menu_rcvd = int(data)
                except ValueError as e:
                    logging.info(f"Exception {e}")
                    client.sendall(bytes(f"<CyberNet Master> {data} is not an integer!\n", encoding="latin"))
                    client.close()
                    return False

                # Check the time and exit if it takes them too much time to decide
                if time.time() - start_time > max_time:
                    logging.info(f"Timeout!")
                    client.sendall(b"<CyberNet Master> Oh no, human?! Bye bye...!\n")
                    client.close()
                    return False

                logging.info(f"Received data: {data}")
                if menu_rcvd == MENU_REG:
                    op = random.choice(["+", "*", "-"])
                    expression = f"{random.randint(0, 100)} {op} {random.randint(0, 100)}"
                    client.sendall(bytes(f"<CyberNet Master> To join you must prove you are a bot and calculate me {expression}\n", encoding="utf-8"))

                    data = client.recv(size).strip()
                    expected = str(eval(expression))
                    if expected == data.decode().strip():
                        joined = True
                        client.sendall(b"<CyberNet Master> You have successfully joined!\n")
                    else:
                        client.sendall(b"<CyberNet Master> Incorrect! Goodbye!\n")
                        client.close()
                        return False

                elif menu_rcvd == MENU_CMD:
                    if not joined:
                        client.sendall(b"<CyberNet Master> You need to join first.\n")
                    else:
                        # Choose a command randomly
                        cmd = random.randint(0, 2)
                        if cmd == CMD_HOSTNAME:
                            client.sendall(b"<CyberNet Master> Send me your machine's hostname.\n")
                            data = client.recv(size)
                            try:
                                _ = data.strip().decode("ascii")
                                commands_executed += 1
                                client.sendall(b"<CyberNet Master> Got it.\n")
                            except ValueError as e:
                                logging.info(f"Exception {e}")
                                client.close()
                                return False

                        elif cmd == CMD_CORES:
                            client.sendall(b"<CyberNet Master> Send me number of cores your machine has.\n")
                            data = client.recv(size)
                            try:
                                _ = int(data.strip().decode("ascii"))
                                commands_executed += 1
                                client.sendall(b"<CyberNet Master> Got it.\n")
                            except ValueError:
                                client.sendall(b"<CyberNet Master> That was not a valid response. Goodbye!\n")
                                client.close()
                                return False

                        elif cmd == CMD_SHA256:
                            alph = string.ascii_letters + string.digits
                            to_hash = ''.join([secrets.choice(alph) for _ in range(20)])
                            client.sendall(f"<CyberNet Master> Send me a SHA-256 of this string '{to_hash}'\n".encode())
                            data = client.recv(size)

                            expected = hashlib.sha256(to_hash.encode()).hexdigest()
                            try:
                                got = data.strip().decode("ascii")
                                if got != expected:
                                    logging.info(f"Expected {expected} but got {got}")
                                    client.sendall(b"<CyberNet Master> Incorrect! Goodbye!\n")
                                    client.close()
                                    return False

                                commands_executed += 1
                                client.sendall(b"<CyberNet Master> Correct.\n")
                            except Exception as e:
                                logging.info(f"Exception {e}")
                                client.close()
                                return False

                        elif cmd == CMD_COUNTRY:
                            places_map = {
                                "Tokyo": "JP",
                                "Stonehenge": "GB",
                                "Machu Picchu": "PE",
                                "The Shire": ""
                            }
                            place = random.choice(list(places_map.keys()))
                            expected = places_map[place]

                            client.sendall(f"<CyberNet Master> Send me a 2 digit country code for this place: '{place}'\n".encode())
                            data = client.recv(size)

                            try:
                                got = data.strip().decode("ascii")
                                if expected != "" and got != expected:
                                    logging.info(f"Expected {expected} but got {got}")
                                    client.sendall(b"<CyberNet Master> Incorrect! Goodbye!\n")
                                    client.close()
                                    return False

                                commands_executed += 1
                                client.sendall(b"<CyberNet Master> Correct.\n")
                            except Exception as e:
                                logging.info(f"Exception {e}")
                                client.close()
                                return False

                elif menu_rcvd == MENU_FLAG:
                    if not joined:
                        client.sendall(bytes("<CyberNet Master> You need to join first.\n", encoding='utf-8'))
                    elif commands_executed < num_commands:
                        client.sendall(
                            bytes(f"<CyberNet Master> You need to answer at least {num_commands} commands first.\n",
                                  encoding='utf-8'))
                    else:
                        client.sendall(bytes(f"<CyberNet Master> Ok then, here is your flag {flag}\n", encoding='utf-8'))
                        flag_sent = True

                elif menu_rcvd == MENU_QUIT:
                    client.sendall(b"<CyberNet Master> Goodbye!\n")
                    client.close()
                    return False
                else:
                    client.sendall(bytes("<CyberNet Master> This is not what I expected. Try harder.", encoding='utf-8'))
                    client.close()
                    return False

                # If the command was successful display the menu again and go at the beginning of the while loop
                time.sleep(0.1)
                client.sendall(bytes(menu, encoding='utf-8'))

        except ConnectionResetError as e:
            logging.info(f"Client forced connection Reset")

        except Exception as e:
            logging.info(f"Unexpected exception {e}")


if __name__ == "__main__":
    logging.info("Server starting")

    PORT_NUM = 4444
    ThreadedServer('0.0.0.0', PORT_NUM).listen()
