/** Creates a w x h maze with corridors of 0 and walls of 255 expressed
    as an array of arrays using flood filling (breadth first search).

    If wrap is true, then the maze is on a torus. Otherwise it is on a rectangle.

    Imperfect is the maximum fraction of additional connections (creating loops). The default
    is zero. The maximum is 1.

    Fill is how much of the space (very roughly) the maze should fill. 1.0 fills the entire
    space. 0.0 gives a very thin and stringy result. 
    Straightness is a measure of how much to favor straight corridors from 0.0 to 1.0.

    The deadEndArray will have the coordinates of all dead ends appended. These are good
    locations to generate rooms when fill is very low. If imperfect > 0 then there is a small
    chance that some of these will not actually be dead ends.

    Morgan McGuire
    @CasualEffects
    https://casual-effects.com

    BSD License
*/
function makeMaze(w, h, straightness, wrap, imperfect, fill, deadEndArray) {
    const SOLID = 255, RESERVED = 127, EMPTY = 0;
    let random = Math.random, floor = Math.floor;

    function randomInt(x) { return floor(random() * x); }

    // Knuth-Fisher-Yates shuffle of an Array
    function shuffle(a) { for (let i = a.length - 1; i > 0; --i) { let j = randomInt(i + 1); [a[i], a[j]] = [a[j], a[i]]; } }

    // Argument cleanup
    if (deadEndArray === undefined) { deadEndArray = []; }
    w = floor(w || 32);
    h = floor(h || w);
    imperfect = Math.min(1, Math.max(0, imperfect || 0));
    if (fill === undefined) { fill = 1; }
    let reserveProb = (1 - Math.min(Math.max(0, fill * 0.9 + 0.1), 1))**1.6;

    if (wrap) {
        // Ensure even size
        w += w & 1; h += h & 1;
    } else {
        // Ensure odd size
        w += ~(w & 1); h += ~(h & 1);
    }

    // Allocate and initialize to solid
    let maze = new Array(w);
    for (let x = 0; x < w; ++x) {
        maze[x] = new Array(h).fill(SOLID);
    }

    // Reserve some regions
    if (reserveProb > 0) {
        for (let x = 1; x < w; x += 2) {
            for (let y = 1, m = maze[x]; y < h; y += 2) {
                if (random() < reserveProb) { m[y] = RESERVED; }
            } // y
        } // x
    }

    // Carve hallways recursively
    let stack = [{x:floor(w / 4) * 2 - 3, y:floor(h / 4) * 2 - 3, step:{x:0, y:0}}];
    deadEndArray.push(stack[0]);
    let directions = [{x:-1, y:0}, {x:1, y:0}, {x:0, y:1}, {x:0, y:-1}];

    // Don't start reserving until a path of at least this length has been carved
    let ignoreReserved = Math.max(w, h);

    function unexplored(x, y) {
        let c = maze[x][y];
        return (c === SOLID) || ((c === RESERVED) && (ignoreReserved > 0));
    }

    while (stack.length) {
        let cur = stack.pop();

        // Unvisited?
        if (unexplored(cur.x, cur.y)) {

            // Mark visited
            maze[cur.x][cur.y] = EMPTY;
            
            // Carve the wall back towards the source
            maze[(cur.x - cur.step.x + w) % w][(cur.y - cur.step.y + h) % h] = EMPTY;
            --ignoreReserved;

            // Fisher-Yates shuffle directions
            shuffle(directions);

            // Prioritize a straight line. Note that cur.step is a
            // pointer to one of the directions, so we can use pointer
            // equality to find it.
            if (random() < straightness) {
                for (let i = 0; i < 4; ++i) {
                    if (directions[i] === cur.step) {
                        // Swap with the last
                        directions[i] = directions[3];
                        directions[3] = cur.step;
                        break;
                    }
                }
            }
            
            // Push neighbors if not visited
            let deadEnd = true;
            for (let i = 0; i < 4; ++i) {
                let step = directions[i];
                let x = cur.x + step.x * 2;
                let y = cur.y + step.y * 2;
                
                if (wrap) {
                    x = (x + w) % w;
                    y = (y + h) % h;
                }
                
                if ((x >= 0) && (y >= 0) && (x < w) && (y < h) && unexplored(x, y)) {
                    // In bounds and not visited
                    stack.push({x:x, y:y, step:step});
                    deadEnd = false;
                }
            } // for each direction
            
            if (deadEnd) { deadEndArray.push(cur); }
        } // if unvisited
    } // while unvisited

    
    if (imperfect > 0) {
        // Boundary
        const bdry = wrap ? 0 : 1;

        // Removes if not  attached to some passage
        function remove(x, y) {
            let a = maze[x][(y + 1) % h], b = maze[x][(y - 1 + h) % h],
                c = maze[(x + 1) % w][y], d = maze[(x - 1 + w) % w][y];
            if (Math.min(a, b, c, d) === EMPTY) {
                maze[x][y] = EMPTY;
            }
        }
        
        // Remove some random walls, preserving the edges if not wrapping.
        for (let i = Math.ceil(imperfect * w * h / 3); i > 0; --i) {
            remove(randomInt(w * 0.5 - bdry * 2) * 2 + 1, randomInt(h * 0.5 - bdry * 2) * 2 + bdry * 2);
            remove(randomInt(w * 0.5 - bdry * 2) * 2 + bdry * 2, randomInt(h * 0.5 - bdry * 2) * 2 + 1);
        }
        
        // Reconnect single-wall islands
        for (let y = 0; y < h; y += 2) {
            for (let x = 0; x < w; x += 2) {
                let a = maze[x][(y + 1) % h], b = maze[x][(y - 1 + h) % h],
                    c = maze[(x + 1) % w][y], d = maze[(x - 1 + w) % w][y];
                
                if (a === EMPTY && b === EMPTY && c === EMPTY && d === EMPTY) {
                    // This is an island. Restore one adjacent wall at random
                    let dir = directions[randomInt(4)];
                    maze[(x + w + dir.x) % w][(y + h + dir.y) % h] = SOLID;
                }
            } // x
        } // y
    }

    // Unreserve everything
    if (reserveProb > 0) {
        for (let x = 1; x < w; x += 2) {
            for (let y = 1, m = maze[x]; y < h; y += 2) {
                if (m[y] === RESERVED) { m[y] = SOLID; }
            } // y
        } // x
    } // reserveProb

    return maze;
}


