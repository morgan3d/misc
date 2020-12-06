function test(src, desired, options) {
    let actual = eval(vectorify(src, options));
    console.assert(actual === desired, '"' + src + '" produced ' + actual + ', should have been ' + desired);
    console.log('test:  (' + src + ') === ' + desired);
}

let src = `
let c = 1 * 2;
c = 1 * 2 * 3;
let d = - 1;
let x = 0, a = [{v:0}], y = {b:1}, z=1;
for (let i = 0; i < 100; ++i) {

  // Hello!
  x = z + i; a[0].v += 1;
  y.b += 1;
  x = -x;
  x += y.b;
}

let a = 1;
x = ++a;


let a = 1, b = 2, c = 3; 
let r = MAD(a, b, c);

// Tests for new features:
//const x = a ?? 1;
//{...{a:1}}
`;

let dst = vectorify(src, {assignmentReturnsUndefined:true, scalarEscapes:true});

console.log('SOURCE:');
console.log(src);
console.log('--------------------------------------------------------');
console.log('RESULT:');
console.log(dst);

// Test the nullish rewriter to ensure it isn't injecting newlines
console.log(vectorify('undefined == 3 + 1', {equalsCallback: vectorify.nullishRewriter}));

test(`dot({x:1,y:2}, {x:4,y:3})`, 10);
test(`({x:1,y:5} + {x:4,y:3}).y`, 8);
test(`({x:1,y:2} + {x:4,y:3}).y`, 5);
test(`([1,2] + [4,3])[0]`, 5);
test(`([3] * [6])[0]`, 18);
test(`(function() { let v = [1, 2]; let b = v; v += [4,2]; return b[0]; }())`, 5);
test(`(function() { let v = Object.freeze([1, 2]); let b = v; v += [4,2]; return b[0]; }())`, 1);
test(`(function () {let a = 1; return ++a; })()`, undefined, {assignmentReturnsUndefined:true});
test(`(function () {let a = 1; return ++a; })()`, 2);
test(`(function () {let a = 1; return a += 1; })()`, 2);
test(`(function () {let a = 1; return a += 1; })()`, undefined, {assignmentReturnsUndefined:true});
test(`(function () {let a = 2, b = 3; return MUL(a, b); })()`, 6, {assignmentReturnsUndefined:true, scalarEscapes:true});
test(`(function () {let a = 1, b = 2, c = a + b; return MAD(a, b, c); })()`, 5, {assignmentReturnsUndefined:true, scalarEscapes:true});
test('undefined == 3 + 1', 4, {equalsCallback: vectorify.nullishRewriter});

console.log('Done with tests');

