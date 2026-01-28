//
//  SJ2BaseNodeTask.swift
//  SJWatchLib
//
//  Created by t_t on 2023/10/17.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit

//@objc protocol SJ2ResponseToWatchDelegate {
//    func response(urnString: String, data: Any?, response: @escaping (Any) -> Void)
//}
//
//extension SJ2ResponseToWatchDelegate {
//    func response(urnString: String, data: Any?, response: @escaping (Any) -> Void) {
//        
//    }
//}

protocol SJTLOCPWriteEnable {
    init?(data: Data)
    var toData: [Data] {get}
    
    var packageCount: Int {get}
    static var urnString: String {get}
    static var data_fmt: DataFormat {get}
    static var errorNoDataHandler: Self? {get}
}

extension SJTLOCPWriteEnable {
    var packageCount: Int {1}
    static var data_fmt: DataFormat {.bin}
    static var urn: [UInt8] {
        return .init(urnString.data(using: .ascii)!)
    }
    static var errorNoDataHandler: Self? {nil}
}

class SJ2BaseNodeTask<T: SJTLOCPWriteEnable>: MTBleTask {
    var desc: String {"节点名称"}
    var timeout: Int {30}
    var needListen: Bool {false}
    var needRepeat: Bool {false} //相同2个命令没有结果前，第1个命令没有收到回复，第2个命令就已经发出去了，这时，如果needRepeat是false，就会忽略
    var needPrint: Bool {false}
    
    var isNotifyRead = false
    
    var readDisposeBag = DisposeBag()
    var sendDisposeBag = DisposeBag()
    var lastTaskType: PackageType?
    
//    weak var delegate: SJ2ResponseToWatchDelegate?
    
    override init(ble: MTWatchPeripheral) {
        super.init(ble: ble)
        self.listen(ble: ble)
    }
    
    func lock() {
//        self.ble?.semaphore.wait()
    }
    func unlock() {
//        self.ble?.semaphore.signal()
    }
    
    func listen(ble: MTWatchPeripheral) {
        
//        ble.tlocp2Response
//            .filter{$0.model.items.contains(where: {$0.urnString == T.urnString})}
//            .compactMap{[weak self] in self?.decoder(rs: $0.model).0}
//            .bind {[weak self] model in
//                guard let self = self else {return}
//                self.response.accept(model)
////                self.publishResponse.accept(model)
//            }
//            .disposed(by: self.disposeBag)
//
//        ble.tlocp2Request
//            .filter{
//                //MTLog.debug("urn: \($0.model.items.map{$0.urnString}), T.urn: \(T.urnString)")
//                return $0.model.items.contains(where: {$0.urnString == T.urnString})
//            }
//            .bind {[weak self] rs in
//                guard let self = self else {return}
//                if rs.model.type == .notify && rs.model.emptyData {
//                    let id = PayloadPackage.requestId()
//                    let datas = PayloadPackage.tlopcDataRequestFrom(id: id, rawDatas: [], type: .read, urn: T.urn, data_fmt: T.data_fmt)
//                    self.sendData(datas: datas, index: 0)
//                    //MTLog.debug(">>>>>>>>>>>>> rs.model.emptyData")
//                }else if let model = self.decoder(rs: rs.model).0 {
//                    self.response.accept(model)
//                    self.publishResponse.accept(model)
//                }
//            }
//            .disposed(by: self.disposeBag)
        
        //回复notify
//        Observable.of(ble.tlocp2Response, ble.tlocp2Request)
//            .merge()
//            .filter{
////                MTLog.debug("urn: \($0.model.items.map{$0.urnString}), T.urn: \(T.urnString)")
//                return $0.model.items.contains(where: {$0.urnString == T.urnString})
//            }
//            .compactMap{[weak self] in self?.decoder(rs: $0.model).0}
//            .bind {[weak self] model in
//                self?.delegate?.response(urnString: T.urnString, data: model, response: {[weak self] data in
//                    guard let model = data as? T else {return}
//                    self?.sendDataFrom(model: model)
//                })
//            }
//            .disposed(by: self.disposeBag)
    }
    
