# TicTacToeAI

Tic-Tac-Toe bot that will never lose, implemented with AI design MiniMax.

### Overview

* Built a Tic-Tac-Toe game for iPhone 4s.
* Made the bot with different implementations:
  1. Average score: the bot goes for the highest score available.
  2. Minimax score: the bot minimizes the player's score.
  3. Alpha-Beta pruning: Minimax with cut-offs to load the game faster.
  4. Rotations and reflections: Alpha-Beta pruning with even more cut-offs by using symmetry.

![TicTacToeAI With Alpha-Beta pruning](https://cloud.githubusercontent.com/assets/12219300/17745811/2886d658-6462-11e6-9b8c-235e978cefea.gif)

### Creating the Bot

The first implementation of the bot was done by making **ALL** the possible moves from the start to the finish and adding them to a tree. This created **A LOT OF** moves which was 1 + Summation(9!/K!) where K = 0 to K = 8, summing to **986,410 boards**! The initial loading time for this was pretty long because there were waaaay too many boards, but we were happy to see that at least we have a working tree.

Not all the possible moves are necessary because **the game can end earlier if there is a winner**. So after adding a check to get the winner and stopping the board making process, the amount of boards reduced to **549,945**. This reduced the initial load of the bot to about 9 seconds on average.



---

### Acknowledgements
My mentor [Rey](https://github.com/reygonzales) for guiding us through the assignment. This assignment was done together with  [Alaric](https://github.com/AlaricGonzales) at our internship at PlanChat.
