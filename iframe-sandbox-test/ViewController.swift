//
//  ViewController.swift
//  iframe-sandbox-test
//
//  Created by Alastair Coote on 10/7/20.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController, WKURLSchemeHandler, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(self, forURLScheme: "test")
        let webview = WKWebView(frame: self.view.frame, configuration: config)
        webview.navigationDelegate = self
        self.view.addSubview(webview)
        webview.load(URLRequest(url: URL(string: "test://test/index.html")!))
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Recevied request for \(urlSchemeTask.request.url!.path)")
        if urlSchemeTask.request.url!.path == "/index.html" {
            urlSchemeTask.didReceive(HTTPURLResponse(url: urlSchemeTask.request.url!, statusCode: 200, httpVersion: nil, headerFields: [
                "Content-Type": "text/html"
            ])!)
            urlSchemeTask.didReceive(HTMLSource.wrapperPage.rawValue.data(using: .utf8)!)
            urlSchemeTask.didFinish()
        } else if urlSchemeTask.request.url!.path == "/iframe.html" {
            urlSchemeTask.didReceive(HTTPURLResponse(url: urlSchemeTask.request.url!, statusCode: 200, httpVersion: nil, headerFields: [
                "Content-Type": "text/html"
            ])!)
            urlSchemeTask.didReceive(HTMLSource.iframePage.rawValue.data(using: .utf8)!)
            urlSchemeTask.didFinish()
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // Found a bug! WKNavigationAction says sourceFrame isn't nil-able, but it is.
        // Trying to use it directly means you get a runtime error with nil, so instead
        // let's dance around it:

        let sourceFrame = navigationAction.value(forKey: "sourceFrame") as? WKFrameInfo

        // if the sourceFrame is the main frame, ignore
        if sourceFrame?.isMainFrame == false &&
            // if the targetFrame *isn't* the main frame, also ignore
            navigationAction.targetFrame?.isMainFrame == true &&
            // and check if the request is coming from the iframe we want. Maybe we could
            // be using query string/hash params to identify which ad it is?
            sourceFrame?.request.url?.absoluteString == "test://test/iframe.html" {

                decisionHandler(.cancel)
                let vc = SFSafariViewController(url: navigationAction.request.url!)
                present(vc,animated: true)
                return
        }

        decisionHandler(.allow)

    }
}



