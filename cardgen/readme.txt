Double click index.html to load it in your favorite web browser and it makes a sheet of cards that you can then print out. Either print to stickers and paste onto standard cards or print on paper and insert into a card sleeve.

You want to modify the top of card.js and the top of card.css. card.js is straight Javascript.

card.css is a CSS file. It is basically just a data file associating the names of card properties with formatting details, like where they go on the cards. I set up an example of a Dominion card.

The advantage of doing this instead of Illustrator or Photoshop is that you can easily change properties of the whole deck and then regenerate it. You can compute the cardArray using your own code, as well.

For example, if you want to change the cost of a card that appears 16x in the deck, you just change one number instead of 16 and messing with fonts. Or if you want to change your graphics, just change one spot on the CSS file. There's tons of information online about CSS. You can search for things like "CSS small caps" or "CSS line height" to learn about more fields.