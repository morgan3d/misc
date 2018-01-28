/** Creates a w x h maze with corridors of 0 and walls of 1 expressed
    as an array of arrays using floodfill.

    If wrap is true, then the maze is on a torus. Otherwise it is on
    a rectangle.

    Imperfect is the maximum fraction of additional connections
    (creating loops). The default is zero. The maximum is 1.

    Every square is always reachable.

    Morgan McGuire
    @CasualEffects
    https://casual-effects.com

    BSD License
*/
function makeMaze(w, h, wrap, imperfect) {
    w = w || 32;
    h = h || w;
    imperfect = Math.min(1, imperfect || 0);

    if (wrap) {
        // Ensure even size
        w += w % 2; h += h % 2;
    } else {
        // Ensure odd size
        w += ~(w & 1); h += ~(h & 1);
    }

    // Allocate and initialize to solid
    let maze = new Array(w);
    for (let x = 0; x < w; ++x) {
        maze[x] = new Array(h).fill(1);
    }

    let directions = [{x:-1, y:0}, {x:1, y:0}, {x:0, y:1}, {x:0, y:-1}];
    let stack = [{x:1 + Math.floor(w / 2 - 2) * 2, y:1 + Math.floor(h / 2 - 2) * 2, step:{x:0, y:0}}];
    while (stack.length) {
        let cur = stack.pop();

        // Unvisited?
        if (maze[cur.x][cur.y]) {
            
            // Mark visited
            maze[cur.x][cur.y] = 0;

            // Carve the wall back towards the source
            maze[(cur.x - cur.step.x + w) % w][(cur.y - cur.step.y + h) % h] = 0;

            // Fisher-Yates shuffle directions
            for (let i = 3; i > 0; --i) {
                let j = Math.floor(Math.random() * (i + 1));
                [directions[i], directions[j]] = [directions[j], directions[i]];
            }
            
            // Push neighbors if not visited
            for (let i = 0; i < 4; ++i) {
                let step = directions[i];
                let x = cur.x + step.x * 2;
                let y = cur.y + step.y * 2;
                if (wrap) {
                    x = (x + w) % w;
                    y = (y + h) % h;
                }
                
                if ((x >= 0) && (y >= 0) && (x < w) && (y < h) && maze[x][y]) {
                    // In bounds and not visited
                    stack.push({x:x, y:y, step:step});
                }
            } // for each direction
        } // if unvisited
    } // while unvisited

    // Blow away some random walls, preserving the edges if not wrapping
    var bdry = wrap ? 0 : 1;
    for (let i = Math.ceil(imperfect * w * h / 4); i > 0; --i) {
        maze[Math.floor(Math.random() * (w * 0.5 - bdry * 2)) * 2 + 1][Math.floor(Math.random() * (h * 0.5 - bdry * 2)) * 2 + bdry * 2] = 0;
        maze[Math.floor(Math.random() * (w * 0.5 - bdry * 2)) * 2 + bdry * 2][Math.floor(Math.random() * (h * 0.5 - bdry * 2)) * 2 + 1] = 0;
    }
    
    return maze;
}


function mazeToString(maze) {
    let width = maze.length;
    let height = maze[0].length;

    let s = '';
    for (let y = 0; y < height; ++y) {
        for (let x = 0; x < width; ++x) {
            s += (maze[x][y] === 0) ? ' ' : '&#x2588;';
        }
        s += '\n';
    }
    
    return s;
}
