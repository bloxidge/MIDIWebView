import MIDIPort from "./MIDIPort"
import { MIDIPortConnectionState } from "./util/Enums"

class MIDIInput extends MIDIPort {
    constructor(id, name, manufacturer, index, midiaccess) {
        super(id, name, manufacturer, index, midiaccess);

        this.type = "input";

        this._onmidimessage = null;
    }

    set onmidimessage(f) {
        this._onmidimessage = f;
        if (this.connection === MIDIPortConnectionState.closed) {
            this._setConnection(MIDIPortConnectionState.open);
        }
    }
    get onmidimessage() {
        return this._onmidimessage
    }
}

export default MIDIInput
