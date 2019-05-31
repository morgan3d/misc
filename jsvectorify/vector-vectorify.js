function vectorify(program, options) {
    options = Object.assign({
        assignmentReturnsUndefined: false
    }, options || {});
    
    let src, args;
    if (typeof program === 'string') {
        src = program;
    } else {
        // Wrapped in a string. Get the source and then strip the
        // function declaration.
        src = program.toString();
        src = src.replace(/^[ \t\n]*(function\s+\().*(\)[ \n\t]*{)/, function(match, fcn, a, ignore) {
            args = a.split(',');
            return '';
        }).replace(/}[ \t\n]*$/, '');
    }

    let ast = _recast.parse(src);

    const opTable = Object.freeze({ '+': '_add', '-': '_sub', '*': '_mul', '/': '_div' });
    const create = _recast.types.builders;

    function wrapUndefined(node) {
        return create.sequenceExpression([node, create.identifier('undefined')]);
    }
    
    ast.program = _estraverse.replace(ast.program, {
        // Wrap mutating operators on traversal *back up* the tree so
        // that we do not recursively process the same node
        // indefinitely.
        leave: (! options.assignmentReturnsUndefined) ? undefined :
            function (node, parent) {
                // If the parent is an expression statement (the most common case`)
                // then this node's value is not being used anyway.
                if (parent.type === 'ExpressionStatement') { return; }
                
                switch (node.type) {
                case 'UpdateExpression': // ++ or --
                case 'AssignmentExpression': // +=, -=, *=, etc.
                    return wrapUndefined(node);
                }
            },
        
        enter: function(node) {
            if ((node.type === 'UnaryExpression') && (node.argument.type !== 'Literal')) {
                if (node.operator === '-') {
                    // Unary minus
                    return create.callExpression(create.identifier('_neg'), [node.argument]);
                } else if (node.operator === '+') {
                    // Unary plus, ignore the operator
                    return node.argument;
                }
                
            } else if (((node.type === 'BinaryExpression') &&
                        ((node.left.type !== 'Literal') || (node.right.type !== 'Literal'))) ||
                       (node.type === 'AssignmentExpression')) {
                
                let fcnName = opTable[node.operator[0]];
                if (fcnName && (node.operator.length === 1)) {
                    // Binary functional operation
                    return create.callExpression(create.identifier(fcnName), [node.left, node.right]);
                } else if (fcnName && (node.operator[1] === '=')) {
                    // Mutating binary operation
                    
                    // Is there a more complicated lvalue than identifier.identifier?
                    if ((node.left.type === 'MemberExpression') && (node.left.computed || node.left.object.type !== 'Identifier')) {
                        // Complex lvalue
                        //
                        // Rewrite to avoid reevaluating either the table/array or the key value 
                        // (for side effects, but also efficiency)
                        let lvalue = node.left, rvalue = node.right;
                        let keyExpr = lvalue.computed ?
                            // obj[key]
                            lvalue.property : 
                            
                            // obj.key; convert the identifier into a literal
                            create.literal(lvalue.property.name);
                        
                        return create.callExpression(create.identifier('_mutate'),
                                                     [lvalue.object, keyExpr, create.identifier(fcnName + 'Mutate'), rvalue]);
                        
                    } else {
                        // Simple expression on the left
                        return create.assignmentExpression(
                            '=',
                            node.left,
                            create.callExpression(create.identifier(fcnName + 'Mutate'), [node.left, node.right]));
                    }
                }
            } // if binary expression
        }
    });
    
    const body = _recast.print(ast).code;
    if (typeof program === 'string') {
        return body;
    } else {
        // Create a function
        for (let i = 0; i < args.length; ++i) {
            args[i] = args[i].trim();
        }
        args.push(body);

        return Function.constructor.apply(null, args);
    }
}