    func sendDataFrom(model: T) {
        let id = PayloadPackage.requestId()
        PayloadPackage.tlopcDataFrom(id: id, rawDatas: model.toData, type: .execute, command: 0x0002, urn: T.urn, data_fmt: T.data_fmt) {[weak self] datas in
            guard let self = self else {return}
            self.sendData(datas: datas, index: 0)
        }
    }
    
    func dataChange(data: T) {
        
    }

    

    
//    func rx_read(data: Data = Data(), needLock: Bool = true) -> Observable<T> {
////        if let last = self.lastTaskType,
////           last == .read,
////           !needRepeat {
////            return .just(self.response.value!)
////        }
//        return .create {[weak self] observer in
//            var disconnectDisposable: Disposable?
//            var sendDisposable: Disposable?
//            
//            guard let self = self, let ble = self.ble else {
//                observer.onError(.mt(.disconnect))
//                return Disposables.create {
//                    disconnectDisposable?.dispose()
//                    sendDisposable?.dispose()
//                }
//            }
//            
//            MTLog.debug("read: \(self.desc) 准备中")
//            self.lastTaskType = .read
//            
//            ble.semaphore_queue.async {
//                if needLock {
//                    self.lock()
//                    //MTLog.debug(">>>>>>>> semaphore1 +1 \(Thread.current)")
//                }
//                
////                disconnectDisposable = ble.bleIsConnect.filter{$0 == false}.bind { _ in
////                    observer.onError(.mt(.disconnect))
////                }
//                
//                let id = PayloadPackage.requestId()
//                
//                let datas = PayloadPackage.tlopcDataRequestFrom(id: id, rawDatas: [data], type: .read, urn: T.urn, data_fmt: T.data_fmt)
//                self.sendData(datas: datas, index: 0)
//                MTLog.debug("read: \(self.desc) 执行")
//                
//                sendDisposable = Observable.of(ble.tlocp2Response, ble.tlocp2Request)
//                    .merge()
//                    .filter{$0.model.items.contains(where: {$0.urnString == T.urnString})}
//                    .take(1)
//                    .take(until: ble.bleIsConnect.filter{!$0})
//                    .timeout(.seconds(self.timeout), scheduler: MainScheduler.asyncInstance)
//                    .do(onDispose: {[weak self] in
//                        self?.lastTaskType = nil
//                        if needLock {
//                            self?.unlock()
//                            //MTLog.debug(">>>>>>>> semaphore -1 \(Thread.current)")
//                        }
//                    })
//                    .subscribe(onNext: {[weak self] pmodel in
//                        guard let self = self else {return}
//                        
//                        let rs = pmodel.model
//                        let rsModel = self.decoder(rs: rs)
//                        if let model = rsModel.0 {
//                            MTLog.debug("read: \(self.desc) 成功")
//                            observer.onNext(model)
//                        }else if let first = rs.items.first, let error = first.error, error == .NODATA, let model = T.errorNoDataHandler {
//                            MTLog.debug("read: \(self.desc) 成功, 空数据")
//                            observer.onNext(model)
//                        }else if let error = rsModel.1 {
//                            MTLog.debug("read: \(self.desc) 失败")
//                            observer.onError(error)
//                        }
//                    }, onError: {[weak self] _ in
//                        guard let self = self else {return}
//                        let desc = self.desc
//                        MTLog.debug("read: \(self.desc) 超时")
//                        observer.onError(.mt(.timeout(desc)))
//                    }, onCompleted: {[weak ble, weak self] in
//                        guard let self = self, let ble = ble else {return}
//                        observer.onError(.mt(.disconnect))
//                        MTLog.debug("read: \(self.desc) 完成: state: \(ble.bleIsConnect.value)")
//                    })
//            }
//            
//            return Disposables.create {
//                disconnectDisposable?.dispose()
//                sendDisposable?.dispose()
//            }
//        }
//        .share(replay: 1)
//        .take(1)
//    }
//    
    func rx_write(model: T) -> Observable<T?> {
        return rx_send(type: .write, model: model)
    }
    
