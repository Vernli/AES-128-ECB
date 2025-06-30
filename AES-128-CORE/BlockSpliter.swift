import Foundation

enum BlockSpliterError: Error {
    case invalidPadding
    case fileReadError
}

struct BlockSpliter {
    static let defaultBlockSize = 16

    static func pad(_ data: Data, blockSize: Int = defaultBlockSize) -> Data {
        var paddedData = data
        let paddingLength = blockSize - (data.count % blockSize)
        paddedData.append(contentsOf: [UInt8](repeating: UInt8(paddingLength), count: paddingLength))
        return paddedData
    }

    static func unpad(_ data: Data) throws -> Data {
        guard !data.isEmpty else {
            return Data()
        }

        let paddingCount = Int(data.last!)
        print(paddingCount)
        try validatePadding(data, paddingLength: paddingCount)
        return data.dropLast(paddingCount)
    }

    private static func validatePadding(_ data: Data, paddingLength: Int) throws {
        guard data.count >= paddingLength && paddingLength > 0 else {
            throw BlockSpliterError.invalidPadding
        }

        let paddingBytes = data.suffix(paddingLength)
        guard paddingBytes.allSatisfy({ $0 == paddingBytes.first && Int($0) == paddingLength }) else {
            throw BlockSpliterError.invalidPadding
        }
    }

    static func splitIntoBlocks(_ data: Data, blockSize: Int = defaultBlockSize) -> [Data] {
        stride(from: 0, to: data.count, by: blockSize).map {
            data[$0..<min($0 + blockSize, data.count)]
        }
    }

    static func readFile(from path: String) throws -> Data {
        let fileURL = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: fileURL)
        else {
            throw BlockSpliterError.fileReadError
        }
        return data
    }
    
    static func loadFileFromFilePath(filePath: String) throws -> [[UInt8]] {
        let originalData = try readFile(from: filePath)
        let paddedData = pad(originalData)
        let blocks = splitIntoBlocks(paddedData)
        return blocks.map { Array($0) }
    }
}

