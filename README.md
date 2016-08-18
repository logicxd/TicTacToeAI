# TicTacToeAI

Tic-Tac-Toe bot that will never lose, implemented with AI design MiniMax.

### Overview

* Built a Tic-Tac-Toe game for iPhone 4s.
* Made the bot with different implementations:
  1. Average score: the bot goes for the highest score available.
  2. Minimax score: the bot minimizes the player's score.
  3. Alpha-Beta pruning: Minimax with cut-offs to load the game faster.
  4. (To-Do) Rotations and reflections: Alpha-Beta pruning with even more cut-offs by using symmetry.

![TicTacToeAI With Alpha-Beta pruning](https://cloud.githubusercontent.com/assets/12219300/17762269/c57e3ca6-64c3-11e6-8409-a4868ee59d7e.gif)

<!-- ![TicTacToeAI With Alpha-Beta pruning](https://cloud.githubusercontent.com/assets/12219300/17762272/d5e007b4-64c3-11e6-909d-f1bd0a185003.gif) -->

## Creating the Bot

![TicTacToe Possible Moves Tree](https://cloud.githubusercontent.com/assets/12219300/17763574/5cbc0e22-64ce-11e6-95d7-2e4397cce8fb.jpg)

Photo taken from http://www.devx.com/dotnet/Article/34912

The first implementation of the bot was done by making all the possible moves from the start to the finish and adding how the board looks like to a tree.
Then, I added a variable to count just exactly how many boards are created, which turned out to be **986,410**.
I checked it by deriving a formula from the pattern `1 + 9 + (9) * 8 + (9 * 8) * 7 + ... + 9!` which is `1 + Summation(9!/K!) where K = 0 to K = 8`, getting us 986,410 boards!
So, the initial loading time was pretty long because there were waaaay too many boards, but we were happy to see that at least we have a working tree.
The tree looks exactly like the picture above.

Not all the possible moves are necessary because the game can end earlier if there is a winner.
So after adding a check to stop making boards when a winner is found, the amount of boards reduced to **549,945** and so did our initial loading time.

All the methods so far has been loading the entire tree at the initial load.
So with our method, it has a very long initial load but after the game is loaded, the bot moves instantly.

In order to make the initial load not so displeasing, [Alpha-Beta pruning](https://www.ocf.berkeley.edu/~yosenl/extras/alphabeta/alphabeta.html) technique was implemented with the Minimax algorithm.
Instead of checking for a winner like before, it checks for the scores that are given from the children tree and decides whether or not it needs to check other trees.
This reduced the amount of boards at initial load to **85,088**!
With this method, it was a faster initial load, with the downside of having to load every bot's turn, which wasn't bad because the number of boards needed to make for future moves are a lot smaller.

This is an overestimated table of the number of boards made with Alpha-Beta pruning at every round.

Round   |  # of boards
---     | ---
1       | 85,097
2       | ~22,000
3       | ~3,500
4       | ~1,000
5       | ~200
6       | ~70
7       | ~20
8       | ~5
9       | <= 1
Total   | **~111,000**

Here's a rough data of loading speed with each implementation run on iPhone 4s simulator on my MacBook.

Algorithm  | # of boards  |  Initial loading speed (seconds) | 1st round loading speed (seconds) | 2nd round loading speed (seconds)
---        | ---          | ---                              | ---                               | ---
All possible moves  | 986,410 |  15 s | 0 s | 0 s
All possible moves w/ checks for winner  | 549,945 | 9 s| 0 s | 0 s
Alpha-Beta pruning | 111,000 | 0 s | 1.5 s | 0.4 s


### Scoring the Bot



---

### Acknowledgements
My mentor [Rey](https://github.com/reygonzales) for guiding us through the assignment. This assignment was done together with  [Alaric](https://github.com/AlaricGonzales) at our internship at PlanChat.
