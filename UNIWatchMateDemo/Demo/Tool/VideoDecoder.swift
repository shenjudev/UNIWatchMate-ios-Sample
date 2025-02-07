import Foundation
import VideoToolbox
import AVFoundation
import RxSwift

class VideoDecoder {
    private var vtDecompressionSession: VTDecompressionSession?
    private var formatDescription: CMVideoFormatDescription?
    private let disposeBag = DisposeBag()
    
    // 存储SPS和PPS
    private var spsData: Data?
    private var ppsData: Data?
    // 数据缓冲区
//    private var h264Buffer = Data()
    var frameNumber = 0
    
    let originHexData = "000000016742c028b9d0283f200000000168ce031c8000000165888012000ffff1eb1f14fe0e22c2d32d234000ea18005621d2ee6dffffe08df52a3224bffffc23effed0f86845fabd1117dd5fffff99051a4f5ebe823ffffc22247dffffc9fe9ff0d087eb796fcdebff2ff0442d7f1c7ffff846fffffc23effffe4ffffc9ffff93ffff27fffe4ffffc9ffff93ffff27fe5fca16e241e697350b778d0312ffe3ea3a0579f1a9cb3ef4f9ffff40baab8d511365dfffffe40ebb5f4b312ed3edfff5a60b0eb7af15f49db156f493ffd8380205cf58b5026ba7a723127ee58b64544bd7fffffb27fffd844fdffffc9ffff93ffff27fffe4ffffc9ffff93ffff27fffe4ffffc9ffe9f0d8e7f8352f6dc95f8f476bff2ea5fffff44222a31e84000cef5754ffff29a3fffff5ffd123ebffa05e45f559d115be9ffd57fc80c09d6f8b316fa7fff5c56b0efb4bd76c55e9fff82eb60a8abb7fffff909ffff93ffff27fffe4ffff909ffff93fffe427fffd13fffe89ffff44949e75ff86cd9b17cbb0f01c70d71a4ea5ff4a18a8d644a338f88e17f749f6a180ef0fd1ee66be0fdff9daee64fe37cb9da69d981f0c7c65767ff3f99cd39035e279accc7cd43691196bb74faf396e92c3bdfb4a8da36eb4dbdbffea9e83bb4eabe4a39a89f6bfe7ae982a66455a7c55c7ce8fff4ffaf5ffd05095f7d75aff18a059ea751b7fd75c3cd5786d6d6b9da0edf374f4ffebae760a980d737fffffe4ffffc9ffff93ffff27fffe4ffffc9ffff93ffff26bde9ea958d35fb589e2dc1a247535244bf77dffe320fd57bf9705b2298ddebfa9fac22e199021ef9f3ac5495a69adf6cafcaebba94ce1b1be6c7f5f07cc5d7dc73fdcfe7f0b057362e31262b2d1b7d3aa67f2c44e377a7ba45c2d4b066a7515b92a9e54ede42fb984f5e0afb50f0e0ed3d97fb7f30ac664aeea28184d8bedc682479266cfe74f91d3412076d713fc04cf5d7ffa13fc20df77abf680ec9c569fc78e339f382d7acc9d3ffcce7fe838b5af026c559bffcfe744f60a992ebfffffc9ffff93ffff27fffe4ffffc9ffff93ffff279f78f9a64cb9d215dcd8b14f074915375a6bf00bc94c3cf82be7d8f23a5dae49bff4faaa3f48fafd3f684743cf2d47fff3c1600f7a881c17f7b9b170375934db8c95f948575d4fd06ee7d5d7950e67d2977db6d3d33f590e211fdf74596527119096abe6a7d15a1ddf333b05f9f1bd7b80240664f477ee9544a66fd610afe95cb1c56d2f9afa7f70507023255ff2c2f6eadef2f10b63b6eaff21da868caedc81ab5e2ef2854d5bfec45e21fb0df7af9a7a7fd3fff20213eb3333929211befbefbeffd523ff0d84266a4b1f0749150ab1b5e9fa9a2f4ff206bde5cb79eef5ff28e74ff82be6c5cdf143ffd700ff82ef13e91375cd4bde72318a116a9bef6ad4dd7bf681b2119a0cd4cbe83acb99cce7083c745ff7f686b1951930db52db4d3a542c03ba94f05fed6bc1dd6ce354d1b6f98a0f9eb0086afd7856b07eb76fa747df97f20deefdd79b0f5e21175ffffc1157c5fffef20749cd913c5c53cf4ff627f2fec1545777f918fbef93be7ed64ffffce1d1daf6a7ba7fffffa043db8b2432f7177a7dbf7237549ac5e4f13cdfdefb422b45b526055bfb6da69cff12be066408695ad6abe453775fd1ca68db676be087ebe3baebf71880d847376debf45cc0652c176d602a2a72d0fb1d536ea5d6ab53cf0d776dae2788ad32f47a36d9a7d3e92fb05d55a40208dae4978530c2e85fb7dba7cb8ffffc80b313cc4f364f5fbffff8223d705aaffffd044b52dd93ffffa234aeededafca453245aa629bbdcd8b9b39f65860dc1f6d32a4feb6999dfac9c9f6b5afde0088cf48a93f5313fbf3478bfabbf6a2f84ff2937af7b7699faf86b9b35d164db397b6f5fcd33003782087a55fae21715674754d1d402e25ad4f582fdacd9b909cb6386237a54edb3b9cd35cfc63ebfa49b9618c4472b7bbd74cddbffe0060c693d8dd6583ff501653c532f8e2bf8f4344916c745cbc96fdb7de27803b2cc769ecbed7fcce52b061e6c4fdacffff6ffb04b7f2ffffd8585bfbbf5ffffc8d645b5b5b5bedac8b9f7fa620d0db95887057179b170df4297bd7e3ee60fcd4305f8bebc78c5669fe7154d5c3f0eefde2e2f74bfad9db4d1d7dfae686a4f7dd54d9f5c652dbed35c60d5875b3e01a9e7a13c1875f2c0162c4a9770f73ed3d7f90c010a9fa5a76aebd60558a94f4d35bc6265e7a98041543b986adf2f6f6cd59e86432f3a416e8a2e1dd16cea2ba633ca9c36fe28827db363f9bfbeb3d4db6a9fc204d7fd7d7ffff60a6bd7b4acefffff93ffff23eee5abbb5b7e79cfe4fc78817aa896117e2e34444d2feb357fe5bea74e3693d9e8c5f5cadbaaa7ab4ff752003e2ffb5d2bd22c22fdde163373a3b6cbff81ea1be10e7bc794df043151dc9f526bffe58aea7482fb52dbcf0f40bc93d1dece0ba29f0722e1cf7cd82e35114946d992d9a68f299782ae69dadab4bef7c18b882ad4a5dc3a75b3cc10e78231057087bae585bc45212d0f187fb96757a48fc0e234c35daf37201c3665feb0c3b01ebbfbafad7fa7ff6ec157bdfffffec8496f93bbbabeeedfc904e15cd517338f29a37bacbfbb78ba2baffec13384fbf0d694ddaf5adffce19781cd60be2b365f37940dc9d3ae7f2fd7335fe55af7f7ef89dcb9cd66ae6ad1fece9fd20c3d57530945b67cdacb7d5bfcc26ba4f0830ebbe01c0451f41bebebaf5210e1e3fdef55e129c1da6f3539699b334f3af11275efbf97e642bab96b4decc959e2d696663c21db36db17d2efad3474eef083bd3fff7ffed0f202acb757fffffb212593befbbbefbf9115dca15cf46970b027ab46cf38e2efcd2ea62b53f9c9e1c89ff72c1d81f9b5efd4f809894c8d57d6fdae5d4f30e9c5491b3a7f0cf382ff0d74abe020a0e8ef6619c0191fd384dfd7edff46de2388a974f54dbf8e6a13d70d52ee2eb1911a8b397b64b7fae399fa86afce0bbac6d168dba3774d95ae51e679c0ffc5e2fafee00a607558a3746fa579ca9bc1298df77f7abefcf0892807d97ffed01fb7d84622f7fffec8496fbe4bbeeafbb7d7ab4b7bf669ddf970b6fd91273e0f0be6753d51b6a6f33bef6eba4f50732d0437bbef69659b37a72fb7d5ff53c30876b37efc43595b4d1d32a53d63fa4cfd247f9b37dfe6c188831e98f77ad3a3f8055f41fef7dbcd9cf03ec03bfc6b4d1bc30e13b96acffebe2b412a955d78b9366bbe1f4e1cdb6fab894434f68d68d5eb67559fda25e3f7f4bbd14def5a70828e9f7b2ffe29c7687ceff24b7df277dbdddd57cc973d6f12c5915ae5dd65c77b5f7005c903d97971d62a898597c6e4a79e70aa39037932fbc4e71cb5ecf5ce11e3e1ddeafce21f96cf324475fc8833a9ebef6d7f6d7783580a59a94db2d3774e7aad5e51af0efb46ccc1701085edd34d5346dcbf3ccfe37d5ae97e6a699bda37a567ffffe0b6fd158db3dbd94b861c04dee5fff3fffb6abfafff9fe0aabd7e5fca1f61eeb642dadac8b6b6b64dad2e0 "
    
