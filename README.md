## AES 128 - ECB
A high-performance AES-128 implementation in ECB mode, written in pure Swift and GPU-accelerated via Apple’s Metal API. This project offers three user interfaces:

- **CLI**: one-shot encryption/decryption via command-line arguments  
- **Interactive CLI**: text-based menu for multiple operations in a single session  
- **GUI**: SwiftUI graphical app for encrypting files and text  

**Technologies:** Swift 5+, SwiftUI, Metal API

**AES** (Advanced Encryption Standard) is a symmetric block cipher that processes 16-byte (128-bit) blocks. In AES-128, each block undergoes **10 rounds** of bitwise transformations—SubBytes, ShiftRows, MixColumns and AddRoundKey—using a 128-bit key. **ECB mode provides independent encryption of each 16-byte block—perfect for fully parallel workloads.** The SubBytes and InvSubBytes steps leverage the official S-box and inverse S-box lookup tables as defined in the NIST FIPS-197 AES specification. By offloading these core operations to the GPU with Metal, this library achieves massive parallelism—encrypting thousands of blocks simultaneously at gigabytes-per-second throughput.  

## Project Structure

The project is divided into three targets:

### 1. **AES-128-CLI** (Command-Line Interface)
A terminal-based tool that allows users to:

- Encrypt or decrypt text and files
- Pass in keys or generate new ones
- Work dynamically with file paths

### 2. **AES-128-CORE** (Reusable Framework)
Contains the core encryption/decryption logic, including:

- AES encryption and decryption operations
- Key management
- File read/write handling
- Reusable public API for other targets

### 3. **AES-128-GUI** (SwiftUI GUI)
A modern graphical interface that provides:

- File selection
- Key input and generation
- Real-time encryption/decryption preview


## Link to YouTube Presentation
[![Presentation of CLI, Interactive CLI & GUI](https://img.youtube.com/vi/9XbU4jck-h8/maxresdefault.jpg)](https://youtu.be/9XbU4jck-h8?si=aLCBTQEzdMro7PQA)


