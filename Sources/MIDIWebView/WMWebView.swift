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
        
        guard let polyfillPath = Bundle.main.path(forResource: "WebMIDIAPIPolyfill", ofType: "js") else {
            return
        }
        guard let polyfillScript = try? String(contentsOfFile: polyfillPath, encoding: .utf8) else {
            return
        }
        let script = WKUserScript(source: polyfillScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            
        // Inject Web MIDI API bridge JavaScript
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(handler, name: "onready")
        configuration.userContentController.add(handler, name: "send")
        configuration.userContentController.add(handler, name: "clear")
    }
}
