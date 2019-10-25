//
//  WMWebView.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 25/10/2019.
//

import WebKit

class WMWebView: WKWebView {
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let scriptString = "setInterval(() => console.log(\"This was called from WMWebView\"), 1000)"
        let script = WKUserScript(source: scriptString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
    }
}
