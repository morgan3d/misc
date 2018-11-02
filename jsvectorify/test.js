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

