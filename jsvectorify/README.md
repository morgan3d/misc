The `vectorify.js` library provides vector math support to JavaScript, so that you can write
expressions such as:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ JavaScript
let c = {r: 0, g: 0.5, b: 1};
let d = {x: 3, y:2};
let p = [1, 2, -1];
let v = [0, 0, 1];
let dt = 0.1; 
p += v * dt;

if (dot(direction(v), [cos(a), sin(a) * sin(b), sin(a) * cos(b)]) > 0.5) {
  v *= 0.5;
}

d = 2 * d / {x:1, y:2};

console.log(maxComponent(p));

c = max(c, 1);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



Usage
==========================================

In your HTML file:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ HTML
<script src="https://morgan3d.github.io/misc/jsvectorify/lib/vectorify.js"></script>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


In your JavaScript file:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ JavaScript

// Vectorify an entire program:
(new Function(vectorify(function() {
   ... your code here ...
   let a = {x: 1, y:2};
   ...
}))();


// or


// Leave you program unmodified, but create a single vectorified function.
// This preserves peak performance for scalar operations outside of this function.
// The function can be used by regular code.
let f = new Function(vectorify(function() {
   ... your code here ...
   let a = {x: 1, y:2};
   ...
}));


// or


// Returns a string of the processed code. You can eval() or construct a function from it, or run the result in 
// in an environment where the vector.js routines are defined.
let s = vectorify(`
   ... your code here ...
  let a = {x:1, y:2};
  ...
`);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`vectorify` does not `eval` the source itself because if it did so, the wrong scope would be
used for evaluating free variables.

You can probably use the library directly from Node.js and other non-browser contexts; it may
require some library/module wrapping. If you're curious about that, then you already know more
than I do, so I can't help you.


Features
==========================================

The library provides pointwise vector operations (a.k.a. Hadamard or array) operations for
arithmetic and common math routines, as well as appropriate definitions for vector functions
such as min, minComponent, copy, and dot product.

`vectorify.js` does not introduce a special vector class. It works with whatever Object or
Array arguments are provided, and seamlessly operates on Numbers mixed with them. So, your
vectors can look like `{x:1, y:2}`, `{r:0, g:1, b:1, a:0.5}`, `[7, 4, 1]`, or another other
structure. If they have a specific prototype such as the Box2D vector class, then that will be
preserved by the operations. Methods are not added to the `Math` object so that you have direct
access to the original routines when operating on scalars for efficiency.

Operator overloading works for Arrays of the same length, Objects with the same keys, and an
Array or Object and a scalar right value. It assumes that the values in the Array or Object are
all Numbers (or Strings, for `+` and `+=`). That is, there is no recursive application of
overloading. If the Object has a prototype, then it is used to construct the result Object.

The left value of a binary operator determines the type of the operation, so if the right value
is a Number or String, then the left must be a Number, Object, or Array except that "Number *
Object" is rewritten as "Object * Number" and accepted. This rewriting does not permit the mutating
"Number *= Object", however.

The following binary operators are supported:

   `+` `-` `*` `/` `+=` `-=` `*=` `/=` 
 
as well as unary `-` and `+`. The library also defines overloaded vectorized functions for
Arrays, Objects, and Numbers:

   `dot` `ceil` `floor` `round` `pow` `abs` `sqrt` `trunc` `min` `max` `clamp` `exp`
   `maxComponent` `minComponent` `magnitude` `direction` `cross` `cloneVector` `copyVector`

`pow` accepts a Number for either argument, as do `min` and `max`. `min` and `max` only accept
two arguments when operating on vectors. For scalars, they are the same as `Math.min` and
`Math.max`. Operators with boolean arguments or results are not supported to minimize
complexity.

The `cross` function assumes the vector is of the form `[x, y, z]` or `{x:, y:, z:}`. Other
routines make no assumptions about length or structure of vectors.


Immutable Vectors
==========================================

The vector operators follow normal Object variable rules for aliasing and assignment, by
default. For example:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ JavaScript
function vec3(x, y, z) { return {x:x, y:y, z:z}; }

let v = vec3(1,2,3);
let b = v;

v += 4;

// note that b === v

console.log(b.x); // prints 5
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

However, if the first input argument to an operator or function is frozen, then the output will
be frozen as well. 

In this case, rather than the mutating operators giving an error, they construct new output
arguments.  This means that if you use `Object.freeze` when you create your original vectors,
then they will have semantics similar to JavaScript Strings or Numbers. For example:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ JavaScript
function vec3(x, y, z) { return Object.freeze({x:x, y:y, z:z}); }

let v = vec3(1,2,3);
let b = v;
v += 4; // same as v = v + 4 since v is immutable

// here, b !== v

console.log(b.x); // prints 1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note that the semantics will _not_ be the same as GLSL vectors or C++ structs because
individual elements will also be immutable if the entire object is frozen.

Design
==========================================

The goal of this operator overloading technique primarily to provide convenience and clean
syntax. It strives to give good performance while retaining near-native performance for scalar
operations with the best JavaScript implementations and preserving line numbers for error
messages and debugging. Performance on vector operations is necessarily lower than could be
achieved by changing the language semantics, which is the cost of the relatively seamless
integration.

I developed this for working with JavaScript as a high-level scripting engine for games in
WebGL or embedded in a binary engine, where low-level, numerically-intense operations are
performed in hand-written JavaScript or C++ that avoids allocation and these abstractions.
That is, you probably shouldn't write your particle system integrator using this library, but
you should write the high-level scene graph logic with it.

This library doesn't support matrix-vector product because there are many different ways to
represent matrices and some domain knowledge is needed to handle something like "matrix * rgb"
as intended. 

Matrices themselves are not supported for the pointwise operators because doing so via
recursive processing of arrays-of-arrays or similar would slow down the more critical vector
case.


Performance
==========================================

As of Nov 2018, Firefox executes the generated code nearly as fast as hand-written code
special-cased with static knowledge of the types involved. Chrome is fast for vectors but about
8x slower than hand-written for operations involving only Numbers. Edge and Safari and about as fast as
Firefox, except for cases where the right-hand side of a mutating operator is computed (e.g.,
`a[x+1] += b`), which slows them down about 4x compared to hand-written code. In the worst case,
all browsers can run certain arithmetic operations about 60x slower for the mutating operator case.
This is still quite fast and hasn't impacted net application performance for the cases where I've used
it, but is a really shocking slowdown given that inlining should allow the browser to optimize this
case well. This worst case seems to affect Firefox significantly less than the others.




Debugging
==========================================

Code that has been vectorified can interact with non-vectorified code without a problem and run
in debuggers, throw exceptions, etc. `vectorify` also does not modify your variable names, so
you can interact with them in a console or debugger as usual.

The vectorified code will likely give incorrect line numbers and not appear in a debugger if
you use it exactly as shown in the simple examples above. For more complicated programs, there
is a workaround for this.

Because `vectorify` preserves line numbers, comments, and even whitespace in its rewriting,
if you process code and then inject it back into your program as code instead of running
`eval`, a debugger will be able to handle it correctly and show you the original source line for 
the problem (and even expose the same variable names). There are a few ways to do this.
The three easiest are:

1. Read the source from a `<script type='vectorify'>` tag, and then replace that
   tag with the vectorified code at runtime (`document.getElementsByTagName`...`node.parentNode.replaceChild(document.createElement('script')...`).
   
2. Read the source and then inject the output into an `iframe`.

3. Process the code offline. The output of `vectorify` is not as pretty as infix math (that's
   kind of the point of using it), but it is still extremely readable.

I suspect that it is also possible to use a "source map" for this, but the source map produced
by `vectorify` internally is relative to the input string, not the place in your program where
it was introduced. So, I haven't exposed that yet. The most likely solution here is to use the
form that grabs source from a function and somehow extract the relative location of that
function in the original source file.


Credits and License
===========================================

`vectorify.js` is by Morgan McGuire and available under the MIT License (see
[`LICENSE`](LICENSE)).  It uses the MIT License [`recast`](https://github.com/benjamn/recast)
library by Ben Newman and the BSD-2-Clause
[`estraverse`](https://github.com/estools/estraverse) library from ECMAScript Tooling.

The name "vectorify" is a ridiculous one chosen with inspiration from "browserify". I
intentionally avoided the name "vectorize", which generally means collecting parallel scalar
code and turning it into vector operations; this library enables vectors but doesn't
"vectorize" scalar code for you.
