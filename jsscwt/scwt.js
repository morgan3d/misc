'use strict';

/* Maps colorSet to stimuli */
const stimulusTable = {
    rgyb: {
        wordArray:  ['red',     'green',   'yellow',  'blue'],
        colorArray: ['#b23034', '#419150', '#e3b53f', '#2941ae']
    },

    rgykp: {
        wordArray:  ['red',     'green',   'yellow',  'black',   'purple'],
        colorArray: ['#b23034', '#419150', '#e3b53f', '#000000', '#c32fee']
    }
};


const defaultOptions = {
    task: 'alternating',
    instructions: 'Say the color of each word (ignore the text)',

    colorSet: 'rgykp',

    // If false, the color and the word can match
    avoidColorMatch: true,

    // If false, a word horizontally adjacent
    // can be the same
    avoidDuplicateWords: true,

    // 3-word sequences with the same index (includes wrapping)
    avoidChains: true,

    // If true, avoid repeating a color horizontally
    avoidDuplicateColors: true,

    avoidVerticalPatterns: true,

    useEveryColor: true,
    
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
    document.getElementById(options.colorSet).checked = true;
    document.getElementById('rows').value = options.rows;
    document.getElementById('columns').value = options.columns;
    document.getElementById('avoidColorMatch').checked = options.avoidColorMatch;
    document.getElementById('avoidDuplicateColors').checked = options.avoidDuplicateColors;
    document.getElementById('avoidDuplicateWords').checked = options.avoidDuplicateWords;
    document.getElementById('avoidChains').checked = options.avoidChains;
    document.getElementById('avoidVerticalPatterns').checked = options.avoidVerticalPatterns;
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

    for (let e of document.querySelectorAll('input[name=colorSet]')) {
        if (e.checked) { options.colorSet = e.id; }
    }

    options.rows = Math.max(1, Math.min(10, parseInt(document.getElementById('rows').value)));
    options.columns = Math.max(1, Math.min(10, parseInt(document.getElementById('columns').value)));
    options.avoidColorMatch = document.getElementById('avoidColorMatch').checked;
    options.avoidDuplicateColors = document.getElementById('avoidDuplicateColors').checked;
    options.avoidDuplicateWords = document.getElementById('avoidDuplicateWords').checked;
    options.avoidChains = document.getElementById('avoidChains').checked;
    options.avoidVerticalPatterns = document.getElementById('avoidVerticalPatterns').checked;
}


