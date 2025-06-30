import Foundation
import AES_128_CORE

struct CLIHandler {
    public static func dataToState(_ data: Data) -> [UInt8] {
        return [UInt8](data)
    }

    public static func mergeBlocks(_ blocks: [[UInt8]]) -> Data {
        let flatArray = blocks.flatMap { $0 }
        return Data(flatArray)
    }

    public static func saveFile(data: Data, originalPath: String, extension ext: String) throws {
        let url = URL(fileURLWithPath: originalPath)
        let newURL = url.deletingPathExtension().appendingPathExtension(ext)
        try data.write(to: newURL)
        print("File saved to: \(newURL.path)")
    }

    public static func readInt(text: String) -> Int {
        print(text, terminator: " ")
        guard let line = readLine(),
              let number = Int(line) else {
            print("Error: invalid format. Please try again.")
            return readInt(text: text)
        }
        return number
    }



    public static  func readString(prompt: String) -> String {
        print(prompt, terminator: " ")
        guard let line = readLine(), !line.isEmpty else {
            print("No value provided, please try again.")
            return readString(prompt: prompt)
        }
        return line
    }

    public static func readFilePath(text: String) -> String {
        let fileManager = FileManager.default
        print(text, terminator: " ")
        
        guard let input = readLine(), !input.isEmpty else {
            fatalError("No path provided.")
        }
        
        let path = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fileManager.fileExists(atPath: path) {
            return path
        } else {
            return "Invalid path"
        }
    }

    func isValid128BitHex(_ str: String) -> Bool {
        let pattern = "^[0-9A-Fa-f]{32}$"
        return str.range(of: pattern, options: .regularExpression) != nil
    }

    func hexStringToData(_ hex: String) -> Data? {
        let cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanHex.count == 32 else { return nil }
        var data = Data(capacity: cleanHex.count / 2)
        var index = cleanHex.startIndex

        for _ in 0..<cleanHex.count/2 {
            let nextIndex = cleanHex.index(index, offsetBy: 2)
            let byteString = cleanHex[index..<nextIndex]
            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        return data
    }

    public static func isSave() -> Bool {
        let response = readString(prompt: "Do you want to save the result to a file? [y/n]:")
        return response.trimmingCharacters(in: .whitespacesAndNewlines)
                       .lowercased() == "y"
    }
    
    public static func encryption(_ mode: Modes, _ filePath: String = "") -> Void {
        
        let filePath = filePath.isEmpty ? readFilePath(text: "Path to the file:") : filePath
        let keyData: Data = KeyOps.generateKey()!
        
        let crypto = Crypto(filePath: filePath, keyData: keyData)
        
        switch mode {
            case .SEQ:
                crypto.sequentionalEncryption()
            case .CPU:
                crypto.cpuEncryption()
            case .GPU:
                crypto.gpuEncryption()
        }
        
        let suffix = String(describing: mode).uppercased()
        crypto.saveResult(suffix: suffix, fileExtension: "aes")
    }

    public static func decryption(_ mode: Modes, _ filePath: String = "", _ keyPath: String = "") -> Void {
        let filePath = filePath.isEmpty ? readFilePath(text: "Path to the aes file:") : filePath
        let keyPath = keyPath.isEmpty ? readFilePath(text: "Path to the key file:") : keyPath
        
        let keyData = try! Data(contentsOf: URL(fileURLWithPath: keyPath))
        
        let crypto = Crypto(filePath: filePath, keyData: keyData)
        
        switch mode {
            case .SEQ:
                crypto.sequentionalDecryption()
            case .CPU:
                crypto.cpuDecryption()
            case .GPU:
                crypto.gpuDecryption()
        }
        
        let suffix = String(describing: mode).lowercased()
       crypto.saveResult(suffix: suffix, target: Crypto.SaveTarget.data, fileExtension: "dec")

    }
}



