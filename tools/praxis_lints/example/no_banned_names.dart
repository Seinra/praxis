// Runnable clean-naming example for the `no_banned_names` rule doc.
library;

// #region clean_names
/// Counts [scores], naming the parameter after its content, not `data`.
int countScores(List<int> scores) {
  return scores.length;
}
// #endregion clean_names
