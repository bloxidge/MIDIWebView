import MIDIAccess from "./src/MIDIAccess"

function _requestMIDIAccess(options) {
    const access = new MIDIAccess(options);
    return access._promise;
}

if (!window.navigator.requestMIDIAccess) {
    window.navigator.requestMIDIAccess = _requestMIDIAccess;
}
