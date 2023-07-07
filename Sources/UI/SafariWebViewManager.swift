//
//  File.swift
//
//
//  Created by lmcmz on 14/11/21.
//


import UIKit
import WebKit

class SafariWebViewManager: NSObject, WKNavigationDelegate {
    static var shared = SafariWebViewManager()
    var webView: WKWebView?
    var delegate: HTTPSessionDelegate?
    
    static func openSafariWebView(url: URL) {
        DispatchQueue.main.async {
            let webView = WKWebView()
            webView.navigationDelegate = SafariWebViewManager.shared
            webView.frame = CGRect(origin: .zero, size: CGSize(width: 800.0, height: 800.0))
            SafariWebViewManager.shared.webView = webView
            UIApplication.shared.topMostViewController?.view.addSubview(webView)
            webView.load(URLRequest(url: url))
        }
    }
    
    static func dismiss() {
        if let webView = SafariWebViewManager.shared.webView {
            DispatchQueue.main.async {
                webView.removeFromSuperview()
            }
            SafariWebViewManager.shared.stopPolling()
        }
    }

    
    func stopPolling() {
        delegate?.isPending = false
    }
}

extension SafariWebViewManager {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopPolling()
    }

    func presentationControllerDidDismiss(_: UIPresentationController) {
        stopPolling()
    }
}

