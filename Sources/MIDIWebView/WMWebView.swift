//
//  WMWebView.swift
//  MIDIWebView
//
//  Created by Peter Bloxidge on 25/10/2019.
//

import WebKit

public class WMWebView: WKWebView {
    
    private let handler = MIDIMessageHandler()
    
    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        guard let polyfillPath = Bundle.main.path(forResource: "MIDIWebViewPolyfill", ofType: "js"),
            let polyfillScriptString = try? String(contentsOfFile: polyfillPath, encoding: .utf8) else {
            return
        }
        let polyfillScript = WKUserScript(source: polyfillScriptString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            
        // Inject Web MIDI API bridge JavaScript
        configuration.userContentController.addUserScript(polyfillScript)
        configuration.userContentController.add(handler, name: "onready")
        configuration.userContentController.add(handler, name: "send")
        configuration.userContentController.add(handler, name: "clear")
        
        // Inject console.log substitute
//        let logScript = WKUserScript(source: "console.log = message => webkit.messageHandlers.log.postMessage(message)", injectionTime: .atDocumentStart, forMainFrameOnly: true)
//        configuration.userContentController.addUserScript(logScript)
//        configuration.userContentController.add(ConsoleMessageHandler(), name: "log")
    }
}
