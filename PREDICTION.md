# Prediction

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

## Result

### No Prediction

- an apple = 66
- The quick brown fox jumps over the lazy dog. = 481
- The weather forecast predicts rain with a chance of thunderstorms = 655
- Please send me the latest sales report by the end of the day = 555
- I'm interested in learning more about machine learning and artificial intelligence = 719
- The sun sets in the west, casting a warm, golden glow over the horizon = 727
- She played a beautiful melody on her violin, filling the room with enchanting music. = 804
- The scientist conducted experiments to prove his groundbreaking theory. = 780
- He embarked on a journey to explore the uncharted wilderness. = 604
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 704
- The chef prepared a delicious gourmet meal that delighted the guests. = 623

Total Score = 6718

### Letter Prediction

- an apple = 20
- The quick brown fox jumps over the lazy dog. = 243
- The weather forecast predicts rain with a chance of thunderstorms = 436
- Please send me the latest sales report by the end of the day = 276
- I'm interested in learning more about machine learning and artificial intelligence = 202
- The sun sets in the west, casting a warm, golden glow over the horizon = 366
- She played a beautiful melody on her violin, filling the room with enchanting music. = 445
- The scientist conducted experiments to prove his groundbreaking theory. = 271
- He embarked on a journey to explore the uncharted wilderness. = 345
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 342
- The chef prepared a delicious gourmet meal that delighted the guests. = 287

Total Score = 3233

### Frequency

- an apple = 49
- The quick brown fox jumps over the lazy dog. = 426
- The weather forecast predicts rain with a chance of thunderstorms = 432
- Please send me the latest sales report by the end of the day = 343
- I'm interested in learning more about machine learning and artificial intelligence = 459
- The sun sets in the west, casting a warm, golden glow over the horizon = 458
- She played a beautiful melody on her violin, filling the room with enchanting music. = 597
- The scientist conducted experiments to prove his groundbreaking theory. = 489
- He embarked on a journey to explore the uncharted wilderness. = 432
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 419
- The chef prepared a delicious gourmet meal that delighted the guests. = 449

Total Score = 4553

### Word and Letter Prediction

- an apple = 35
- The quick brown fox jumps over the lazy dog. = 292
- The weather forecast predicts rain with a chance of thunderstorms = 483
- Please send me the latest sales report by the end of the day = 336
- I'm interested in learning more about machine learning and artificial intelligence = 264
- The sun sets in the west, casting a warm, golden glow over the horizon = 434
- She played a beautiful melody on her violin, filling the room with enchanting music. = 469
- The scientist conducted experiments to prove his groundbreaking theory. = 337
- He embarked on a journey to explore the uncharted wilderness. = 390
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 406
- The chef prepared a delicious gourmet meal that delighted the guests. = 347

Total Score = 3793

### Word, Letter, Frequency

- an apple = 41
- The quick brown fox jumps over the lazy dog. = 286
- The weather forecast predicts rain with a chance of thunderstorms = 330
- Please send me the latest sales report by the end of the day = 255
- I'm interested in learning more about machine learning and artificial intelligence = 241
- The sun sets in the west, casting a warm, golden glow over the horizon = 364
- She played a beautiful melody on her violin, filling the room with enchanting music. = 402
- The scientist conducted experiments to prove his groundbreaking theory. = 299
- He embarked on a journey to explore the uncharted wilderness. = 291
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 314
- The chef prepared a delicious gourmet meal that delighted the guests. = 320

Total Score = 3143

### Word Prediction

- an apple = 81
- The quick brown fox jumps over the lazy dog. = 475
- The weather forecast predicts rain with a chance of thunderstorms = 599
- Please send me the latest sales report by the end of the day = 460
- I'm interested in learning more about machine learning and artificial intelligence = 537
- The sun sets in the west, casting a warm, golden glow over the horizon = 661
- She played a beautiful melody on her violin, filling the room with enchanting music. = 556
- The scientist conducted experiments to prove his groundbreaking theory. = 618
- He embarked on a journey to explore the uncharted wilderness. = 544
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 656
- The chef prepared a delicious gourmet meal that delighted the guests. = 498

Total Score = 5685

### Apple Word Prediction Only

- an apple = 45
- The quick brown fox jumps over the lazy dog. = 400
- The weather forecast predicts rain with a chance of thunderstorms = 212
- Please send me the latest sales report by the end of the day = 273
- I'm interested in learning more about machine learning and artificial intelligence = 387
- The sun sets in the west, casting a warm, golden glow over the horizon = 471
- She played a beautiful melody on her violin, filling the room with enchanting music. = 365
- The scientist conducted experiments to prove his groundbreaking theory. = 343
- He embarked on a journey to explore the uncharted wilderness. = 229
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 445
- The chef prepared a delicious gourmet meal that delighted the guests. = 334

Total Score = 3504

### Apple, Word, Letter

- an apple = 25
- The quick brown fox jumps over the lazy dog. = 245
- The weather forecast predicts rain with a chance of thunderstorms = 191
- Please send me the latest sales report by the end of the day = 244
- I'm interested in learning more about machine learning and artificial intelligence = 223
- The sun sets in the west, casting a warm, golden glow over the horizon = 337
- She played a beautiful melody on her violin, filling the room with enchanting music. = 313
- The scientist conducted experiments to prove his groundbreaking theory. = 210
- He embarked on a journey to explore the uncharted wilderness. = 196
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 287
- The chef prepared a delicious gourmet meal that delighted the guests. = 242

Total Score = 2513

### Apple, Word, Letter, Frequency

- an apple = 25
- The quick brown fox jumps over the lazy dog. = 245
- The weather forecast predicts rain with a chance of thunderstorms = 191
- Please send me the latest sales report by the end of the day = 244
- I'm interested in learning more about machine learning and artificial intelligence = 223
- The sun sets in the west, casting a warm, golden glow over the horizon = 337
- She played a beautiful melody on her violin, filling the room with enchanting music. = 313
- The scientist conducted experiments to prove his groundbreaking theory. = 210
- He embarked on a journey to explore the uncharted wilderness. = 196
- The ancient castle stood atop the hill, shrouded in legends and mysteries. = 287
- The chef prepared a delicious gourmet meal that delighted the guests. = 242

Total Score = 2513

## Totals

- No Prediction: 6718
- Word Prediction: 5685
- Frequency: 4553
- Word and Letter Prediction: 3793
- Apple Word Prediction: 3504
- Letter Prediction: 3233
- Word, Letter, Frequency: 3143
- Apple, Word, Letter: 2513
- Apple, Word, Letter, Frequency: 2513