    func rx_execute(model: T) -> Observable<T?> {
        return rx_send(type: .execute, model: model)
    }
    
    func rx_send(type: PackageType, model: T) -> Observable<T?> {
        if let last = self.lastTaskType,
           last == type,
           !needRepeat {
            MTLog.error("rx_send 重复 忽略 type = \(type)")
            return .empty()
        }
        
//        var disconnectDisposable: Disposable?
        var sendDisposable: Disposable?
        
        return .create {[weak self] observer in
            guard let self = self, let ble = self.ble else {
                observer.onError(.mt(.disconnect))
                return Disposables.create {
//                    disconnectDisposable?.dispose()
                    sendDisposable?.dispose()
                }
            }
            
            MTLog.debug("\(type.desc): \(self.desc) 准备中")
            self.lastTaskType = type
            
            ble.semaphore_queue.async {
                self.lock()
                //MTLog.debug(">>>>>>>> semaphore2 +1 \(Thread.current)")
                
//                disconnectDisposable = ble.bleIsConnect.filter{$0 == false}.bind { _ in
//                    observer.onError(.mt(.disconnect))
//                }
                
                let id = PayloadPackage.requestId()
                let mtuObservable: Observable<Int>
                
                mtuObservable = .just(0)
                
                sendDisposable = mtuObservable.flatMapFirst {[weak self, weak ble] mtu -> Observable<MTWatchPeripheral.TLOCP2GroupResult?> in
                    if let self = self, let ble = ble {
                        PayloadPackage.tlopcDataFrom(id: id, rawDatas: model.toData, type: type, command: 0x0001, mtu: mtu, urn: T.urn, data_fmt: T.data_fmt) {[weak self] datas in
                            guard let self = self else {return}
                            MTLog.debug("\(type.desc): \(self.desc) 执行")
                            self.sendData(datas: datas, index: 0)
                        }
                        
                        return Observable.of(ble.tlocp2Response)
                            .merge()
                            .map{$0}
                    }else {
                        return .just(nil)
                    }
                }
                .compactMap{$0}
                .filter{$0.model.items.contains(where: {$0.urnString == T.urnString})}
                .take(1)
                .timeout(.seconds(self.timeout), scheduler: MainScheduler.asyncInstance)
                .do(onDispose: {[weak self] in
                    guard let self = self else {return}
                    self.lastTaskType = nil
                        self.unlock()
                        //MTLog.debug(">>>>>>>> semaphore -1 \(Thread.current)")
                })
                .subscribe(onNext: { pmodel in
                    
                    let rs = pmodel.model
                    
                    if rs.type == .all_ok {
                        MTLog.debug("\(type.desc): \(self.desc) 成功")
                        observer.onNext(model)
                    }else if let first = rs.items.first, let error = first.error {
                        if error == .OK {
                            MTLog.debug("\(type.desc): \(self.desc) 成功")
                            observer.onNext(model)
                        }else {
                            MTLog.debug("\(type.desc): \(self.desc) 失败")
                            observer.onError(error)
                        }
                    }else if let model = self.decoder(rs: rs).0 {
//                        if self.desc == "设置连接类型"{
//                            MTLog.debug("\(type.desc): \(self.desc) 失败")
//                            observer.onError(.mt(.timeout("test102E")))
//                        }else {
                            MTLog.debug("read: \(self.desc) 成功")
                            observer.onNext(model)
                    }else {
                        MTLog.debug("\(type.desc): \(self.desc) 失败")
                        observer.onError(.mt(.other))
                    }
                }, onError: {[weak self] _ in
                    guard let self = self else {return}
                    let desc = self.desc
                    MTLog.debug("\(type.desc): \(self.desc) 超时")
                    observer.onError(.mt(.timeout(desc)))
                }, onCompleted: {[weak ble, weak self] in
                    guard let self = self, let ble = ble else {return}
                    observer.onError(.mt(.disconnect))
                    MTLog.debug("\(type.desc): \(self.desc) 完成: ")
                })
                
            }
            
            return Disposables.create {
//                disconnectDisposable?.dispose()
                sendDisposable?.dispose()
            }
        }
        .share(replay: 1)
        .take(1)
    }
    