    // 通过回调返回解码后的 CMSampleBuffer
    private var sampleBufferCallback: ((CVImageBuffer) -> Void)?
    
    init(sampleBufferCallback: @escaping (CVImageBuffer) -> Void) {
        self.sampleBufferCallback = sampleBufferCallback
        print("VideoDecoder  init(sampleBufferCallback")

    }
    
    deinit {
        print("VideoDecoder  deinit")

        if let session = vtDecompressionSession {
            VTDecompressionSessionInvalidate(session)
        }
    }
    
    func  applicationWillResignActive(){
//        if let session = vtDecompressionSession {
//            VTDecompressionSessionInvalidate(session)
//        }
//        vtDecompressionSession = nil

    }
    
    private func subscribeToBluetoothData(data: Data) {
        self.handleH264Data(data)
    }
    
    public func testH264(){
         let data = Data(hexEncoded: originHexData)
         handleH264Data(data!)
    }
    
    public func handleOriginH264Data(_ originData: Data) {
        // 解析 keyFrame 标志
        let keyFrameFlag = originData[0]
        let isKeyFrame = keyFrameFlag == 0x02
//        print("isKeyFrame = \(isKeyFrame)",level: 3)
//        print("originData = \(originData.hexEncodedString())",level: 3)
        
        // 提取 H.264 数据部分
        let data = originData.subdata(in: 5..<originData.count)
        handleH264Data(data)
    }
    var sessionUseCount = 160
    public func handleH264Data(_ data: Data) {
        // 将接收到的数据追加到缓冲区
      
//        print("追加数据到缓冲区，当前缓冲区长度: \(h264Buffer.count)")
        
        // 尝试分割 NAL 单元
        let nalUnits = splitNALUnits(data: data)
        
        // 计算已处理的数据长度
        var processedLength = 0
        for nal in nalUnits.nalUnits {
            // 根据实际检测到的起始码长度调整，此处假设每个起始码为3或4字节
            processedLength += nal.count
        }
        
        for nal in nalUnits.nalUnits {
            guard nal.count > 0 else { continue }
            let nalType = nal[0] & 0x1F
//             print("处理 NAL 单元类型: \(nalType)")
            switch nalType {
            case 7:
                // SPS
                spsData = nal
//                print("接收到 SPS，长度: \(spsData!.count) 字节，内容: \(spsData!.hexEncodedString())")
                if spsData!.count < 9 { // 假设完整的 SPS 至少20字节
                    print(" spsData!.count =\(spsData!.count)")
//                    continue
                }
            case 8:
                // PPS
                ppsData = nal
//                print("接收到 PPS，长度: \(ppsData!.count) 字节，内容: \(ppsData!.hexEncodedString())")
                if ppsData!.count < 5 { // 假设完整的 PPS 至少5字节
                    print(" ppsData!.count = \(ppsData!.count)")
//                    continue
                }
            case 5:
                // IDR 帧（I 帧）
                if let sps = spsData, let pps = ppsData, vtDecompressionSession == nil {
//                if let sps = spsData, let pps = ppsData , sessionUseCount > 80{
//                if let sps = spsData, let pps = ppsData{
                    setupDecompressionSession(sps: sps, pps: pps)
                    sessionUseCount = 0
                }else {
//                    print("I 帧 PPS sps不存在")
                    if let sps = spsData, let pps = ppsData{//Description每次都创建
                        setupH264ParameterDescription(sps: sps, pps: pps)
                    }
                }
                sessionUseCount += 1
             
                decodeH264Data(nal)
            case 1:
                // P 帧
                if vtDecompressionSession == nil {
                    print("尚未初始化解码会话，跳过 P 帧")
                    continue
                }
                decodeH264Data(nal)
            default:
                print("未处理的 NAL 单元类型: \(nalType)")
                break
            }
        }
    }
    
