// Calls to mutate are emitted by mutating operator processing, for example +=.
// This is use to avoid double-evaluation of r-values.
function _mutate(obj, key, op, val) {
    return obj[key] = op(obj[key], val);
}

//////////////////////////////////////////////////////////////////////////////

function _add(a, b) {
    // Keep short to encourage inlining
    return ((typeof a === 'object') && (a !== null)) ? _objectAdd(a, b) : a + b;
}

function _addMutate(a, b) {
    return ((typeof a === 'object') && (a !== null)) ? (Object.isFrozen(a) ? _objectAdd(a, b) : _objectAddMutate(a, b)) : a += b;
}

function _objectAdd(a, b) {
    // clone, preserving prototype
    let c = a.constructor();

    // avoid hasOwnProperty for speed
    if (typeof b === 'object') for (let key in a) c[key] = a[key] + b[key];
    else                       for (let key in a) c[key] = a[key] + b;
    
    return Object.isFrozen(a) ? Object.freeze(c) : c;
}

function _objectAddMutate(a, b) {
    if (typeof b === 'object') for (let key in a) a[key] += b[key];
    else                       for (let key in a) a[key] += b;
    return a;
}

/////////////////////////////////////////////////////////////////////////////

function _neg(a) {
    return ((typeof a === 'object') && (a !== null)) ? _objectNeg(a, b) : -a;
}

function _objectNeg(a) {
    let c = a.constructor();
    for (let key in a) c[key] = -a[key];
    return Object.isFrozen(a) ? Object.freeze(c) : c;
}

/////////////////////////////////////////////////////////////////////////////

function _sub(a, b) {
    return ((typeof a === 'object') && (a !== null)) ? _objectSub(a, b) : a - b;
}

function _subMutate(a, b) {
    return ((typeof a === 'object') && (a !== null)) ? (Object.isFrozen(a) ? _objectSub(a, b) : _objectSubMutate(a, b)) : a -= b;
}

function _objectSub(a, b) {
    let c = a.constructor();

    if (typeof b === 'object') for (let key in a) c[key] = a[key] - b[key];
    else                       for (let key in a) c[key] = a[key] - b;
    
    return Object.isFrozen(a) ? Object.freeze(c) : c;
}

function _objectSubMutate(a, b) {
    if (typeof b === 'object') for (let key in a) a[key] -= b[key];
    else                       for (let key in a) a[key] -= b;
    return a;
}

/////////////////////////////////////////////////////////////////////////////

function _div(a, b) {
    return ((typeof a === 'object') && (a !== null)) ? _objectDiv(a, b) : a / b;
}

function _divMutate(a, b) {
    return ((typeof a === 'object') && (a !== null)) ? (Object.isFrozen(a) ? _objectDiv(a, b) : _objectDivMutate(a, b)) : a /= b;
}

function _objectDiv(a, b) {
    let c = a.constructor();

    if (typeof b === 'object') for (let key in a) c[key] = a[key] / b[key];
    else                       for (let key in a) c[key] = a[key] / b;
    
    return Object.isFrozen(a) ? Object.freeze(c) : c;
}

function _objectDivMutate(a, b) {
    if (typeof b === 'object') for (let key in a) a[key] /= b[key];
    else                       for (let key in a) a[key] /= b;
    return a;
}

/////////////////////////////////////////////////////////////////////////////

function _mul(a, b) {
    // Special case: allow number * object
    return ((typeof a === 'object') && (a !== null)) ?
        _objectMul(a, b) :
        ((typeof b === 'object') && (b !== null)) ?
        _objectMul(b, a) :
        a * b;
}

function _mulMutate(a, b) {
    return ((typeof a === 'object') && (a !== null)) ? (Object.isFrozen(a) ? _objectMul(a, b) : _objectMulMutate(a, b)) : a *= b;
}

function _objectMul(a, b) {
    let c = a.constructor();

    if (typeof b === 'object') for (let key in a) c[key] = a[key] * b[key];
    else                       for (let key in a) c[key] = a[key] * b;
    
    return Object.isFrozen(a) ? Object.freeze(c) : c;
}

