import Foundation
import Metal

class MetalAES {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let encryptPipeline: MTLComputePipelineState
    private let decodePipeline: MTLComputePipelineState
    
    private var paramsBuf: MTLBuffer?
    private var inBuf: MTLBuffer?
    private var outBuf: MTLBuffer?
    private var cmdBuf: MTLCommandBuffer!
    private var encoder: MTLComputeCommandEncoder!
    private let rounds = UInt16(10).littleEndian
    private var mode: AESMode = .encrypt

    private var blockCount: Int = 0
    
    enum AESMode {
        case encrypt
        case decrypt
    }
    
    public func setMode(_ newMode: AESMode) {
        self.mode = newMode
    }
    
    public func getMode() -> AESMode {
        return self.mode
    }
    
    public func setBlockCount(count: Int) {
        self.blockCount = count
    }
    
    public func getBlockCount() -> Int {
        return self.blockCount
    }
    
    
    init?() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary(),
              let encryptFunction = library.makeFunction(name: "aes_encrypt"),
              let decodeFunction = library.makeFunction(name: "aes_decode")
        else {
            
            print("Błąd ładowania METAL API")
            return nil
        }
        
        do {
            self.encryptPipeline = try device.makeComputePipelineState(function: encryptFunction)
            self.decodePipeline = try device.makeComputePipelineState(function: decodeFunction)
        } catch {
            print("Błąd tworzenia pipeline: \(error)")
            return nil
        }
        
        self.device = device
        self.commandQueue = commandQueue
    }
    
public func initBuffers(roundKeys: [[UInt8]], blocks: [[UInt8]]) {
    var params = Data()
    withUnsafeBytes(of: rounds) {
        params.append(contentsOf: $0)
    }
    roundKeys.forEach { params.append(contentsOf: $0)}
    setBlockCount(count: blocks.count)
    
    let flatInput = blocks.flatMap { $0 }
    
    paramsBuf = params.withUnsafeBytes({
        rawBuf -> MTLBuffer? in
        guard let base = rawBuf.baseAddress else { return nil }
        
        return device.makeBuffer(bytes: base,
             length: rawBuf.count,
             options: [])
    })
          
    inBuf = flatInput.withUnsafeBytes { rawBuf -> MTLBuffer? in
        guard let base = rawBuf.baseAddress else { return nil }
        return device.makeBuffer(bytes: base, length: rawBuf.count, options: [])
    }

    outBuf = device.makeBuffer(length: flatInput.count, options: [])

    guard inBuf != nil, outBuf != nil else {
        fatalError("Nie udało się stworzyć któregoś z bufferów")
    }
    cmdBuf = commandQueue.makeCommandBuffer()
}
    
    
    public func initEncoder() {
        encoder = cmdBuf.makeComputeCommandEncoder()
        encoder.setComputePipelineState(mode == .encrypt ? encryptPipeline : decodePipeline)
        encoder.setBuffer(paramsBuf, offset: 0, index: 0)
        encoder.setBuffer(inBuf,     offset: 0, index: 1)
        encoder.setBuffer(outBuf,    offset: 0, index: 2)
        
        let blockCount = blockCount
        let w          = mode == .encrypt ? encryptPipeline.threadExecutionWidth : decodePipeline.threadExecutionWidth
       
        let tg         = MTLSize(width: w,       height: 1, depth: 1)
        let tgAll      = MTLSize(width: blockCount, height: 1, depth: 1)

        encoder.dispatchThreads(tgAll, threadsPerThreadgroup: tg)
        encoder.endEncoding()
    }
    
    
    public func run() {
        cmdBuf.commit()
        cmdBuf.waitUntilCompleted()
    }
    
    public func getOutputBlocks() -> Data {
        guard let outBuf = outBuf else {
            fatalError("Brak bufora wyjściowego")
        }
        
        let length = blockCount * 16
        return Data(bytesNoCopy: outBuf.contents(), count: length, deallocator: .none)
    }
}
