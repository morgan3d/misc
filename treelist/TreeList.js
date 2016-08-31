/*
TreeList.js 
Open Source under the BSD License

Copyright (c) 2012, Morgan McGuire
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

var TreeList = (function() {
/** parentElement is only required when constructing the root element */
function Node(treeList, parentNode, value, childNodes, parentElement) {
    var thisIsRoot = (parentNode === null);
    
    this.parent     = parentNode;
    this.childNodes = childNodes || [];
    this.value      = value;

    if (! thisIsRoot) {
        this.element = document.createElement('LI');
        if (this.childNodes.length === 0) {
            this.element.className = 'Leaf';
        } else {
            this.element.className = 'Closed';
        }
       
        // Create two nodes: one for the button
        var icon = document.createElement('DIV');
        icon.className = 'Icon';
        this.element.appendChild(icon);
        
        this.label = document.createElement('SPAN');
        this.label.className = 'Label';

        if (value.toHTML) {
            this.label.innerHTML = value.toHTML();
        } else {
            this.label.appendChild(document.createTextNode(value.toString()));
        }
        this.element.appendChild(this.label);

        var node = this;
        // Create a new function to capture the 'node' and 'treeList' variables
        var callback = function(event) {
            if (treeList.justScrolled) {
                // This call was triggered by our touchend handler and is for
                // a single drag (probably to move).  Ignore the event.
                return;
            }

            if (treeList.selectedNode) {
                // Deselect the old node
                treeList.selectedNode.label.className = 'Label';
            }
            treeList.selectedNode = node;
            treeList.selectedNode.label.className = "Selected Label";

            treeList.onSelectionChange();
            event.preventDefault();
        };
        
        this.label.onclick = callback;
        this.label.ontouchend = callback;

        // Make the icon open/close the node
        icon.onclick = treeList.iconOnClick;

        // Make iOS more responsive by not waiting for 300ms after
        // touchend to trigger the click. This prevents scrolling by
        // grabbing the icon, but that is OK.
        icon.ontouchstart = treeList.iconOnClick;
    }

    this.containerElement = document.createElement('UL');
    this.containerElement.className = 'TreeList';


    if (thisIsRoot) {
        parentElement.appendChild(this.containerElement);
    } else {
        this.element.appendChild(this.containerElement);
        parentNode.containerElement.appendChild(this.element);
    }
}


/** Recursively search for a descendant whose value is === value, and return null if not found. */
Node.prototype.find = function(value) {
    if (value === null) {
        // Asking the root for itself
        return this;
    } else if (value === this.value) {
        return this;
    } else {
        var c, r;
        for (c = 0; c < this.childNodes.length; ++c) {
            r = this.childNodes[c].find(value);
            if (r !== null) {
                return r;
            }
        }
        
        // Could not find it
        return null;
    }
}


/** Returns the new node */
Node.prototype.add = function(treeList, childValue) {
    // The Node constructor automatically creates the extra HTML elements
    var node = new Node(treeList, this, childValue);
    this.childNodes.push(node);
    
    if (this.element && (this.element.className === 'Leaf')) {
        this.element.className = 'Closed';
    }

    return node;
}


Node.prototype.remove = function(childValue) {
    var c;
    for (c = 0; c < this.childNodes.length; ++c) {
        var node = childNodes[c];
        if (node.value === childValue) {
            // Remove from GUI
            this.containerElement.removeChild(node.element);

            // Remove from data model
            this.childNodes.splice(c, 1);

            if ((this.childNodes.length === 0) && this.element) {
                this.element.className = 'Leaf';
            }

            return;
        }
    }
}

/** 
  A TreeList maintains a hierarchical order on a set of values.

  Values must have a toString method that converts them to the 
  text to display.

  Identical values are detected with ===

 */
function TreeList(parentHTMLElementId, onSelectionChange) {

    var me = this;

    this.onSelectionChange = onSelectionChange || function() {}
    
    var container = document.getElementById(parentHTMLElementId);

    // Detect moving touches and use them to turn off our selection handler
    // that executes at ontouchend on each node.
    this.justScrolled = false;
    container.ontouchstart = function(event) { me.justScrolled = false; };
    container.ontouchmove = function(event) { me.justScrolled = true; };

    // Click handler customed for this tree object
    this.iconOnClick = function(event) {
        // 'this' is bound to the icon
        var nodeElement = this.parentNode;

        if (nodeElement.className === 'Closed')    nodeElement.className = 'Open';
        else if (nodeElement.className === 'Open') nodeElement.className = 'Closed';
        // (Leave Leaf nodes alone)
    
        // Do not let the parent handle the node
        event.stopPropagation();
        event.preventDefault();
    }; // iconOnClick



    this.selectedNode = null;
    this.root = new Node(this, null, 'ROOT', [], container);
}


/** Use null for the parentValue of the root */
TreeList.prototype.addChild = function(parentValue, childValue) {
    this.root.find(parentValue).add(this, childValue);
}

     
/** http://studiokoi.com/blog/article/typechecking_arrays_in_javascript */
function isArray(a) {
    return Object.prototype.toString.apply(a) === '[object Array]';
}


/** Ignores the first child, which is the parent value */
function _addChildren(treeList, parentNode, childValueNestedArray) {
    var c;
    for (c = 1; c < childValueNestedArray.length; ++c) {
        var child = childValueNestedArray[c];
        if (isArray(child)) {
            // Nested array
            // Create the child node and then recurse recurse into the grandchildren
            _addChildren(treeList, parentNode.add(treeList, child[0]), child);
        } else {
            // Single child, add directly
            parentNode.add(treeList, child);
        }
    }
}

/** Add multiple children in the format:

    [A,
       [B, C],
       D,
       E];
    
    =

    A
    |--B 
    |  `-C
    |- D
    `- E

 */
TreeList.prototype.addSubtree = function(nestedArray) {
    _addChildren(this, this.root.find(nestedArray[0]), nestedArray);
}


TreeList.prototype.remove = function(childValue) {
    var n = this.root.find(childValue);

    if (n === this.selectedNode) {
        setSelectedValue(null);
    }

    n.parentNode.remove(childValue);
}


/** Prefetch the images */
TreeList.prototype.icons =
    [new Image('TreeList-Open.gif'),
     new Image('TreeList-Closed.gif'),
     new Image('TreeList-Leaf.gif')];


/** Return the currently selected value, or null. */
TreeList.prototype.selectedValue = function () {
    if (this.selectedNode) {
        return this.selectedNode.value;
    } else {
        return null;
    }
}


/** Or pass null to deselect */
TreeList.prototype.setSelectedValue = function (value) {
    if (this.selectedNode) {
        if (this.selectedNode.value === value) {
            return;
        }

        // Deselect the old node
        this.selectedNode.label.className = 'Label';
    }

    if (value) {
        this.root.find(value).label.className = 'Selected Label';
        this.onSelectionChange();
    } else if (this.selectedNode !== null) {
        this.selectedNode = null;
        this.onSelectionChange();
    }
}


/** Remove all elements */
TreeList.prototype.clear = function () {
    this.setSelectedValue(null);
    var i;
    for (i = 0; i < this.root.childNodes.length; ++i) {
        this.root.containerElement.removeChild(this.root.childNodes[i].element);
    }
    this.root.childNodes = [];
}

return TreeList;

    })();
