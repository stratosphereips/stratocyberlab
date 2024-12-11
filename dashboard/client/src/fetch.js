const difficultyOrder = { easy: 1, medium: 2, hard: 3 };

export async function fetchChallenges() {
  try {
    const res = await fetch(`/api/challenges`);
    const challenges = await res.json();

    if (res.status !== 200) {
      throw new Error(`Error: request failed with HTTP status ${res.status}: ${await res.text()}`);
    }

    // sort based on challenges difficulties - first we show easy, then medium and lastly hard
    challenges.sort((a, b) => {
      return difficultyOrder[a.difficulty] - difficultyOrder[b.difficulty];
    });

    const res2 = await fetch(`/api/challenges/up`);
    const upChallenges = await res2.json();
    if (res2.status !== 200) {
      throw new Error(`Error: request failed with HTTP status ${res2.status}: ${res2.body}`);
    }
    upChallenges.forEach((ch_id) => {
      const ch = challenges.find((ch) => ch.id === ch_id);
      if (ch) {
        ch['running'] = true;
      }
    });
    return challenges;
  } catch (err) {
    console.error(err);
    alert(err instanceof Error ? err.message : err);
  }
}

export async function fetchClasses() {
  try {
    const res = await fetch(`/api/classes`);
    const classes = await res.json();

    if (res.status !== 200) {
      throw new Error(`Error: request failed with HTTP status ${res.status}: ${await res.text()}`);
    }

    const res2 = await fetch(`/api/classes/up`);
    const upClasses = await res2.json();
    if (res2.status !== 200) {
      throw new Error(`Error: request failed with HTTP status ${res2.status}: ${res2.body}`);
    }
    upClasses.forEach((c_id) => {
      const c = classes.find((c) => c.id === c_id);
      if (c) {
        c['running'] = true;
      }
    });
    return classes;
  } catch (err) {
    console.error(err);
    alert(err instanceof Error ? err.message : err);
  }
}
