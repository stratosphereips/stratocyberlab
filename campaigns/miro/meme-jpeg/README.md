# Meme.jpeg

Steganography + cryptography.

## How to solve

1. Install steghide (`apt install steghide`) and Stegano (`pip3 install Stegano --break-system-packages`)
2. Access `http://172.20.0.205` (ideally using the transparent proxy) and download the image (further referred to as img.png)
3. `stegano-lsb reveal -i img.png -o l1re.jpg` will yield a l1re.jpg, from the looks of it the same image
4. `steghide extract -sf l1re.jpg -xf l0re.txt -p ""` will yield a l0re.txt containing an encrypted string
5. Run the script through a Vigenére cipher tool, such as [dCode.fr](https://www.dcode.fr/vigenere-cipher) or [this at University of Denver](https://www.cs.du.edu/~snarayan/crypt/vigenere.html) while aiming to produce something meaningful in front of the `://` in the string

## Solution
<details>
<summary>Solution</summary>
You should arrive at the conclusion that the key is KEY and the open text thus <code>http://repository</code>, which is the flag
</details>