    private func setupDecompressionSession(sps: Data, pps: Data) {
        // 创建视频格式描述
        // 确保 SPS 和 PPS 数据完整
//        guard sps.count >= 9, pps.count >= 4 else {
//            print("SPS 或 PPS 数据不完整，无法创建格式描述。")
//            return
//        }
        if(!setupH264ParameterDescription(sps: sps, pps: pps)){
            return
        }
        
        // 配置解码参数
        var callback = VTDecompressionOutputCallbackRecord()
        callback.decompressionOutputCallback = decompressionOutputCallback
//        callback.decompressionOutputRefCon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
//        callback.decompressionOutputRefCon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self))
        callback.decompressionOutputRefCon = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        let imageBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            kCVPixelBufferWidthKey: 320,
            kCVPixelBufferHeightKey: 240,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ] as [CFString : Any]
        
        // 创建解码会话
        let statusSession = VTDecompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            formatDescription: formatDescription!,
            decoderSpecification: nil,
            imageBufferAttributes: imageBufferAttributes as CFDictionary,
            outputCallback: &callback,
            decompressionSessionOut: &vtDecompressionSession
        )
        
        if statusSession != noErr {
            print("无法创建解码会话: \(statusSession)")
            return
        }
        VTSessionSetProperty(self.vtDecompressionSession!, key: kVTDecompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        
        print("解码会话已初始化。")
    }
    
    private func splitNALUnits(data: Data) -> (nalUnits: [Data], remaining: Data) {
        var nalUnits: [Data] = []
        var startCodes: [Int] = []
        let bytes = [UInt8](data)
        let dataCount = bytes.count
        var fourOnce = false
        // 遍历数据，查找所有起始码的位置
        var i = 0
        while i < dataCount - 3 {
            // 检查 4 字节起始码
            if !fourOnce {
                if bytes[i] == 0x00 && bytes[i+1] == 0x00 && bytes[i+2] == 0x00 && bytes[i+3] == 0x01 {
                    startCodes.append(i)
                    i += 4
                    // fourOnce = true
                    continue
                }
            }
            
            // 检查 3 字节起始码
            if bytes[i] == 0x00 && bytes[i+1] == 0x00 && bytes[i+2] == 0x01 {
                startCodes.append(i)
                i += 3
                continue
            }
            i += 1
        }
        
        // 如果在最后还有可能的起始码
        if i < dataCount - 2 {
            if bytes[i] == 0x00 && bytes[i+1] == 0x00 && bytes[i+2] == 0x01 {
                startCodes.append(i)
                i += 3
            }
        }
        
        // 如果没有找到任何起始码，返回空数组和原始数据
        if startCodes.isEmpty {
            return ([], data)
        }
        
        // 分割 NAL 单元
        for j in 0..<startCodes.count {
            let start = startCodes[j]
            let startCodeLength: Int
            if j < startCodes.count - 1 {
                let nextStart = startCodes[j + 1]
                // 确定当前起始码的长度
                if start + 4 <= dataCount && bytes[start] == 0x00 && bytes[start+1] == 0x00 && bytes[start+2] == 0x00 && bytes[start+3] == 0x01 {
                    startCodeLength = 4
                } else {
                    startCodeLength = 3
                }
                let nalStart = start + startCodeLength
                if nalStart < nextStart {
                    let nalUnit = data.subdata(in: nalStart..<nextStart)
                    nalUnits.append(nalUnit)
                }
            } else {
                // 最后一个起始码后的数据
                let startCodeLengthForLast: Int
                if start + 4 <= dataCount && bytes[start] == 0x00 && bytes[start+1] == 0x00 && bytes[start+2] == 0x00 && bytes[start+3] == 0x01 {
                    startCodeLengthForLast = 4
                } else {
                    startCodeLengthForLast = 3
                }
                let nalStart = start + startCodeLengthForLast
                if nalStart < dataCount {
                    let nalUnit = data.subdata(in: nalStart..<dataCount)
                    nalUnits.append(nalUnit)
                }
            }
        }
        
        // 确定剩余未处理的数据
        let lastStartCode = startCodes.last!
        let lastStartCodeLength: Int
        if lastStartCode + 4 <= dataCount && bytes[lastStartCode] == 0x00 && bytes[lastStartCode+1] == 0x00 && bytes[lastStartCode+2] == 0x00 && bytes[lastStartCode+3] == 0x01 {
            lastStartCodeLength = 4
        } else {
            lastStartCodeLength = 3
        }
        
        let processedLength = lastStartCode + lastStartCodeLength
        let remainingData: Data
        if processedLength < dataCount {
            remainingData = data.subdata(in: processedLength..<dataCount)
        } else {
            remainingData = Data()
        }
        
        return (nalUnits, remainingData)
    }
    
    
    private func setupH264ParameterDescription(sps: Data, pps: Data) -> Bool{
        var spsBytes: [UInt8] = []
        [UInt8](sps).forEach { (value) in
            spsBytes.append(value)
        }
        var ppsBytes: [UInt8] = []
        [UInt8](pps).forEach { (value) in
            ppsBytes.append(value)
        }
        
        let parameterSetPointers = [spsBytes.withUnsafeBufferPointer { $0.baseAddress! }, ppsBytes.withUnsafeBufferPointer { $0.baseAddress! }]
        let parameterSetSizes: [Int] = [spsBytes.count, ppsBytes.count]
        guard parameterSetPointers.count == 2 else {
            print("parameterSetPointers 参数集不完整")
            return false
        }
        
        let status = CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: kCFAllocatorDefault,
                                                                         parameterSetCount: 2,
                                                                         parameterSetPointers: parameterSetPointers,
                                                                         parameterSetSizes: parameterSetSizes,
                                                                         nalUnitHeaderLength: 4,
                                                                         formatDescriptionOut: &formatDescription)
        if status != noErr {
            print("无法创建 CMVideoFormatDescription: \(status)")
            return false
        }
        return true
    }
    
    private func decodeH264Data(_ data: Data) {
        guard let session = vtDecompressionSession, let formatDescription = formatDescription else {
            print("解码会话尚未初始化。")
            return
        }
        var naluSize = data.count
        let length: [UInt8] = [
            UInt8(truncatingIfNeeded: naluSize >> 24),
            UInt8(truncatingIfNeeded: naluSize >> 16),
            UInt8(truncatingIfNeeded: naluSize >> 8),
            UInt8(truncatingIfNeeded: naluSize)
        ]
        var frameByte: [UInt8] = length
        [UInt8](data).forEach { (bb) in
            frameByte.append(bb)
        }
        let frameData = Data(frameByte)
        let frameSize = frameData.count
        
        let memoryBlock = malloc(frameSize)
        
        guard let memoryBlockPointer = memoryBlock else {
            print("无法分配内存")
            return
        }
        
        // 将数据复制到分配的内存块中
        frameData.copyBytes(to: memoryBlockPointer.assumingMemoryBound(to: UInt8.self), count: frameSize)
        
        // 创建CMBlockBuffer
        var blockBuffer: CMBlockBuffer?
        let statusBlock = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: memoryBlockPointer,
            blockLength: Int(frameSize),
            blockAllocator: nil,
            customBlockSource: nil,
            offsetToData: 0,
            dataLength: Int(frameSize),
            flags: 0,
            blockBufferOut: &blockBuffer
        )
        
        if statusBlock != kCMBlockBufferNoErr {
            print("无法创建CMBlockBuffer: \(statusBlock)")
            print("无法创建CMBlockBuffer: \(statusBlock.description)")
            return
        }
        
        // 创建CMSampleBuffer
