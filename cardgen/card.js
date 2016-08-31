"use strict";
/* 
   This program helps you quickly generate decks of cards.
   It is designed as an example that you modify. Rewrite the
   code, primarily modifying the card.css file.

   by Morgan McGuire, mcguire@cs.williams.edu
   Released into the Public Domain on 2 May 2015.
 */


var ABATTOIR_COST = 3;
/* These are your cards. You can compute this array instead of
   directly entering it as well. The abattoir cost is used as an
   example. */
var cardArray =
    [
        {
            // Standard properties:

            count: 4,
            type: "dominion card",

            // Properties specific to your cards. Each of these must
            // correspond to a CSS selector in the card.css file:

            name: "Abattoir",

            cost: ABATTOIR_COST,
            
            flavor: "You may trash exactly two cards.<br/>If you do, +<div class='coin'>3</div>.",

            image: "abattoir.png"
        },

        {
            count: 2,
            type: "dominion card",
            name: "Magician",
            cost: ABATTOIR_COST - 1,
            flavor: "Trash this card and gain any card costing up to <div class='coin'>1</div> more.",
            image: "magician.png"
        }
    ];


/* You should not need to modify this too much. It creates a DIV
   element and */
function makeCard(card) {
    document.write("<div class='" + card.type + "'>"); {
        for (var property in card) {
            if (property === "image") {
                document.write("<div class='default image' style='background-image: url(\"" + card["image"] + "\");'> </div>");
            } else if (card.hasOwnProperty(property) &&
                (property !== "count") && 
                (property !== "type")) {
                document.write("<div class='default " + property + "'>" + 
                               card[property] + "</div>");
            }
        }
    } document.write("</div>");
}


// Process each kind of card
for (var i = 0; i < cardArray.length; ++i) {
    var card = cardArray[i];
    
    // Repeat as many times as specified
    for (var c = 0; c < card.count; ++c) {
        makeCard(card);
    }
}
