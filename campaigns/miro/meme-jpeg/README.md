# Meme.jpeg

This challenge combines **steganography and cryptography** to let students extract and decrypt hidden information within inconspicuous files.
Students must use multiple techniques to uncover a hidden URL that serves as the challenge flag, demonstrating how sensitive information can be concealed in seemingly innocent files.

## Skills Used

1. **Steganography Techniques**: Using common tools to extract hidden data from files
1. **Cryptography**: Decrypting ciphertext to reveal hidden information
1. **Pattern Recognition**: Identifying meaningful patterns in decrypted strings to determine a cipher key

## Learning Objectives

- Understand how **steganography** can be used to hide data within image files
- Learn to apply **multiple steganography techniques** in sequence
- Develop skills in **cryptanalysis** to break simple ciphers
- Gain experience with **forensic tools** for data extraction
- Recognize how **layered obfuscation** can be used to hide sensitive information
- Understand the importance of **pattern recognition** in decrypting messages

## How to solve

<details>
  <summary>Click to reveal how to solve steps</summary>
1. Install steghide (`apt install steghide`) and Stegano (`pip3 install Stegano --break-system-packages`)
2. Access `http://172.20.0.205` (ideally using the transparent proxy) and download the image (further referred to as img.png)
3. `stegano-lsb reveal -i img.png -o l1re.jpg` will yield a l1re.jpg, from the looks of it the same image
4. `steghide extract -sf l1re.jpg -xf l0re.txt -p ""` will yield a l0re.txt containing an encrypted string
5. Run the script through a Vigenére cipher tool, such as [dCode.fr](https://www.dcode.fr/vigenere-cipher) or [this at University of Denver](https://www.cs.du.edu/~snarayan/crypt/vigenere.html) while aiming to produce something meaningful in front of the `://` in the string
6. You should arrive at the conclusion that the key is KEY and the open text thus <code>http://repository</code>, which is the flag
</details>
