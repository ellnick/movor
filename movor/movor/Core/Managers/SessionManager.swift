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
    
    var localizedDescription: String {
        switch self {
            case .uploadStoreNotProvided:
                return "Upload Store not provided"
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
        let upload = tusSession?.createUpload(fromFile: fromFile, retry: -1, headers: nil, metadata: nil)
        
        upload?.progressBlock = progress
        upload?.resultBlock = result
        upload?.failureBlock = failure
        
        upload?.resume()
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
