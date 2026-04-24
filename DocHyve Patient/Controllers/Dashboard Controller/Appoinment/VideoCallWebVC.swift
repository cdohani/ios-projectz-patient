//
//  VideoCallWebVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 14/04/2026.
//

import UIKit
import WebKit

class VideoCallWebVC: UIViewController {

    var webView: WKWebView!
    var roomID: String = "call_123"

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        startCall()
    }

    func startCall() {
        let urlString = "https://meet.dochyve.com/\(roomID)"
        guard let url = URL(string: urlString) else { return }

        webView.load(URLRequest(url: url))
    }
}

extension VideoCallWebVC: WKUIDelegate {

    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {

        completionHandler()
    }
}
