import struct
import socket
import base64

from time import sleep


def craft_payload(message: str, data: bytes) -> bytes:
    magic_number = 0x1A2B3C4D
    version = 0x01

    msg_encoded = base64.b64encode(message.encode())

    payload = struct.pack('!I B', magic_number, version) # represents header
    payload += struct.pack("Q", len(msg_encoded))
    payload += msg_encoded
    payload += struct.pack("Q", len(data))
    payload += data
    return payload


def send(payload: bytes):
    dst_ip = "172.20.0.2"
    dst_port = 1337

    with socket.create_connection((dst_ip, dst_port)) as sock:
        sock.sendall(payload)


def main():
    first_flag = "BSY{a!sk&fjlhý76S5F9OUILFNRQKJLRHIUFKHAS}"
    msg = f"Oh finally you hear me!!! This is your flag {first_flag}. Now, you might be interested in the rest of the message"
    binary_file = "binary.gz"

    with open(binary_file, "rb") as f:
        file_data = f.read()

    payload = craft_payload(msg, file_data)
    while True:
        try:
            send(payload)
        except ConnectionRefusedError:
            pass
        except Exception as e:
            print(f"Unexpected exception while sending packets: {e}")

        sleep(5)

if __name__ == "__main__":
    main()
