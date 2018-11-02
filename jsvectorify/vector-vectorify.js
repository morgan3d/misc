function vectorify(program) {
    let src = (typeof program === 'string') ? program : program.toString();

    let ast = _recast.parse(src);

    const opTable = Object.freeze({ '+': '_add', '-': '_sub', '*': '_mul', '/': '_div' });
    const create = _recast.types.builders;
    
    ast.program = _estraverse.replace(ast.program, {
        enter: function(node) {
            if (node.type === 'UnaryExpression') {
                if (node.operator === '-') {
                    // Unary minus
                    return create.callExpression(create.identifier('_neg'), [node.argument]);
                } else if (node.operator === '+') {
                    // Unary plus, ignore the operator
                    return node.argument;
                }
                
            } else if ((node.type === 'BinaryExpression') || (node.type === 'AssignmentExpression')) {
                
                let fcnName = opTable[node.operator[0]];
                if (fcnName && (node.operator.length === 1)) {
                    // Binary functional operation
                    return create.callExpression(create.identifier(fcnName), [node.left, node.right]);
                } else if (fcnName) {
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
    
    return _recast.print(ast).code;
}
