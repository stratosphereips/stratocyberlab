from scapy.all import sr1, IP, ICMP
import time

# Configurable IP address and timing interval (in seconds)
target_ip = "172.20.0.2"  # Replace with the desired IP address
interval = 1  # Time in seconds between each ICMP request

def ping():
    while True:
        # Create an IP packet with the target IP
        ip_packet = IP(dst=target_ip)
        # Create an ICMP echo request
        icmp_request = ICMP()
        # Send the packet and wait for a response
        response = sr1(ip_packet/icmp_request, timeout=1, verbose=False)
        
        if response:
            print(f"Received reply from {target_ip}")
        else:
            print(f"No reply from {target_ip}")
        
        # Wait for the specified interval before sending the next packet
        time.sleep(interval)

if __name__ == "__main__":
    ping()