/** 
    Thickens a 2D array maze for variable width halls and walls.
    Assumes a maze generated by makeMaze in which the walls are always
    on even rows and columns. The output is no longer of that form.
*/
function mazeToMap(maze, hallWidth, wallWidth) {
    hallWidth = Math.max(1, hallWidth || 1);
    wallWidth = Math.max(1, wallWidth || 1);
    
    let width = maze.length, height = maze[0].length;
    let map = [];
    
    for (let x = 0; x < width; ++x) {
        for (let src = maze[x], i = ((x & 1) ? hallWidth : wallWidth); i > 0; --i) {
            let dst = [];
            for (let y = 0; y < height; ++y) {
                for (let c = src[y], j = ((y & 1) ? hallWidth : wallWidth); j > 0; --j) {
                    dst.push(c);
                } // j
            } // y
            map.push(dst);
        } // i
    } // x

    return map;
}


/** 
    Carve empty rooms into map, which was expanded using parameters hallWidth, wallWidth from a
    maze that had the mazeDeadEndArray dead ends.
 */
function addMapRooms(map, mazeDeadEndArray, roomsFraction, hallWidth, wallWidth) {
    const EMPTY = 0;
    const w = map.length, h = map[0].length, floor = Math.floor, min = Math.min, max = Math.max, ceil = Math.ceil;

    roomsFraction = max(0, min(1, roomsFraction));
    // Scale maze coordinates by this value
    const s = (hallWidth + wallWidth) / 2;
    
    // Dimensions of the room
    let a = ceil(1.2 * s / max(roomsFraction, 0.4));
    let b = a;
    
    // Outermost rooms are usually at the end of the array
    const last = floor((mazeDeadEndArray.length - 1) * roomsFraction);
    for (let i = last; i >= 0; --i) {
        let c = mazeDeadEndArray[i];

        // Upper-left corner of the hallway
        let u = floor((c.x - 0.5) * s + wallWidth - a / 2);
        let v = floor((c.y - 0.5) * s + wallWidth - b / 2);

        for (let x = max(wallWidth, u - a); x <= min(w - wallWidth - 1, u + a); ++x) {
            map[x].fill(EMPTY, max(wallWidth, v - b), min(h - wallWidth, v + b + 1));
        } // x
    } // i
}


/** Draws 0 as empty, 255 as solid, strings as their first character, 
    and everything else as half-solid. */
function mapToString(map) {
    let width = map.length, height = map[0].length;

    let s = '';
    for (let y = 0; y < height; ++y) {
        for (let x = 0; x < width; ++x) {
            let c = map[x][y];
            s += (c === 255) ? '&#x2588;' : (c === 0) ? ' ' : (c && c.codePointAt) ? c[0] : '&#x2591;';
        }
        s += '\n';
    }
    
    return s;
}
