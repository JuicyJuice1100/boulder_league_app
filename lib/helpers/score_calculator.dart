num calculateScore({required num attempts, required bool completed}) {
  num score = 0;

  if(completed) {
    score += 100;

    if(attempts == 1) {
      score += 25;
    } else {
      score -= attempts * .1;
    }
  }

  return score;
}
