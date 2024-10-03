from scapy.all import sr1, IP, ICMP, send, TCP, UDP
import time
import random

# hackerlab IP
target_ip = "172.20.0.2"

# intervals for sleep (uniform probability)
flag_interval_from, flag_interval_to = 4, 10
noise_interval_from, noise_interval_to = 1, 2
noise_burst_packets = 5

def rot13(text):
    result = []
    for char in text:
        if 'a' <= char <= 'z':
            result.append(chr((ord(char) - ord('a') + 13) % 26 + ord('a')))
        elif 'A' <= char <= 'Z':
            result.append(chr((ord(char) - ord('A') + 13) % 26 + ord('A')))
        else:
            result.append(char)  # Non-alphabetic characters stay unchanged
    return ''.join(result)


def send_noise():
    """Send random noise in the form of TCP and UDP packets."""
    while True:
        # Randomly choose between TCP and UDP
        for i in range(noise_burst_packets):
            protocol = random.choice(["TCP", "UDP"])
            if protocol == "TCP":
                # Send a TCP packet to a random port
                random_port = random.randint(1024, 65535)
                tcp_packet = IP(dst=target_ip) / TCP(dport=random_port, flags="S")
                send(tcp_packet, verbose=False)
            else:
                # Send a UDP packet to a random port
                random_port = random.randint(1024, 65535)
                udp_packet = IP(dst=target_ip) / UDP(dport=random_port)
                send(udp_packet, verbose=False)

        # Random delay before sending the next noise packet
        time.sleep(random.uniform(noise_interval_from, noise_interval_to))

def ping_flag(flag):
    while True:
        # Create an IP packet with the target IP
        ip_packet = IP(dst=target_ip)
        # Create an ICMP echo request with the payload
        icmp_request = ICMP() / flag
        # Send the packet and wait for a response
        response = sr1(ip_packet/icmp_request, timeout=1, verbose=False)

        if response:
            print(f"Received reply from {target_ip}")
        else:
            print(f"No reply from {target_ip}")

        # Wait for the specified interval before sending the next packet
        time.sleep(random.uniform(flag_interval_from, flag_interval_to))

def main():
    # Read the content from the file /tmp/flag.txt
    with open('/tmp/flag.txt', 'r') as file:
        encrypted_flag = rot13(file.read().strip())

    # Start the noise generation in a separate thread
    import threading
    noise_thread = threading.Thread(target=send_noise)
    noise_thread.daemon = True
    noise_thread.start()

    ping_flag(encrypted_flag)

if __name__ == "__main__":
    main()
