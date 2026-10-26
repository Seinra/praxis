// The `no_single_letter` house rule: thesis invariant 3, first half.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'declaration_scope.dart';

/// Flags single-letter local and parameter names.
///
/// Dart ships style lints such as `non_constant_identifier_names`, but no
/// built-in lint judges name *length*: a camelCase single letter like `x`
/// passes the SDK set untouched. That is the stdlib gap this rule fills for
/// thesis invariant 3 ("names a stranger can grep").
///
/// A violation looks like this:
///
/// ```dart
/// void main() {
///   var x = 1; // LINT: rename to what the value holds.
///   print(x);
/// }
/// ```
///
/// The clean form below is a runnable example, verified by `dart analyze`
/// over this package:
///
/// {@example /example/no_single_letter.dart#clean_names}
///
/// Short loop indices are excepted (`for (var i = 0; ...)`), as is the
/// wildcard `_`. Field-formal and super parameters (`this.field`,
/// `super.param`) are out of scope: they alias a declaration owned
/// elsewhere, so renaming them means renaming the target. Catch-clause
/// parameters are out of scope too: the SDK-idiomatic `catch (e)` would
/// otherwise drown the signal.
class NoSingleLetterRule extends AnalysisRule {
  /// The diagnostic reported for every single-letter local or parameter.
  static const LintCode code = LintCode(
    'no_single_letter',
    'Single-letter name `{0}`; use a name a stranger can grep.',
    correctionMessage:
        'Rename to a descriptive noun; keep short indices in for-loop headers.',
  );

  /// Creates the `no_single_letter` rule with its default configuration.
  NoSingleLetterRule()
    : super(
        name: 'no_single_letter',
        description:
            'Flags single-letter local variable and parameter names; '
            'short for-loop indices and the wildcard `_` are excepted.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final _Visitor visitor = _Visitor(this);
    registry
      ..addVariableDeclaration(this, visitor)
      ..addRegularFormalParameter(this, visitor)
      ..addDeclaredIdentifier(this, visitor)
      ..addDeclaredVariablePattern(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final AnalysisRule rule;

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    // A for-each loop variable is always locally scoped.
    _checkName(node, node.name);
  }

  @override
  void visitDeclaredVariablePattern(DeclaredVariablePattern node) {
    if (!isLocallyScopedName(node)) {
      return;
    }
    _checkName(node, node.name);
  }

  @override
  void visitRegularFormalParameter(RegularFormalParameter node) {
    _checkName(node, node.name);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (!isLocallyScopedName(node)) {
      return;
    }
    _checkName(node, node.name);
  }

  void _checkName(AstNode declaration, Token? nameToken) {
    if (nameToken == null) {
      return;
    }
    final String name = nameToken.lexeme;
    if (name.length != 1 || name == '_') {
      return;
    }
    if (isLoopHeaderName(declaration)) {
      return;
    }
    rule.reportAtToken(nameToken, arguments: <Object>[name]);
  }
}
