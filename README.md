A high-performance AES-128 implementation in ECB mode, written in pure Swift and GPU-accelerated via Apple’s Metal API. This project offers three user interfaces:

- **CLI**: one-shot encryption/decryption via command-line arguments  
- **Interactive CLI**: text-based menu for multiple operations in a single session  
- **GUI**: SwiftUI graphical app for encrypting files and text  

**Technologies:** Swift 5+, SwiftUI, Metal API

**AES** (Advanced Encryption Standard) is a symmetric block cipher that processes 16-byte (128-bit) blocks. In AES-128, each block undergoes **10 rounds** of bitwise transformations—SubBytes, ShiftRows, MixColumns and AddRoundKey—using a 128-bit key. **ECB mode provides independent encryption of each 16-byte block—perfect for fully parallel workloads.** The SubBytes and InvSubBytes steps leverage the official S-box and inverse S-box lookup tables as defined in the NIST FIPS-197 AES specification. By offloading these core operations to the GPU with Metal, this library achieves massive parallelism—encrypting thousands of blocks simultaneously at gigabytes-per-second throughput.  

