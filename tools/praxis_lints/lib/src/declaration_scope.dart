// Shared scope predicates for the Praxis house-rule lints.
//
// Both naming rules visit the same declaration nodes; the predicates here
// decide whether a node declares a checkable local-or-parameter name and
// whether a single-letter name sits in a for-loop header (the one place
// thesis invariant 3 permits short indices).
library;

import 'package:analyzer/dart/ast/ast.dart';

/// Whether [declaration] binds a name in a local scope (locals, loop
/// variables, pattern bindings, and formal parameters).
///
/// Fields and top-level variables are excluded: they are API surface, not
/// locals, and renaming them is a breaking change rather than a cleanup.
/// Anything unrecognized returns false (fail-closed: an unknown declaration
/// shape is never flagged).
bool isLocallyScopedName(AstNode declaration) {
  if (declaration is FieldFormalParameter ||
      declaration is SuperFormalParameter) {
    // `this.field` and `super.param` alias a declaration owned elsewhere;
    // renaming them means renaming the target, so they are never locals.
    return false;
  }
  if (declaration is FormalParameter) {
    return true;
  }
  AstNode? cursor = declaration.parent;
  while (cursor != null) {
    if (cursor is FieldDeclaration || cursor is TopLevelVariableDeclaration) {
      return false;
    }
    if (cursor is VariableDeclarationStatement ||
        cursor is PatternVariableDeclaration ||
        cursor is ForParts ||
        cursor is ForEachParts) {
      return true;
    }
    if (cursor is Block ||
        cursor is FunctionBody ||
        cursor is CompilationUnit) {
      return false;
    }
    cursor = cursor.parent;
  }
  return false;
}

/// Whether [declaration] sits directly in a for-loop header.
///
/// Only header declarations qualify (`for (var i = ...)`): a single-letter
/// local inside the loop *body* is still flagged. Stops at block, body, and
/// declaration boundaries so nesting can never leak the exemption inward.
bool isLoopHeaderName(AstNode declaration) {
  AstNode? cursor = declaration.parent;
  while (cursor != null) {
    if (cursor is ForParts || cursor is ForEachParts) {
      return true;
    }
    if (cursor is Block ||
        cursor is FunctionBody ||
        cursor is VariableDeclarationStatement ||
        cursor is PatternVariableDeclaration ||
        cursor is FieldDeclaration ||
        cursor is TopLevelVariableDeclaration ||
        cursor is FormalParameter) {
      return false;
    }
    cursor = cursor.parent;
  }
  return false;
}
