let src = `
let x = 0, a = [{v:0}], y = {b:1}, z=1;
for (let i = 0; i < 100; ++i) {

  // Hello!
  x = z + i; a[0].v += 1;
  y.b += 1;
  x = -x;
  x += y.b;
}
`;

let dst = vectorify(src);

console.log(src);
console.log('------------------------------------------------------');
console.log(dst);

function test(src, desired) {
    let actual = eval(vectorify(src));
    console.assert(actual === desired, '"' + src + '" produced ' + actual + ', should have been ' + desired);
    console.log('test:  (' + src + ') === ' + desired);
}

test(`dot({x:1,y:2}, {x:4,y:3})`, 10);
test(`({x:1,y:5} + {x:4,y:3}).y`, 8);
test(`({x:1,y:2} + {x:4,y:3}).y`, 5);
test(`([1,2] + [4,3])[0]`, 5);
test(`([3] * [6])[0]`, 18);
console.log('Done with tests');
