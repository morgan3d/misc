function vectorify(program, options) {

    // See https://github.com/benjamn/recast for the parsing documentation.
    // See https://github.com/benjamn/ast-types for the AST documentation.
    
    options = Object.assign({
        assignmentReturnsUndefined: false,
        scalarEscapes: false,
        equalsCallback: undefined,
        operatorPrefix: '_',
        throwErrors: true
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

    const ast = _recast.parse(src);

    if (options.throwErrors) {
        if (ast.program.errors && ast.program.errors.length > 0) {
            throw ast.program.errors[0].original;
        } else if (ast.program.program && ast.program.program.errors && ast.program.program.errors.length > 0) {
            throw ast.program.program.errors[0].original;
        }
    }
    
    const _ = options.operatorPrefix;
    const opTable = Object.freeze({ '+': _ + 'add', '-': _ + 'sub', '*': _ + 'mul', '/': _ + 'div' });

    // The MAD gets special extra processing to introduce an extra addition operation at the end
    const escapeTable = {'ADD': '+', 'MUL': '*', 'SUB': '-', 'DIV': '/', 'MAD' : '*'};
    const create = _recast.types.builders;

    // Wraps an expression so that it returns 'undefined', hiding its value.
    // This could also be implemented using the 'void' operator.
    function wrapUndefined(node) {
        return create.sequenceExpression([node, create.identifier('undefined')]);
    }

    function allLiteral(node) {
        if (node.type === 'Literal') {
            return true;
        } else if (node.type === 'BinaryExpression') {
            return allLiteral(node.left) && allLiteral(node.right);
        }
            
        return false;
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
            if (options.throwErrors && node.errors && node.errors.length > 0) {
                throw node.errors[0].original;
            }
            
            if ((node.type === 'UnaryExpression') && (node.argument.type !== 'Literal')) {
                if (node.operator === '-') {
                    // Unary minus
                    return create.callExpression(create.identifier(_ + 'neg'), [node.argument]);
                } else if (node.operator === '+') {
                    // Unary plus, ignore the operator
                    return node.argument;
                }
            } else if (options.equalsCallback && (node.type === 'BinaryExpression') && (node.operator === '==')) {

                return options.equalsCallback(node);
                
            } else if (((node.type === 'BinaryExpression') && ! allLiteral(node)) ||
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
                        
                        return create.callExpression(create.identifier(_ + 'mutate'),
                                                     [lvalue.object, keyExpr, create.identifier(fcnName + 'Mutate'), rvalue]);
                        
                    } else {
                        // Simple expression on the left
                        return create.assignmentExpression(
                            '=',
                            node.left,
                            create.callExpression(create.identifier(fcnName + 'Mutate'), [node.left, node.right]));
                    }
                }
            } else if (node.type === 'CallExpression') {
                const op = escapeTable[node.callee.name];
                if (op) {
                    // This is a scalar escape function. Create an operator expression
                    // using the arguments
                    if (node.callee.name === 'MAD') {
                        // Inject the addition, and convert the rest to MUL for recursive processing
                        return create.binaryExpression('+',
                                                       create.callExpression(create.identifier('MUL'), [node.arguments[0], node.arguments[1]]),
                                                       node.arguments[2]);
                    } else {
                        return create.binaryExpression(op, node.arguments[0], node.arguments[1]);
                    }
                }
            } // expression type
        }
    });

    let body = _recast.print(ast, {wrapColumn:Infinity}).code;

    // Replace any nullish rewriting done. This is exactly tied to the syntax used by the nullish rewriter
    // below.
    body = body.replace(/\bfunction\((__nullish_gen\d+)\) {\n([\s\S]+)\1;\s*\}/g, 'function($1){$2$1;}')
    
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

// Using '==' to build a '??' operator for browsers that don't support it.
// This would make a lot more sense using the actual '??' operator, but esprima can't
// parse that yet, so we re-use the (now deprecated) '==' operator. In the future
// when esprima is updated, we'll use this to rewrite the nullish operator itself
// for older browsers.
//
// L ?? R -> (function (_L) { return _L === undefined ? (R) : _L; })(L)
//
// The exact output pattern is intentionally chosen so that newlines inserted
// by the prettyprinter can be detected and removed.
vectorify.nullishRewriter = function(node) {
    const create = _recast.types.builders;
    
    // Unique identifier
    const _L = create.identifier('__nullish_gen' + Math.floor(Math.random() * 2e9));
    const testExpr = create.binaryExpression('===', _L, create.identifier('undefined'));
    const bodyExpr =
          create.blockStatement([
              create.returnStatement(
                  create.conditionalExpression(testExpr, node.right, _L)),
          ]);
    const fcn = create.functionExpression(null, [_L], bodyExpr);
    return create.callExpression(fcn, [node.left]);
}
