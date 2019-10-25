# MIDIWebView

#### Problem:
WebMIDI API is not natively included for WKWebView in iOS.

#### Solution:
_WMWebView_
A subclass of Apple's WKWebView which executes a Javascript polyfill for the WebMIDI API spec.

### Usage

```swift
import MIDIWebView

class MyViewController: ViewController {
    
    @IBOutlet var myWebView: WMWebView!
    
    ...
}
```
