// Runnable clean-naming example for the `no_single_letter` rule doc.
library;

// #region clean_names
/// Totals [scores], naming every local after what it holds.
int totalScores(List<int> scores) {
  int runningTotal = 0;
  for (int scoreIndex = 0; scoreIndex < scores.length; scoreIndex++) {
    runningTotal += scores[scoreIndex];
  }
  return runningTotal;
}
// #endregion clean_names
