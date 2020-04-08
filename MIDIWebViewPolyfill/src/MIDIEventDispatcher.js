class MIDIEventDispatcher {
    constructor() {
        this._listeners = {};
    }

    addEventListener(type, callback) {
        const listeners = this._listeners[type];
        if (listeners) {
            for (let i = 0; i < listeners.length; i++) {
                if (listeners[i] === callback) {
                    return;
                }
            }
        } else {
            this._listeners[type] = [];
        }

        this._listeners[type].push(callback);
    };

    removeEventListener(type, callback) {
        const listeners = this._listeners[type];
        if (listeners) {
            for (let i = 0; i < listeners.length; i++) {
                if (listeners[i] === callback) {
                    this._listeners[type].splice( i, 1 );  //remove it
                    return;
                }
            }
        }
    };

    preventDefault() {
        this._pvtDef = true;
    }

    dispatchEvent(event) {
        this._pvtDef = false;

        const rawEvent = Object.assign({}, event, { target: this, currentTarget: this });

        const listeners = this._listeners[event.type];
        if (listeners) {
            // dispatch to listeners
            for (let i = 0; i < listeners.length; i++) {
                if (listeners[i].handleEvent) {
                    listeners[i].handleEvent.bind(this)(rawEvent);
                } else {
                    listeners[i].bind(this)(rawEvent);
                }
            }
        }

        console.warn("Ready to dispatch event:");
        console.warn(event);

        switch (event.type) {
        case "midimessage":
            if (this.onmidimessage) {
                this.onmidimessage(rawEvent);
            }
            break;
        case "statechange":
            console.warn("It's an statechange event!");
            if (this.onstatechange) {
                console.warn("and it exists!");
                this.onstatechange(rawEvent);
            } else {
                console.warn("but it doesn't exist!");
            }
            break;
        }

        return this._pvtDef;
    };
}

export default MIDIEventDispatcher
