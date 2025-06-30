import Foundation
import Metal

public class Crypto {
    private let filePath: String;
    private let _keyData: Data;
    
    private let blocks: [[UInt8]];
    private var _data: Data;
    
    var data: Data {
           get { _data }
           set { _data = newValue }
       }
    
    var keyData: Data {
        get { _keyData }
    }
    
    
    private let aes: AES = AES();
    private var metalAES: MetalAES!
    
    public init(filePath: String, keyData: Data) {
        self.filePath = filePath;
        self._keyData = keyData;
        guard let blocks = try? BlockSpliter.loadFileFromFilePath(filePath: filePath) else { fatalError("ERROR")}
        self.blocks = blocks;
        self._data = Data(count: blocks.count * 16)

        aes.initRoundKeys(keyData: keyData);
    }
    
    public enum SaveTarget {
        case data
        case key
        case both
    }

    public func saveResult(
        suffix: String,
        target: SaveTarget = .both,
        fileExtension: String
    ) {
        if target == .data || target == .both {
            try? saveFile(data: data, originalPath: filePath, extension: fileExtension, suffix: suffix)
        }

        if target == .key || target == .both {
            try? KeyOps.saveKey(keyData: keyData, originalPath: filePath, extension: "key", suffix: suffix)
        }
    }
    
    public func sequentionalEncryption(saveResult: Bool = false) {
        measureTime("SEQ ENCRYPT") {
            data.withUnsafeMutableBytes { buffer in
                guard let ptr = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }

                for i in 0..<blocks.count {
                    let destPtr = ptr.advanced(by: i * 16)
                    aes.encrypt(block: blocks[i], output: destPtr)
                }
            }
        }

        if (saveResult) {
            try? saveFile(data: data, originalPath: filePath, extension: "aes", suffix: "seq")
            try? KeyOps.saveKey(keyData: keyData, originalPath: filePath, extension: "key", suffix: "seq")
        }
    }

public func cpuEncryption(saveResult: Bool = false, threadCount: Int = ProcessInfo.processInfo.activeProcessorCount) {
    measureTime("CPU ENCRYPT[\(threadCount)]") {
            data.withUnsafeMutableBytes { rawBuffer in
                guard let basePtr = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                else { return }

                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = threadCount

                for i in 0..<blocks.count {
                    queue.addOperation {
                        let destPtr = basePtr.advanced(by: i * 16)
                        self.aes.encrypt(block: self.blocks[i], output: destPtr)
                    }
                }

                queue.waitUntilAllOperationsAreFinished()
            }
        }
    if saveResult {
        try? saveFile(data: data, originalPath: filePath, extension: "aes", suffix: "cpu")
        try? KeyOps.saveKey(keyData: keyData, originalPath: filePath, extension: "key", suffix: "cpu")
    }
}

    public func gpuEncryption(saveResult: Bool = false) {
        initMetalAES()
        measureTime("GPU ENCRYPT") {
            metalAES.run()
        }
        data = metalAES.getOutputBlocks()

        
        if (saveResult) {
            try? saveFile(data: data, originalPath: filePath, extension: "aes", suffix: "gpu")
            try? KeyOps.saveKey(keyData: keyData, originalPath: filePath, extension: "key", suffix: "gpu")
        }
    }


    public func sequentionalDecryption(saveResult: Bool = false)   {
    measureTime("SEQ DECRYPT") {
        data.withUnsafeMutableBytes { buffer in
            guard let ptr =  buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }

            for i in 0..<blocks.count {
                let destPtr = ptr.advanced(by: i * 16)
                aes.decrypt(block: blocks[i], output: destPtr)
            }
        }
    }
    if (saveResult) {
        try? saveFile(data: data, originalPath: filePath, extension: "dec", suffix: "seq")
    }
    }
    
    
    public func cpuDecryption(saveResult: Bool = false, threadCount: Int = ProcessInfo.processInfo.activeProcessorCount)
    {
        measureTime("CPU DECRYPT[\(threadCount)]") {
            data.withUnsafeMutableBytes { rawBuffer in
                guard let basePtr = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                else { return }

                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = threadCount

                for i in 0..<blocks.count {
                    queue.addOperation { [unowned self] in
                        let destPtr = basePtr.advanced(by: i * 16)
                        self.aes.decrypt(block: self.blocks[i], output: destPtr)
                    }
                }

                queue.waitUntilAllOperationsAreFinished()
            }
        }

        if saveResult {
            try? saveFile(data: data,
                         originalPath: filePath,
                         extension: "dec",
                         suffix: "cpu")
        }

    }
    
    public func gpuDecryption(saveResult: Bool = false) {
        initMetalAES(encryption: false)
        measureTime("GPU") {
            metalAES.run()
        }
        data = metalAES.getOutputBlocks()
        
        if (saveResult) {
            try? saveFile(data: data, originalPath: filePath, extension: "dec", suffix: "gpu")
        }
    }
    
    private func initMetalAES(encryption: Bool = true) {
        self.metalAES = MetalAES()
        
        
        if (encryption) {
            metalAES.initBuffers(roundKeys: aes.roundKeys, blocks: blocks)
            metalAES.initEncoder()
        }
        else {
            metalAES.setMode(MetalAES.AESMode.decrypt)
            metalAES.initBuffers(roundKeys: aes.roundKeys, blocks: blocks)
            metalAES.initEncoder()
        }
    }

    
    private func loadFileFromFilePath(filePath: String) throws -> [[UInt8]] {
        let originalData = try BlockSpliter.readFile(from: filePath)
        let paddedData = BlockSpliter.pad(originalData)
        let blocks = BlockSpliter.splitIntoBlocks(paddedData)
        return blocks.map { Array($0) }
    }
    
    func measureTime<T>(_ label: String = "", block: () throws -> T) rethrows {
        let start = DispatchTime.now()
        let _ = try block()
        let end = DispatchTime.now()
        
        print(String(format: "(%@) Time: %.6f seconds", label, elapsedTime(start, end)))
    }
    
    func saveFile(data: Data, originalPath: String, extension ext: String, suffix: String = "") throws {
        let originalURL = URL(fileURLWithPath: originalPath)

        let directory = originalURL.deletingLastPathComponent()
        let baseName  = originalURL.deletingPathExtension().lastPathComponent
        let newFileName: String
        
        if (suffix != "") {
            newFileName = "\(baseName)_\(suffix).\(ext)"
        } else {
            newFileName = "\(baseName).\(ext)"
        }
        let newURL      = directory.appendingPathComponent(newFileName)

        try data.write(to: newURL)
        print("File saved to: \(newURL.path)")
    }
    
    private let elapsedTime = { (start: DispatchTime, end: DispatchTime) -> Double in return Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000}
}


