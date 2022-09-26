//
//  File.swift
//  
//
//  Created by Hao Fu on 26/9/2022.
//

import Foundation
import Flow
import AuthenticationServices

protocol HTTPSessionDelegate {
    // TODO: Improve this
    var isPending: Bool { get set }
    var session: ASWebAuthenticationSession? { get set }
    func openAuthenticationSession(service: FCL.Service) throws
    func closeSession()
}

extension FCL {
    class HTTPProvider: NSObject, FCLStrategy {
        internal let api = API()
        internal var session: ASWebAuthenticationSession?
        // TODO: Improve this
        internal var isPending = true
        
        override init() {
            super.init()
            api.delegate = self
        }
        
        func execService(url: URL, data: Data?) async throws -> FCL.Response {
            return try await api.execHttpPost(url: url, data: data)
        }
    }
}

extension FCL.HTTPProvider: HTTPSessionDelegate {
    
    // MARK: - Session

    func openAuthenticationSession(service: FCL.Service) throws {
        guard let endpoint = service.endpoint,
              let url = buildURL(url: endpoint, params: service.params)
        else {
            throw FCLError.invalidSession
        }

        DispatchQueue.main.async {
            fcl.delegate?.hideLoading()

            if service.type == .authn {
                let session = ASWebAuthenticationSession(url: url,
                                                         callbackURLScheme: nil) { _, _ in
                    self.isPending = false
                }
                self.session = session
                session.presentationContextProvider = self
                session.prefersEphemeralWebBrowserSession = false
                session.start()
            } else {
                SafariWebViewManager.openSafariWebView(url: url)
            }
        }
    }
    
    internal func closeSession() {
        DispatchQueue.main.async {
            self.session?.cancel()
        }
    }
}

extension FCL.HTTPProvider: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let anchor = fcl.delegate?.presentationAnchor() {
            return anchor
        }
        return ASPresentationAnchor()
    }
}
