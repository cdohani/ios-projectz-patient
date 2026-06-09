//
//  WebViewVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 08/06/2026.
//

import UIKit
import WebKit

class WebViewVC: ParentViewController {
    //MARK: Outlets
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var webView: WKWebView!
    
    //MARK: Variable
    var url = ""
    var heading = ""
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        lblHeading.text = heading
        let url = URL(string: url)!
        webView.load(URLRequest(url: url))
    }
    
    //MARK: Functions
    
    
    
    //MARK: ButtonActions
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension WebViewVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            let js = """
            document.querySelector('.baselayout-header')?.remove();
            document.querySelector('section.bg-primaryBlue')?.style.setProperty('display', 'none', 'important');
            document.querySelector('.bg-primaryBlue.container')?.remove();
            """

            webView.evaluateJavaScript(js)
        }
    }
}
