// The `no_banned_names` house rule: thesis invariant 3, second half.
library;

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'declaration_scope.dart';

/// Default denylist for [NoBannedNamesRule].
///
/// Seeds thesis invariant 3 (`data`, `item`, `res`) plus the abbreviations
/// the craft floor bans outright (`err`, `ctx`, `req`, `cfg`, `usr`, `mgr`,
/// `svc`), the two ubiquitous temp-name shortenings (`tmp`, `temp`), and
/// the generic value/object shortenings (`val`, `obj`).
/// Deliberately absent: `result`, `info`, and `dto`, which read as
/// legitimate domain nouns in this codebase; they join on observed
/// evidence, never speculatively. Matching is exact and case-sensitive, so
/// `database` or `items` never trip the rule.
const Set<String> defaultBannedNames = <String>{
  'data',
  'item',
  'res',
  'err',
  'ctx',
  'req',
  'cfg',
  'usr',
  'mgr',
  'svc',
  'tmp',
  'temp',
  'val',
  'obj',
};

/// Flags denylisted local and parameter names.
///
/// Dart ships no built-in lint for generic or abbreviated identifiers: the
/// SDK set checks style (`non_constant_identifier_names`) and narrow
/// over-specific cases, never whether a name carries meaning. That is the
/// stdlib gap this rule fills for thesis invariant 3 ("names a stranger
/// can grep").
///
/// A violation looks like this:
///
/// ```dart
/// int count(List<int> data) { // LINT: `data` says nothing about the content.
///   return data.length;
/// }
/// ```
///
/// The clean form below is a runnable example, verified by `dart analyze`
/// over this package:
///
/// {@example /example/no_banned_names.dart#clean_names}
///
/// The denylist is configurable at the Dart level through [bannedNames]:
/// the analysis server only toggles rules on and off, so per-rule options
/// cannot travel through `analysis_options.yaml`. The plugin registers the
/// [defaultBannedNames]-seeded instance. Fields, top-level variables,
/// field-formal and super parameters, and catch-clause parameters follow
/// the same scope edges as `no_single_letter`.
class NoBannedNamesRule extends AnalysisRule {
  /// The diagnostic reported for every denylisted local or parameter.
  static const LintCode code = LintCode(
    'no_banned_names',
    'Banned name `{0}`; say what the value holds instead.',
    correctionMessage: 'Rename to a descriptive noun; extend the denylist, never shrink it silently.',
  );

  /// Creates the `no_banned_names` rule.
  ///
  /// When [bannedNames] is omitted, [defaultBannedNames] applies. Pass an
  /// explicit set to extend or replace the seed for a codebase that has
  /// earned its own additions.
  NoBannedNamesRule({Set<String>? bannedNames})
    : bannedNames = bannedNames ?? defaultBannedNames,
      super(
        name: 'no_banned_names',
        description:
            'Flags denylisted local variable and parameter names such as '
            '`data`, `item`, and `res`.',
      );

  /// The names this instance flags; defaults to [defaultBannedNames].
  final Set<String> bannedNames;

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

  final NoBannedNamesRule rule;

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
    if (!rule.bannedNames.contains(name)) {
      return;
    }
    rule.reportAtToken(nameToken, arguments: <Object>[name]);
  }
}
