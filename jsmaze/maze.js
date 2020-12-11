/** Creates a w x h maze with corridors of value 0 and walls of 255,
    expressed as an array of arrays. The primary underlying algorithm
    is flood filling (breadth first search).

    If wrap is true, then the maze is on a torus. Otherwise it is on a
    rectangle.

    Imperfect is the maximum fraction of additional connections
    (creating loops). The default is zero. The maximum is 1.

    Fill is how much of the space (very roughly) the maze should
    fill. 1.0 fills the entire space. 0.0 gives a very thin and
    stringy result.  Straightness is a measure of how much to favor
    straight corridors from 0.0 to 1.0.

    The horizontal and vertical objects have symmetry:bool,
    border:int, and loop:bool properties.

    The deadEndArray will have the coordinates of all dead ends
    appended. These are good locations to generate rooms when fill is
    very low. If imperfect > 0 then some
    of these will not actually be dead ends.
    The dead ends are not correctly represented in maps with mirroring.

    Morgan McGuire
    @CasualEffects
    https://casual-effects.com

    BSD License
*/
function makeMaze(w, h, horizontal, vertical, straightness, imperfect, fill, deadEndArray, hallWidth, wallWidth, random) {
    const hSymmetry = horizontal.symmetry;
    const hBorder   = horizontal.border;
    // Ignore wrapping unless the border and symmetry are also set; in
    // that case, generate without wrapping and poke holes in the
    // border
    const hWrap     = horizontal.loop && !(hSymmetry && hBorder);
    
    const vSymmetry = vertical.symmetry;
    const vBorder   = vertical.border;
    const vWrap     = vertical.loop && !(vSymmetry && vBorder);
    
    const SOLID = 255, RESERVED = 127, EMPTY = 0;
    random = random || Math.random;
    const floor = Math.floor;
          
    function randomInt(x) { return floor(random() * x); }

    // Knuth-Fisher-Yates shuffle of an Array
    function shuffle(a) { for (let i = a.length - 1; i > 0; --i) { let j = randomInt(i + 1); [a[i], a[j]] = [a[j], a[i]]; } }

    // Argument cleanup
    if (deadEndArray === undefined) { deadEndArray = []; }
    w = floor(w || 32);
    h = floor(h || w);

    // Account for edges that will later be stripped
    if (! hBorder) {
        ++w;
        if (! hWrap) { ++w; }
    }
    
    if (! vBorder) {
        ++h;
        if (! vWrap) { ++h; }
    }
    
    imperfect = Math.min(1, Math.max(0, imperfect || 0));
    if (fill === undefined) { fill = 1; }
    let reserveProb = (1 - Math.min(Math.max(0, fill * 0.9 + 0.1), 1))**1.6;

    if (hWrap) {
        if (hSymmetry) {
            // Must be a multiple of 4 offset by 2
            // for mirror symmetry
            w = Math.round((w - 2) / 4) * 4 + 2;
        } else {
            // Ensure even size
            w += w & 1; 
        }
    } else {
        // Ensure odd size
        w += ~(w & 1);
    }

    if (vWrap) {
        if (vSymmetry) {
            h = Math.round((h - 2) / 4) * 4 + 2;
        } else {
            h += h & 1;
        }

    } else {
        h += ~(h & 1);
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

    // Carve hallways recursively, starting at the center
    let stack = [{x: floor(w / 4) * 2 - 1, y: floor(h / 4) * 2 - 1, step: {x: 0, y: 0}}];
    deadEndArray.push(stack[0]);
    let directions = [{x:-1, y:0}, {x:1, y:0}, {x:0, y:1}, {x:0, y:-1}];

    // Don't start reserving until a path of at least this length has been carved
    let ignoreReserved = Math.max(w, h);

    function unexplored(x, y) {
        let c = maze[x][y];
        return (c === SOLID) || ((c === RESERVED) && (ignoreReserved > 0));
    }

    const hBorderOffset = hWrap ? 0 : 1;
    const vBorderOffset = vWrap ? 0 : 1;

    function set(x, y, value) {
        x = (x + w) % w;
        y = (y + h) % h;

        maze[x][y] = value;
        
        const u = w - x - hBorderOffset;
        const v = h - y - vBorderOffset
        if (hSymmetry) {
            if (u < w) {
                maze[u][y] = value;
                if (vSymmetry) {
                    maze[u][v] = value;
                }
            }
        }
        
        if (vSymmetry && v < h) {
            maze[x][v] = value;
        }                
    }
    
    while (stack.length) {
        const cur = stack.pop();

        // Unvisited?
        if (unexplored(cur.x, cur.y)) {

            // Mark visited
            set(cur.x, cur.y, EMPTY);

            // Carve the wall back towards the source
            set(cur.x - cur.step.x, cur.y - cur.step.y, EMPTY);
            
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
                const step = directions[i];
                let x = cur.x + step.x * 2;
                let y = cur.y + step.y * 2;
                
                if (hWrap) { x = (x + w) % w; }
                if (vWrap) { y = (y + h) % h; }
                
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
        const hBdry = hWrap ? 0 : 1;
        const vBdry = vWrap ? 0 : 1;

        // Removes the wall at (x, y) if at least one neighbor is also
        // empty
        function remove(x, y) {
            let a = maze[x][(y + 1) % h], b = maze[x][(y - 1 + h) % h],
                c = maze[(x + 1) % w][y], d = maze[(x - 1 + w) % w][y];
            if (Math.min(a, b, c, d) === EMPTY) {
                set(x, y, EMPTY);
            }
        }
        
        // Remove some random walls, preserving the edges if not wrapping.
        for (let i = Math.ceil(imperfect * w * h / 3); i > 0; --i) {
            remove(randomInt(w * 0.5 - hBdry * 2) * 2 + 1,         randomInt(h * 0.5 - vBdry * 2) * 2 + vBdry * 2);
            remove(randomInt(w * 0.5 - hBdry * 2) * 2 + hBdry * 2, randomInt(h * 0.5 - vBdry * 2) * 2 + 1);
        }
        
        // Reconnect single-wall islands
        for (let y = 0; y < h; y += 2) {
            for (let x = 0; x < w; x += 2) {
                let a = maze[x][(y + 1) % h], b = maze[x][(y - 1 + h) % h],
                    c = maze[(x + 1) % w][y], d = maze[(x - 1 + w) % w][y];
                
                if (a === EMPTY && b === EMPTY && c === EMPTY && d === EMPTY) {
                    // This is an island. Restore one adjacent wall at random
                    let dir = directions[randomInt(4)];
                    set(x + dir.x, y + dir.y, SOLID);
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

    if (horizontal.loop && horizontal.border && horizontal.symmetry) {
        // Poke some holes in the border. The regular generator
        // doesn't handle this case elegantly
        // Decrease probability with straightness, increase with
        // imperfection
        const prob = 0.025 + 0.25 * (1 - straightness**2 * (1 - imperfect)) + 0.5 * imperfect;
        for (let y = 1; y < maze[0].length; y += 2) {

            // Do not create a passage into a wall or immediately below another
            if ((maze[1][y] === EMPTY) &&
                (maze[0][y - 2] !== EMPTY) && 
                (random() < prob)) {
                maze[0][y] = EMPTY;
                maze[maze.length - 1][y] = EMPTY;
            }
        }
    }

    if (vertical.loop && vertical.border && vertical.symmetry) {
        const prob = 0.05 + 0.15 * (1 - straightness * (1 - imperfect)) + 0.5 * imperfect;
        for (let x = 1; x < maze.length; x += 2) {

            // Do not create a passage into a wall or immediately beside another
            if ((maze[x][1] === EMPTY) &&
                (x < 2 || maze[x - 2][0] !== EMPTY) && 
                (random() < prob)) {
                maze[x][0] = EMPTY;
                maze[x][maze[0].length - 1] = EMPTY;
            }
        }
    }
    
    // Horizontal borders
    if (! hWrap && ! hBorder) {
        // Remove border
        maze.shift();
        maze.pop();
        
        // Correct the dead ends for the new coordinates
        for (let i = 0; i < deadEndArray.length; ++i) {
            --deadEndArray[i].x;
        }
    } else if (hBorder && hWrap && ! hSymmetry) {
        // Duplicate the left edge on the right
        maze.push([...maze[0]]);

        // Duplicate dead ends
        for (let i = 0; i < deadEndArray.length; ++i) {
            if (deadEndArray[i].x === 0) {
                deadEndArray.push({x: maze.length - 1, y: deadEndArray[i].y})
            }
        }
    } else if (hSymmetry && hWrap) {
        // Remove the left wall and hall columns; the wall will
        // be a solid edge and the hall is the same as
        // the rightmost one
        maze.shift();
        maze.shift();

        // Correct the dead ends for the new coordinates
        for (let i = 0; i < deadEndArray.length; ++i) {
            deadEndArray[i].x -= 2;
        }
    }


    // Vertical borders
    if (vBorder && vWrap && ! vSymmetry) {
        // Duplicate the top edge on the bottom
        for (let x = 0; x < maze.length; ++x) {
            maze[x].push(maze[x][0]);
        }
        
        //  Duplicate dead ends
        for (let i = 0; i < deadEndArray.length; ++i) {
            if (deadEndArray[i].y === 0) {
                deadEndArray.push({x: deadEndArray[i].x, y: maze[0].length - 1})
            }
        }
    } else if (! vWrap && ! vBorder) {
        // Remove border
        for (let x = 0; x < maze.length; ++x) {
            maze[x].shift();
            maze[x].pop();
        }
        
        // Correct the dead ends for the new coordinates
        for (let i = 0; i < deadEndArray.length; ++i) {
            --deadEndArray[i].y;
        }
    } else if (vSymmetry && vWrap) {
        // Remove the top wall and top columns; the wall will
        // be a solid edge and the hall is the same as
        // the bottom one
        for (let x = 0; x < maze.length; ++x) {
            maze[x].shift();
            maze[x].shift();
        }

        // Correct the dead ends for the new coordinates
        for (let i = 0; i < deadEndArray.length; ++i) {
            deadEndArray[i].y -= 2;
        }
    }

    // Remove out of bounds dead ends after the border has been adjusted
    for (let i = 0; i < deadEndArray.length; ++i) {
        if (deadEndArray[i].x < 0 || deadEndArray[i].y < 0) {
            deadEndArray[i] = deadEndArray[deadEndArray.length - 1];
            deadEndArray.pop();
            --i;
        }
    }

    // Expand hall and wall width
    if ((hallWidth > 1) || (wallWidth > 1)) {
        const width = maze.length, height = maze[0].length;
        const old = maze;
        maze = [];
        
        // Stripping the border alters the phase of the edges
        const xPhase = ! hBorder && ! hWrap ? 1 : 0;
        const yPhase = ! vBorder && ! vWrap ? 1 : 0;
    
        for (let x = 0; x < width; ++x) {
            for (let src = old[x], i = (((x + xPhase) & 1) ? hallWidth : wallWidth); i > 0; --i) {
                let dst = [];
                for (let y = 0; y < height; ++y) {
                    for (let c = src[y], j = (((y + yPhase) & 1) ? hallWidth : wallWidth); j > 0; --j) {
                        dst.push(c);
                    } // j
                } // y
                maze.push(dst);
            } // i
        } // x
        
        // Adjust deadEndArray
        for (let i = 0; i < deadEndArray.length; ++i) {
            const c = deadEndArray[i];
            c.x = (c.x >> 1) * (wallWidth + hallWidth) + (1 - xPhase) * wallWidth + hallWidth / 2;
            c.y = (c.y >> 1) * (wallWidth + hallWidth) + (1 - yPhase) * wallWidth + hallWidth / 2;
        }
    }

    if (horizontal.border > 1) {
        // Increase the border thickness by duplication
        for (let i = 0; i < horizontal.border - 1; ++i) {
            maze.unshift([...maze[0]]);
            maze.push([...maze[maze.length - 1]]);
        }
        
        // Adjust deadEndArray
        for (let i = 0; i < deadEndArray.length; ++i) {
            deadEndArray[i].x += (horizontal.border - 1) * wallWidth;
        }
    }

    if (vertical.border > 1) {
        for (let i = 0; i < vertical.border - 1; ++i) {
            for (let x = 0; x < maze.length; ++x) {
                maze[x].unshift(maze[x][0]);
                maze[x].push(maze[x][maze[x].length - 1]);
            }
        }

        for (let i = 0; i < deadEndArray.length; ++i) {
            deadEndArray[i].y += (vertical.border - 1) * wallWidth;
        }
    }

    return maze;
}


/** 
    Carve empty rooms into map, which was expanded using parameters
    hallWidth, wallWidth from a maze that had the mazeDeadEndArray
    dead ends.
 */
function addMapRooms(map, hallWidth, wallWidth, horizontal, vertical, mazeDeadEndArray, roomsFraction) {
    const EMPTY = 0;
    const w = map.length, h = map[0].length, floor = Math.floor, min = Math.min, max = Math.max, ceil = Math.ceil;

    roomsFraction = max(0, min(1, roomsFraction));
    
    // Dimensions of the room
    const a = ceil(0.6 * (hallWidth + wallWidth) / max(roomsFraction, 0.4));
    const b = a;
    
    // Outermost rooms are usually at the end of the array
    const last = floor((mazeDeadEndArray.length - 1) * roomsFraction);
    for (let i = last; i >= 0; --i) {
        const c = mazeDeadEndArray[i];

        // Upper-left corner
        const u = floor(c.x - a / 2);
        const v = floor(c.y - b / 2);

        for (let x = max(wallWidth, u - a); x <= min(w - wallWidth - 1, u + a); ++x) {
            map[x].fill(EMPTY, max(wallWidth, v - b), min(h - wallWidth, v + b + 1));
        } // x
    } // i


    // Restore symmetry
    {
        const w = map.length;
        const h = map[0].length;
        if (horizontal.symmetry) {
            const offset = horizontal.loop ? hallWidth + 1 : 1;
            for (let y = 0; y < h; ++y) {
                for (let x = 0; x <= w / 2; ++x) {
                    map[w - offset - x][y] = map[x][y];
                }
            }
        } // horiz
        
        if (vertical.symmetry) {
            const offset = vertical.loop ? hallWidth + 1 : 1;
            for (let x = 0; x < w; ++x) {
                for (let y = 0; y <= h / 2; ++y) {
                    map[x][h - offset - y] = map[x][y];
                }
            }
        } // vert
    } // scope
}


/** Draws 0 as empty, 255 as solid, strings as their first character, 
    and everything else as half-solid. */
function mazeToString(map) {
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
