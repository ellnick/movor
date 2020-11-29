//
//  SessionManager.swift
//  movor
//
//  Created by Elizabeth Saltykova on 26.11.2020.
//

import TUSKit
import Foundation

enum SessionManagerError: Error {
    case uploadStoreNotProvided
    case uploadNotCreated
    
    var localizedDescription: String {
        switch self {
            case .uploadStoreNotProvided:
                return "Upload Store not provided"
            case .uploadNotCreated:
                return "Upload Not created"
        }
    }
}


typealias TUSUploadProgress = ((_ bytesWritten: __int64_t, _ bytesTotal: __int64_t) -> ())
typealias TUSUploadResult = ((_ url: URL) -> ())
typealias TUSUploadFailure = ((_ error: Error) -> ())


protocol SessionManagerProtocol: class {
    
    func startSession(endpoint: URL, _ completionHandler: (Error?) -> Void)
    func stopSession()
    
    func upload(fromFile: URL)
    
    func cancelAll()
    func stop(_ completionHandler: (() -> Void)?)
    
    func resumeAll()
    
    var progress: TUSUploadProgress? { get set }
    var result: TUSUploadResult? { get set }
    var failure: TUSUploadFailure? { get set }
    
}

class SessionManager: SessionManagerProtocol {
    
    static let fileName: String = "TuskFileStore"
    
    // MARK: - Public
    
    public var progress: TUSUploadProgressBlock?
    
    public var result: TUSUploadResult?
    
    public var failure: TUSUploadFailure?
    
    // MARK: - Private
    
    private var tusSession: TUSSession?
    
    private var uploadStore: TUSUploadStore?
    
    private var currentUpload: TUSResumableUpload?
    
    // MARK: - Init
    
    init() {}
    
    // MARK: - Public
    
    func startSession(endpoint: URL, _ completionHandler: (Error?) -> Void) {
        
        guard let uploadStore = getUploadStore() else {
            completionHandler(SessionManagerError.uploadStoreNotProvided)
            return
        }
        
        tusSession = TUSSession(endpoint: endpoint, dataStore: uploadStore, sessionConfiguration: URLSessionConfiguration.default)
        completionHandler(nil)
    }
    
    func stopSession() {
        tusSession = nil
        uploadStore = nil
    }
    
    func upload(fromFile: URL) {
        guard let currentUpload = tusSession?.createUpload(fromFile: fromFile, retry: 1, headers: [:], metadata: [:]) else {
            print("upload was not created")
            return
        }
        
        currentUpload.progressBlock = progress
        currentUpload.resultBlock = result
        currentUpload.failureBlock = failure
        
        let res = currentUpload.resume()
        print("upload res: \(res)")
    }
    
    func stop(_ completionHandler: (() -> Void)?) {
        let res = tusSession?.stopAll()
        
        if res == 1 {
            completionHandler?()
        }
    }
    
    func cancelAll() {
        currentUpload = nil
        tusSession?.cancelAll()
    }
    
    func resume() {
        guard let uploadId = currentUpload?.uploadId else {
            return
        }
        let res = tusSession?.restoreUpload(uploadId)
        
        print("upload res: \(res)")
    }
    
    func resumeAll() {
        
        guard let session = tusSession else {
            return
        }
        
        for upload in session.restoreAllUploads() {
            upload.progressBlock = progress
            upload.resultBlock = result
            upload.failureBlock = failure

        }
        session.resumeAll()
    }
    
    
    // MARK: - Private
    
    private func getUploadStore() -> TUSUploadStore? {
        let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return TUSFileUploadStore.init(url: applicationSupportURL?.appendingPathComponent(SessionManager.fileName))
    }
}