function _objectMulMutate(a, b) {
    if (typeof b === 'object') for (let key in a) a[key] *= b[key];
    else                       for (let key in a) a[key] *= b;
    return a;
}

/////////////////////////////////////////////////////////////////////////////

// vector operators:

function abs(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.abs(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.abs(a);
    }
}

function sqrt(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.sqrt(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.sqrt(a);
    }
}

function floor(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.floor(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.floor(a);
    }
}

function ceil(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.ceil(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.ceil(a);
    }
}

function round(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.round(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.round(a);
    }
}

function trunc(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.trunc(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.trunc(a);
    }
}

function exp(a) {
    if (typeof a === 'object') {
        let c = a.constructor();
        for (let key in a) c[key] = Math.exp(a[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.exp(a);
    }
}

// Copies all fields of a into b.
// Only works on objects, not numbers
function copyVector(a, b) {
    return Object.assign(b, a);
}

function cloneVector(a) {
    if (Array.isArray(a)) {
        let c = a.slice(0);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else if (typeof a === 'object') {
        let c = Object.assign(a.constructor(), a);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return a;
    }
}

// Cross product for 3D vectors of the form [x, y, z] or {x:, y:, z:}
function cross(a, b) {
    if (Array.isArray(a)) {
        let c = a.constructor();
        c[0] = a[1] * b[2] - a[2] * b[1];
        c[1] = a[2] * b[0] - a[0] * b[2];
        c[2] = a[0] * b[1] - a[1] * b[0];
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        let c = a.constructor();
        c.x = a.y * b.z - a.z * b.y;
        c.y = a.z * b.x - a.x * b.z;
        c.z = a.x * b.y - a.y * b.x;
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    }
}

// Inner product. Always returns a Number.
function dot(a, b) {
    if (typeof a === 'number') { return a * b; }
    let s = 0;
    for (let key in a) s += a[key] * b[key];
    return s;
}

function magnitude(a) {
    return Math.sqrt(dot(a, a));
}

function direction(a) {
    return _mul(a, 1.0 / magnitude(a));
}

// Used by min and max. Assumes 'this' is bound to the corresponding Math function.
function _minOrMax(a, b) {
    const ta = typeof a, tb = typeof b;
    let allNumbers = (ta === 'number') && (tb === 'number');
    const fcn = this;

    if (allNumbers || (arguments.length > 2)) {
        // common case on only numbers
        return fcn.apply(Math, arguments);
    } else {
        if (ta === 'Number') {
            // Swap, b is the vector
            let tmp = b; b = a; a = b;
            tmp = tb; tb = ta; ta = tmp;
        }

        let c = a.constructor();
        if (tb === 'Number') for (let key in a) c[key] = fcn(a[key], b);
        else                 for (let key in a) c[key] = fcn(a[key], b[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    }
}

// Handles any number of arguments for Numbers, two
// arguments for vectors
function max(a, b) {
    return _minOrMax.apply(Math.max, arguments);
}
    
function min(a, b) {
    return _minOrMax.apply(Math.min, arguments);
}

function clamp(x, lo, hi) {
    return min(max(x, lo), hi);
}

function maxComponent(a) {
    if (typeof a === 'number') { return a; }
    let s = -Infinity;
    for (let key in a) s = Math.max(s, a[key]);
    return s;
}

function minComponent(a) {
    if (typeof a === 'number') { return a; }
    let s = Infinity;
    for (let key in a) s = Math.min(s, a[key]);
    return s;
}

function pow(a, b) {
    const ta = typeof a, tb = typeof b;
    if (ta === 'object') {
        let c = a.constructor();
        if (tb === 'number') {
            for (let key in a) c[key] = Math.pow(a[key], b);
        } else {
            for (let key in a) c[key] = Math.pow(a[key], b[key]);
        }
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else if ((ta === 'number') && (tb === 'object')) {
        let c = b.constructor();
        for (let key in b) c[key] = Math.pow(a, b[key]);
        return Object.isFrozen(a) ? Object.freeze(c) : c;
    } else {
        return Math.ceil(a, b);
    }
}

