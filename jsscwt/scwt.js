'use strict';

const wordArray  = ['red',     'blue',    'yellow',  'green'];
const colorArray = ['#b23034', '#2941ae', '#e3b53f', '#419150'];

const defaultOptions = {
    task: 'alternating',
    instructions: 'Say the color of each word (ignore the text)',

    // If true, the color and the word can match
    allowColorMatch: false,

    // If true, a word horizontally or vertically adjacent
    // can be the same
    allowDuplicateWords: false,

    // If true, a color horizontally or vertically adjacent
    // can be the same
    allowDuplicateColors: false,
    showRowNumbers: true,
    rows: 5,
    columns: 7,
    fontSize: 24,
    fontFamily: 'helvetica'
};

let options = {...defaultOptions, ...JSON.parse(localStorage.getItem('options') || '{}')};
let startTime;

/* Inclusive. Slightly nonuniform distribution due to the set of all
   floats not mapping to the set of ints in this range, but good
   enough for this application. */
function randomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function optionsToGui() {
    document.getElementById(options.fontFamily).checked = true;
    document.getElementById(options.task).checked = true;
    document.getElementById('rows').value = options.rows;
    document.getElementById('columns').value = options.columns;
    document.getElementById('allowColorMatch').checked = options.allowColorMatch;
    document.getElementById('allowDuplicateColors').checked = options.allowDuplicateColors;
    document.getElementById('allowDuplicateWords').checked = options.allowDuplicateWords;
}

function guiToOptions() {
    for (let e of document.querySelectorAll('input[name=task]')) {
        if (e.checked) {
            options.task = e.id;
            options.instructions = e.title;
        }
    }

    for (let e of document.querySelectorAll('input[name=fontFamily]')) {
        if (e.checked) { options.task = e.id; }
    }

    options.rows = Math.max(1, Math.min(10, parseInt(document.getElementById('rows').value)));
    options.columns = Math.max(1, Math.min(10, parseInt(document.getElementById('columns').value)));
    options.allowColorMatch = document.getElementById('allowColorMatch').checked;
    options.allowDuplicateColors = document.getElementById('allowDuplicateColors').checked;
    options.allowDuplicateWords = document.getElementById('allowDuplicateWords').checked;
}

function start() {
    guiToOptions();
    localStorage.setItem('options', JSON.stringify(options));
    let s = `<center>${options.instructions} out loud. Proceed from left to right and top to bottom.</center><center><table style="font-family: ${options.fontFamily}; font-weight: bold; font-size: ${options.fontSize}pt">`;
    let prevRowColorIndex = [], prevRowWordIndex = [];
    for (let r = 0; r < options.rows; ++r) {
        let prevColorIndex, prevWordIndex;
        s += `<tr style="height: ${options.fontSize * 4}pt">`;

        if (options.showRowNumbers) {
            s += `<td style="color: #000; font-weight: normal; text-align: right">${r + 1}</td>`;
        }
        
        for (let c = 0; c < options.columns; ++c) {
            let colorIndex, wordIndex;

            do {
                colorIndex = randomInt(0, colorArray.length - 1);
            } while (((colorIndex === prevColorIndex) ||
                      (colorIndex === prevRowColorIndex[c])) &&
                     ! options.allowDuplicateColors);
            
            do {
                wordIndex = randomInt(0, wordArray.length - 1);
            } while ((((wordIndex === prevWordIndex) ||
                       (wordIndex === prevRowWordIndex[c])) && ! options.allowDuplicateWords) ||
                     (colorIndex === wordIndex && ! options.allowColorMatch));
            
            s += `<td style="text-align: center; color: ${colorArray[colorIndex]}; width: ${options.fontSize * 50}pt">${wordArray[wordIndex]}</td>`;
            
            prevColorIndex = colorIndex;
            prevRowColorIndex[c] = colorIndex;
            prevWordIndex = wordIndex;
            prevRowWordIndex[c] = wordIndex;
        }
        s += '</tr>\n';
    }

    s += '</table></center>\n';

    s += `<center>Click, touch, or press any key when done</center>`;

    document.getElementById('instructionsPane').style.visibility = 'hidden';
    const pane = document.getElementById('taskPane');
    pane.innerHTML = s;
    pane.style.visibility = 'visible';
    
    startTime = new Date().getTime();
}

function stop() {
    const stopTime = new Date().getTime();
    const durationMilliseconds = stopTime - startTime;
    document.getElementById('taskPane').style.visibility = 'hidden';
    const resultPane = document.getElementById('resultPane');
    resultPane.style.visibility = 'visible';

    const min = Math.floor(durationMilliseconds / (60 * 1000));
    const sec = ((durationMilliseconds - (min * 60 * 1000)) / 1000);
    const count = options.rows * options.columns;
    const rate = count / (durationMilliseconds / (60 * 1000));

    let s = `<center style="margin-top:40px">${count} words in `;

    if (min > 0) {
        s += `${min} min `;
    }

    s += `${sec.toFixed(2)} sec = ${rate.toFixed(1)} words/min</center>`;
    console.log(s);

    s += '<br><center><button onclick="reset()">Reset</button></center>'
    s = '<br><br>\n' + s;
    
    resultPane.innerHTML = s;
}


function reset() {
    document.getElementById('resultPane').style.visibility = 'hidden';
    document.getElementById('instructionsPane').style.visibility = 'visible';
}
