// Polyfill
if (typeof HTMLCollection.prototype.forEach === "undefined") {
    HTMLCollection.prototype.forEach = Array.prototype.forEach;
}

function showMenu(event) { event.target.classList.add('activeMenu'); }

function closeAllMenus() {        
    document.getElementsByClassName('activeMenu').forEach(function (node) { node.classList.remove('activeMenu'); });
}

// Add the show menu event handler
window.addEventListener('load', function (event) { document.getElementsByClassName('menuLabel').forEach(function(node) { node.onclick = showMenu; }); });

// Close all open menus on click or escape
window.addEventListener('click', closeAllMenus, true);
window.addEventListener('keydown', function (event) { (event.key === "Escape") && closeAllMenus(); }, true);

(function () {
    var style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = `
    #menubar {
        position: absolute;
        left: 72px;
        top: 43px;
        font-size: 13px;
    }
    
    #menubar div {
        display: inline-block;
        vertical-align: top;
    }
    
    /* Menu label (no hover) */
    #menubar .menuLabel { 
        padding-top: 4px;
        padding-bottom: 4px;
        padding-left: 8px;
        padding-right: 8px;
        margin-right: 10px;
        margin-left: -8px;
    }
    
    /* Menu label (hover) */
    #menubar .menuLabel:hover {
        background: #eeeeee;
    }
    
    
    /* Drop-down menu (hidden) */
    #menubar div div {
        position: absolute;
        display: block;
        min-width: 120px;
        overflow: auto;
        background: #fff;
        box-shadow: 0px 2px 6px 0px rgba(0,0,0,0.5);
        z-index: 4;
        padding: 4px 2px 2px 30px;
        margin-left: -8px;
        margin-top: 4px;
    }
    
    /* Drop-down menu (hidden) */
    #menubar span:not(.activeMenu) + div {
        visibility:hidden;
    }
    
    /* Menu item */
    #menubar div div a {
        color: #000;
        text-decoration: none;
        display: block;
        padding: 4px;
        margin-top: 4px;
        margin-bottom: 4px;
    }
    
    /* Left-aligned icon within a menu item */
    #menubar div div a .icon {
        position: absolute;
        left: 9px;
    }
    
    /* Hotkey documentation in a menu item */
    #menubar div div a .hotkey {
        position: absolute;
        right: 9px;
        color: rgba(0,0,0,0.5);
    }
    
    /* Google's icon font within the menu */
    #menubar div div a .material-icons {
        font-size: 120%;
        color: rgba(0,0,0,0.55);
    }
    
    /* Line between menu items */
    #menubar div div hr {
        border: none;
        height: 1px;
        background: rgba(0,0,0,0.15);
        margin-left: -30px;
        margin-right: -2px;
        margin-top: 5px;
        margin-bottom: 5px;
    }
    `;
    document.getElementsByTagName('head')[0].appendChild(style);
})();