function start() {
    guiToOptions();
    localStorage.setItem('options', JSON.stringify(options));
    let s = `<center>${options.instructions} out loud. Proceed from left to right and top to bottom.</center><center><table id="grid" style="transition: 0.3s filter linear, 0.3s -webkit-filter linear; filter: blur(25px) saturate(0); font-family: ${options.fontFamily}; text-align: center; font-weight: bold; margin-top: 20px; font-size: ${options.fontSize}pt">`;
    let prevRowColorIndex = [], prevRowWordIndex = [];

    // Queue of recent indices used
    let chainIndex = [-1, -1];

    if (options.task === 'alternating') {
        s += '<tr valign=bottom style="font-weight: normal; font-size: 80%; color: #AAA">';
        if (options.showRowNumbers) {
            s += '<td></td>';
        }
        s += '<td>word</td><td>color</td><td>...</td></tr>';
    }

    const stimulus = stimulusTable[options.colorSet];
    const wordArray = stimulus.wordArray;
    const colorArray = stimulus.colorArray;
    
    for (let r = 0; r < options.rows; ++r) {
        s += `<tr valign=top style="height: ${options.fontSize * 4}pt">`;

        if (options.showRowNumbers) {
            s += `<td style="color: #AAA; font-weight: normal; text-align: right">${r + 1}</td>`;
        }

        const MAX_ROW_TRIES = 5;
        let rowTries = 0;
        // Masks to detect whether along a row every word/color has been used
        let colorUsedMask, wordUsedMask;
        let rowString;

        
        let backupPrevRowColorIndex = prevRowColorIndex,
            backupPrevRowWordIndex = prevRowWordIndex;
        
        do {
            // Restore from backup in case of multiple row tries
            prevRowColorIndex = [...backupPrevRowColorIndex];
            prevRowWordIndex = [...backupPrevRowWordIndex];
            
            let prevColorIndex, prevWordIndex;
            rowString = '';
            colorUsedMask = (1 << colorArray.length) - 1;
            wordUsedMask = colorUsedMask;
            
            if (options.task === 'blackWords') { colorUsedMask = 0; }
            if (options.task === 'colorBoxes') { wordUsedMask = 0; }
            
            for (let c = 0; c < options.columns; ++c) {
                let colorIndex, wordIndex;
                
                const sayWord = ((c + r) % 2) === 0;
                
                const MAX_TRIES = 10;
                let tries = 0;
                do {
                    if (options.task !== 'blackWords') {
                        do {
                            colorIndex = randomInt(0, colorArray.length - 1);
                        } while (((colorIndex === prevColorIndex) ||
                                  (colorIndex === prevRowColorIndex[c] && options.avoidVerticalPatterns)) &&
                                 options.avoidDuplicateColors);
                    }
                    
                    if (options.task !== 'colorBoxes') {
                        do {
                            wordIndex = randomInt(0, wordArray.length - 1);
                        } while ((((wordIndex === prevWordIndex) ||
                                   (wordIndex === prevRowWordIndex[c] && options.avoidVerticalPatterns)) && ! options.avoidDuplicateWords) ||
                                 (colorIndex === wordIndex && options.avoidColorMatch));
                    }
                    
                    // Don't get stuck
                    ++tries;
                } while (
                    (tries < MAX_TRIES) &&
                        options.avoidChains &&
                        (options.task === 'alternating') &&
                        (chainIndex[0] === chainIndex[1]) &&
                        ((sayWord && wordIndex === chainIndex[0]) ||
                         (! sayWord && colorIndex === chainIndex[0])));
                
                if (tries === MAX_TRIES) {
                    console.log('Note: exceeded max tries for generating a pattern');
                }
                
                chainIndex[0] = chainIndex[1];
                chainIndex[1] = sayWord ? wordIndex : colorIndex;
                
                const color = options.task === 'blackWords' ? '#000' : colorArray[colorIndex];
                const word = options.task === 'colorBoxes' ? '&#x2588;&#x2588;&#x2588;' : wordArray[wordIndex];
                rowString += `<td style="text-align: center; color: ${color}; width: ${options.fontSize * 50}pt">${word}</td>`;
                
                prevColorIndex = colorIndex;
                prevRowColorIndex[c] = colorIndex;
                prevWordIndex = wordIndex;
                prevRowWordIndex[c] = wordIndex;
            }

            // Keep iterating if there were unused colors
            ++rowTries;
        } while ((rowTries < MAX_ROW_TRIES) &&
                 options.useEveryColor && (colorUsedMask | wordUsedMask));
                 
        s += rowString + '</tr>\n';
    }

    s += '</table></center>\n';

    s += `<center>Click, touch, or press any key when done.</center>`;

    s += '<div id="startButton" style="position: absolute; top: 40%; width:100%; text-align: center"><button onclick="startTimer()">Begin</button></div>';

    document.getElementById('instructionsPane').style.visibility = 'hidden';
    const pane = document.getElementById('taskPane');
    pane.innerHTML = s;
    pane.style.visibility = 'visible';

}

function startTimer() {
    document.getElementById('grid').style.filter = 'none';
    document.getElementById('startButton').remove();
    startTime = new Date().getTime();
}

function stop() {
    const stopTime = new Date().getTime();
    const durationMilliseconds = stopTime - startTime;
    if (! startTime || durationMilliseconds < 1000) {
        // Must be an accident
        return;
    }
        
    startTime = undefined;
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