    // 新增：处理响应的辅助方法
    private func handleResponse(
        pmodel: MTWatchPeripheral.TLOCP2GroupResult,
        type: PackageType,
        model: T,
        observer: AnyObserver<T?>
    ) {
        let rs = pmodel.model
        
        if rs.type == .all_ok {
            MTLog.debug("\(type.desc): \(self.desc) 成功")
            observer.onNext(model)
        } else if let first = rs.items.first, let error = first.error {
            if error == .OK {
                MTLog.debug("\(type.desc): \(self.desc) 成功")
                observer.onNext(model)
            } else {
                MTLog.debug("\(type.desc): \(self.desc) 失败")
                observer.onError(error)
            }
        } else if let decodedModel = self.decoder(rs: rs).0 {
            MTLog.debug("read: \(self.desc) 成功")
            observer.onNext(decodedModel)
        } else {
            MTLog.debug("\(type.desc): \(self.desc) 失败")
            observer.onError(.mt(.other))
        }
    }
    
//    func read(data: Data = Data()) -> Promise<T> {
//        return .init {[weak self] event in
//            guard let self = self else {
//                event.reject(.mt(.disconnect))
//                return
//            }
//            
//            self.readDisposeBag = .init()
//            
//            self.rx_read(data: data).subscribe { model in
//                event.fulfill(model)
//            } onError: { error in
//                event.reject(error)
//            }.disposed(by: self.readDisposeBag)
//        }
//    }
    
    func write(model: T)-> Promise<Void> {
        return .init {[weak self] event in
            guard let self = self else {
                event.reject(.mt(.disconnect))
                return
            }
            
            self.readDisposeBag = .init()
            
            self.rx_write(model: model).subscribe { model in
                event.fulfill(())
            } onError: { error in
                event.reject(error)
            }.disposed(by: self.readDisposeBag)
        }
    }
    
    func execute(model: T)-> Promise<T?> {
        return .init {[weak self] event in
            guard let self = self else {
                event.reject(.mt(.disconnect))
                return
            }
            
            self.readDisposeBag = .init()
            
            self.rx_execute(model: model).subscribe { model in
                event.fulfill(model)
            } onError: { error in
                event.reject(error)
            }.disposed(by: self.readDisposeBag)
        }
    }
    
    func sendData(datas: [Data], index: Int) {
        self.sendDisposeBag = .init()
        guard let ble = self.ble, index < datas.count else {
            self.sendDisposeBag = .init()
            return
        }
        
        let data = datas[index]
        ble.sendIfNeed(data)

//        if self.needPrint {
//            MTLog.debug("发送 \(self.desc): \(data.toHexString())")
//        }
        
        ble.fff2Data
            .filter{$0.sceneId == 0x30 && $0.commandId == 0x8004}
            .filter{$0.payload.count == 2}
            .filter{$0.payload[1] == data[1]}
            .bind {[weak self] model in
                guard let self = self else {return}
                let rs = model.payload
                if rs.count == 2, rs[0] == 1 {
                    self.sendData(datas: datas, index: index+1)
                }
            }
            .disposed(by: self.sendDisposeBag)
    }
    
    func decoder(rs: TLOCP2PackageModel?) -> (T?, Error?) {
        guard let rs = rs else {return (nil, .mt(.other))}
        
        var data = Data()
        for item in rs.items {
            if let _data = item.urnData {
                data.append(_data)
            }
        }
        
        let model = T(data: data)
        if let model = model {
            return (model, nil)
        }
        return (nil, .mt(.other))
    }
    
    override func cancel() {
        super.cancel()
    }
    
    override func bleDisconnectHandler() {
        self.readDisposeBag = DisposeBag()
        self.sendDisposeBag = DisposeBag()
    }
}
