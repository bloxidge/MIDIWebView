import MIDIPort from "./MIDIPort"
import { MIDIPortConnectionState, MIDIPortDeviceState } from "./util/Enums"

class MIDIOutput extends MIDIPort {
    constructor(id, name, manufacturer, index, midiaccess) {
        super(id, name, manufacturer, index, midiaccess);

        this.type = "output";
    }

    send(data, timestamp) {
        let delayBeforeSend = 0;
        if (data.length === 0) {
            throw new TypeError();
        }

        if (!this._midiaccess.sysexEnabled) {
            let i = data.length;
            do {
                if (data[i] == 0xf0) {
                    throw new DOMException("SysEx messages are disabled.", "InvalidAccessError");
                }
            } while (i--);
        }

        if (this.state === MIDIPortDeviceState.disconnected) {
            throw new DOMException("Output device is disconnected", "InvalidStateError");
        }

        if (this.connection === MIDIPortConnectionState.closed) {
            this._setConnection(MIDIPortConnectionState.open);
        }

        if (timestamp) {
            delayBeforeSend = timestamp - performance.now();
        }

        const outputData = new MIDIOutputData(this._index, data, delayBeforeSend);

        if (window.webkit) {
            window.webkit.messageHandlers.send.postMessage(outputData);
        }
    };
}

class MIDIOutputData {
    constructor(outputPortIndex, data, deltaTime) {
        this.outputPortIndex = outputPortIndex;
        this.data = data.map(i => Number(i)); // convert "data" to an array of Number
        this.deltaTime = deltaTime;
    };
}

export default MIDIOutput