//        var sampleBuffer: CMSampleBuffer?
//        var sampleTiming = CMSampleTimingInfo()
//        
//        let statusSample = CMSampleBufferCreate(
//            allocator: kCFAllocatorDefault,
//            dataBuffer: blockBuffer,
//            dataReady: true,
//            makeDataReadyCallback: nil,
//            refcon: nil,
//            formatDescription: formatDescription,
//            sampleCount: 1,
//            sampleTimingEntryCount: 0,
//            sampleTimingArray: nil,
//            sampleSizeEntryCount: 0,
//            sampleSizeArray: nil,
//            sampleBufferOut: &sampleBuffer
//        )
//        
//        if statusSample != noErr {
//            print("无法创建CMSampleBuffer: \(statusSample)")
//            return
//        }
        var sampleSizeArray :[Int] = [Int(frameSize)]
        var sampleBuffer :CMSampleBuffer?
        //创建sampleBuffer
        /*
         参数1: allocator 分配器,使用默认内存分配, kCFAllocatorDefault
         参数2: blockBuffer.需要编码的数据blockBuffer.不能为NULL
         参数3: formatDescription,视频输出格式
         参数4: numSamples.CMSampleBuffer 个数.
         参数5: numSampleTimingEntries 必须为0,1,numSamples
         参数6: sampleTimingArray.  数组.为空
         参数7: numSampleSizeEntries 默认为1
         参数8: sampleSizeArray
         参数9: sampleBuffer对象
         */
        let readyState = CMSampleBufferCreateReady(allocator: kCFAllocatorDefault,
                                  dataBuffer: blockBuffer,
                                  formatDescription: formatDescription,
                                  sampleCount: CMItemCount(1),
                                  sampleTimingEntryCount: CMItemCount(),
                                  sampleTimingArray: nil,
                                  sampleSizeEntryCount: CMItemCount(1),
                                  sampleSizeArray: &sampleSizeArray,
                                  sampleBufferOut: &sampleBuffer)
        if readyState != 0 {
            print("无法创建CMSampleBuffer: \(readyState)")
            return
        }
        let flags: VTDecodeFrameFlags = []
        var infoFlags = VTDecodeInfoFlags()
        
        let sourceFrame: UnsafeMutableRawPointer? = nil
        
        // 解码
        let decodeStatus = VTDecompressionSessionDecodeFrame(
            session,
            sampleBuffer: sampleBuffer!,
            flags: VTDecodeFrameFlags._EnableAsynchronousDecompression,
            frameRefcon: sourceFrame,
            infoFlagsOut: &infoFlags
        )
        
        if decodeStatus != noErr {
            print("解码失败: \(decodeStatus)")
            vtDecompressionSession = nil
        }
    }
    
    public func resetFrameNumber(){
        frameNumber = 0
    }
    
    // 解码输出回调
    private let decompressionOutputCallback: VTDecompressionOutputCallback = { (
        decompressionOutputRefCon,
        sourceFrameRefCon,
        status,
        infoFlags,
        imageBuffer,
        presentationTimeStamp,
        presentationDuration
    ) in
        guard status == noErr, let imageBuffer = imageBuffer else {
            print("解码错误: \(status)")
            return
        }
                let decoder = Unmanaged<VideoDecoder>.fromOpaque(decompressionOutputRefCon!).takeUnretainedValue()
 
        decoder.sampleBufferCallback?(imageBuffer)

//        guard let formatDescription = decoder.createFormatDescription(for: imageBuffer) else { return }
        // 将解码后的图像通过回调返回

//        
//        decoder.frameNumber += 1
//        var timingInfo = CMSampleTimingInfo(
//            duration: CMTime(value: 1, timescale: 10), // 假设帧率为 30 FPS，每帧持续时间 1/30 秒
//            presentationTimeStamp: CMTime(value: CMTimeValue(decoder.frameNumber), timescale: 10), // 根据帧序号递增时间戳
//            decodeTimeStamp: .invalid // DTS 可设为无效
//        )
//        
//        var newSampleBuffer: CMSampleBuffer?
//        let statusCreate = CMSampleBufferCreateForImageBuffer(
//            allocator: kCFAllocatorDefault,
//            imageBuffer: imageBuffer,
//            dataReady: true,
//            makeDataReadyCallback: nil,
//            refcon: nil,
//            formatDescription: formatDescription,
//            sampleTiming: &timingInfo,
//            sampleBufferOut: &newSampleBuffer
//        )
//        
//        if statusCreate == noErr, let sampleBuffer = newSampleBuffer {
//            decoder.sampleBufferCallback?(sampleBuffer)
//        } else {
//            print("无法创建解码后的CMSampleBuffer: \(statusCreate)")
//        }
    }
    
    func createFormatDescription(for imageBuffer: CVImageBuffer) -> CMVideoFormatDescription? {
        var formatDescription: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: imageBuffer,
            formatDescriptionOut: &formatDescription
        )
        guard status == noErr else {
            print("无法创建格式描述: \(status)")
            return nil
        }
        return formatDescription
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    init?(hexEncoded string: String) {
        // 去除字符串中的空格等不必要字符（如果有）
        let hexString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查字符串长度是否为偶数，否则返回 nil
        guard hexString.count % 2 == 0 else { return nil }
        
        // 初始化空的 Data 对象
        var data = Data()
        
        // 遍历字符串，每次取两个字符并转换为字节
        var index = hexString.startIndex
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            let byteString = hexString[index..<nextIndex]
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                return nil // 如果转换失败，返回 nil
            }
            index = nextIndex
        }
        
        self = data
    }
}
