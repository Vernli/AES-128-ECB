import Foundation
import AppKit
import UniformTypeIdentifiers

enum Mode: String, CaseIterable {
    case encryption = "Encryption"
    case decryption = "Decryption"
}

enum Options: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case seq = "Sequentional"
    case cpu = "Parallel CPU"
    case gpu = "Parallel GPU"
}



class CryptoManager {
    var mode: Mode
    var option: Options
    var filePath: String
    var keyPath: String

    init(mode: Mode, option: Options, filePath: String, keyPath: String = "") {
        self.mode = mode
        self.option = option
        self.filePath = filePath
        self.keyPath = keyPath
    }
    
    static var documentsDirectory: URL {
           FileManager.default.urls(
               for: .documentDirectory,
               in: .userDomainMask
           )[0]
       }

    func run() {
        switch mode {
        case .encryption:
            let keyData = KeyOps.generateKey()
            let crypto = Crypto(filePath: filePath, keyData: keyData!)
            performEncryption(using: crypto)

        case .decryption:
            guard !keyPath.isEmpty,
                  let keyData = try? Data(contentsOf: URL(fileURLWithPath: keyPath)) else {
                return
            }
            let crypto = Crypto(filePath: filePath, keyData: keyData)
            performDecryption(using: crypto)
        }
    }

    private func performEncryption(using crypto: Crypto) {
        switch option {
        case .seq:
            crypto.sequentionalEncryption()
        case .cpu:
            crypto.cpuEncryption()
        case .gpu:
            crypto.gpuEncryption()
        }

        saveOutput(data: crypto.data, suffix: optionString(option), fileExtension: "aes")
        saveOutput(data: crypto.keyData, suffix: optionString(option), fileExtension: "key")
    }

    private func performDecryption(using crypto: Crypto) {
        switch option {
        case .seq:
            crypto.sequentionalDecryption()
        case .cpu:
            crypto.cpuDecryption()
        case .gpu:
            crypto.gpuDecryption()
        }
        print("✅ FINISHED decryption – zaraz zapiszę plik")

        saveOutput(data: crypto.data, suffix: optionString(option), fileExtension: "dec")
    }

    private func saveOutput(data: Data, suffix: String, fileExtension: String) {
        let fileName = "result_\(suffix).\(fileExtension)"
        let url = URL.documentsDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: url, options: [.atomic])

            print("✅ Zapisano \(data.count) bajtów do: \(url.path)")
        } catch {
            print("❌ Błąd zapisu danych:", error.localizedDescription)
        }
    }

    private func optionString(_ option: Options) -> String {
        switch option {
        case .seq: return "SEQ"
        case .cpu: return "CPU"
        case .gpu: return "GPU"
        }
    }
}
