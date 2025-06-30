import ArgumentParser

enum Modes : String, ExpressibleByArgument {
    case SEQ
    case CPU
    case GPU
}

struct CLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Encrypts or decrypts a file using a key file, with CPU/GPU/SEQ mode."
    )

    @Argument(help: "Path to input file")
    var filePath: String

    @Option(name: [.customShort("k"), .long], help: "Required for decrypt – path to key file")
    var keyPath: String?

    @Option(name: [.customShort("m"), .long], help: "Mode of processing: SEQ, CPU, GPU")
    var mode: Modes

    @Option(name: [.customShort("o"), .long], help: "Operation to perform: encrypt or decrypt")
    var operation: String

    func run() throws {
        print("Input file: \(filePath)")
        print("Mode: \(mode)")
        print("Operation: \(operation)")

        switch operation {
        case "encrypt":
            CLIHandler.encryption(mode, filePath)
        case "decrypt":
            guard let keyPath = keyPath else {
                throw ValidationError("Key path is required for decryption")
            }
            CLIHandler.decryption(mode, filePath, keyPath)
        default:
            throw ValidationError("Unsupported operation: \(operation)")
        }
    }
}

