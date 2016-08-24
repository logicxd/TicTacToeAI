# TicTacToeAI

Tic-Tac-Toe bot that will never lose, implemented with AI design MiniMax.

### Overview

* Built a Tic-Tac-Toe game for iPhone 4s.
* Made the bot with different implementations:
  1. Average score: the bot goes for the highest score available.
  2. MiniMax score: the bot minimizes the player's score.
  3. Alpha-Beta pruning: MiniMax with cut-offs to load the game faster.
  4. (To-Do) Rotations and reflections: Alpha-Beta pruning with even more cut-offs by using symmetry.

![TicTacToeAI With Alpha-Beta pruning](https://cloud.githubusercontent.com/assets/12219300/17765188/1ef01e52-64d9-11e6-8e27-c3e46e20d01a.gif)

<!-- ![TicTacToeAI With Alpha-Beta pruning](https://cloud.githubusercontent.com/assets/12219300/17762272/d5e007b4-64c3-11e6-909d-f1bd0a185003.gif) -->

## Creating the Bot

![TicTacToe Possible Moves Tree](https://cloud.githubusercontent.com/assets/12219300/17765292/c83650a8-64d9-11e6-8039-93aff9365229.jpg)

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

In order to make the initial load not so displeasing, [Alpha-Beta pruning](https://www.ocf.berkeley.edu/~yosenl/extras/alphabeta/alphabeta.html) technique was implemented with the MiniMax algorithm.
Instead of checking for a winner like before, it checks for the scores that are given from the children tree and decides whether or not it needs to check other trees.
This reduced the amount of boards at initial load to **85,088**!
With this method, it was a faster initial load, with the downside of having to load every bot's turn, which wasn't bad because the number of boards needed to make for future moves are a lot smaller.

This is an overestimated number of boards made with Alpha-Beta pruning at every round.

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

Here's a rough comparison between each implementation with the iPhone 4s simulator on my MacBook.

Algorithm  | # of boards  |  Initial loading speed (seconds) | 1st round loading speed (seconds) | 2nd round loading speed (seconds)
---        | ---          | ---                              | ---                               | ---
All possible moves  | 986,410 |  15 s | 0 s | 0 s
All possible moves w/ checks for winner  | 549,945 | 9 s| 0 s | 0 s
Alpha-Beta pruning | 111,000 | 0 s | 1.5 s | 0.4 s

## Scoring the Bot

![Scoring picture](https://cloud.githubusercontent.com/assets/12219300/17835933/80bf37bc-6736-11e6-9aca-f5612ccd4573.jpg)

Photo taken from http://users.sussex.ac.uk/~christ/crs/kr-ist/lec05a.html

We have a tree where each depth represents a move made on the board.
The scores are calculated at the leaf nodes when the game ends, returning a score of 1 if the bot wins, 0 for a tie, and -1 for a loss. This is known as the **static score**.
Then the scores are passed to the parents until it reached the root node.

#### ~~Average Score~~

![Average score error](https://cloud.githubusercontent.com/assets/12219300/17845944/723258d6-67fa-11e6-855c-02f494d717d2.jpeg)

Photo credit: [Alaric](https://github.com/AlaricGonzales)

The first idea was to select the highest average scores from the children nodes to get the best possible chance of winning.
The idea was that the children with the higher average score will lead to higher chance of winning.
While this is true, **it didn't create an unbeatable Tic-Tac-Toe**.
It made the bot too focused on selecting the moves that leads it to higher chances of victory.
What this means is that, even if the opponent is about to win in the next turn, the bot will continue to go towards a move where it *CAN* lead to higher chances of winning instead of blocking.
Because the bot doesn't block the opponent's moves, the bot often loses and was not unbeatable as we wanted it to be.

#### MiniMax Score

MiniMax is the idea of minimizing the opponent's maximum score.
It goes like this:
 * Build the game tree. The static scores are determined at the leaf nodes.
 * Then start traversing backwards to the top of the tree.
 * The bot node will pick the highest score from children.
 * The player node will pick the smallest score from children.

So the bot will pick moves that will give the opponent the lowest score possible, thus maximizing the bot's own score.
By using this method, the bot will continuously block the opponent's moves, preventing them from winning, while also going for any possible victories.
As a result, using the MiniMax algorithm allowed us to create an unbeatable bot in Tic-Tac-Toe.

#### Alpha-Beta Pruning

Alpha-Beta pruning is a way of reducing the amount of search by not exploring the child nodes that will never be searched.
This is done by having two variables with given names *alpha* and *beta* to keep track of scores for alpha-cutoff and beta-cutoff.
Chris Thronton explains in [his lecture](http://users.sussex.ac.uk/%7Echrist/crs/kr-ist/lec05a.html):
> * Applying an **alpha-cutoff** means we stop search of a particular branch because we see that we already have a better opportunity elsewhere.
> * Applying a **beta-cutoff** means we stop search of a particular branch because we see that the opponent already has a better opportunity elsewhere.

So where does Alpha-Beta pruning come in?
As an example, let's say it's the bot's turn and that it has two children.

 1. Bot's turn, `root` node: Wants to pick the highest score from children. It will populate the first child node, call it `A`, and get it's score. Next, it will have to find the score for the second child, call it `B`.

 2. Opponent's turn, node `B`: Wants to pick the lowest score from children. It has 3 child `B1, B2, B3`. It wants to iterate through each one of those to get the lowest score *BUT* it also knows that **the biggest score that the `root` node has found is from node `A`**. So we pass that biggest score to each of the children.

 3. Bot's turn, node `B1`: Wants to pick the highest score. Re-iteration of step 1 and returns the biggest score to node `B`.

 4. Opponent's turn, back to node `B`: Now we have the score of `B1`. If the score of `B1` is smaller than the score from `root` node, then it doesn't have to search child nodes `B2` and  `B3`. The node `B` will pick a score from `B1` or smaller and the `root` node will pick a score bigger than score from `B1`. Because of that, the `root` node will end up never picking from the node `B`.

So cutoffs happen when **alpha >= beta**.
Alpha is the biggest score that the `root` node might pick and beta is the smallest score that the `B` might pick.
Then `B1, B2, B3` can sets the highest alpha.
`B` compares if `B1` alpha is bigger than or equal to `B` beta and decides to do a cutoff if it does.

This [Alpha-Beta pruning practice](http://inst.eecs.berkeley.edu/~cs61b/fa14/ta-materials/apps/ab_tree_practice/) is a very neat tool that can help visualize how the process goes.

---

### Acknowledgements
My mentor [Rey](https://github.com/reygonzales) for guiding us through the assignment. This assignment was done together with [Alaric](https://github.com/AlaricGonzales) at our internship at PlanChat.
