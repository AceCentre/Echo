# Echo - Auditory Scanning

## Default Behaviour

After each letter you type out: read back the current word one charcter at a time. Prefix it with 'Current word'

After each word read out the current sentence. Prefix it with 'current sentence'

The prefixes should be toggleable in the settings but lets keep them on by default

## Prediction

We want to evaluate our prediction so that we can make sure any changes we make improve prediction. To do that we will measure hwo many 'moves' it would take to spell out a set of random sentences. The less moves the more efficient. This is not a perfect way to measure but its useful for a baseline.

Sentences:

1. "The quick brown fox jumps over the lazy dog"
2. "The weather forecast predicts rain with a chance of thunderstorms"
3. "Please send me the latest sales report by the end of the day"
4. "I'm interested in learning more about machine learning and artificial intelligence"
5. "The sun sets in the west, casting a warm, golden glow over the horizon"
6. "She played a beautiful melody on her violin, filling the room with enchanting music."
7. "The scientist conducted experiments to prove his groundbreaking theory."
8. "He embarked on a journey to explore the uncharted wilderness."
9. "The ancient castle stood atop the hill, shrouded in legends and mysteries."
10. "The chef prepared a delicious gourmet meal that delighted the guests."

| Method                                                                      | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   | 9   | 10  |
| --------------------------------------------------------------------------- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| No Prediction                                                               |     |     |     |     |     |     |
| Dictionary Based Letter Prediction Only                                     |     |     |     |     |     |     |     |     |     |     |
| Dictionary Based Word Prediction Only                                       |     |     |     |     |     |     |     |     |     |     |
| Dictionary Based Word and Letter Prediction                                 |     |     |     |     |     |     |     |     |     |     |
| Dictionary Based Word and Letter Prediction combined with Apples Prediction |     |     |     |     |     |     |     |     |     |     |
