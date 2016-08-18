//
//  TTTBot.m
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//
//  Number of boards: 986,410 without stopping once winner is found.
//
//  Number of boards: 549,945. No alpha-beta pruning. Stops once a winner is found.
//  Time elasped (in seconds): 9.668, 9.819, 9.435
//
//  Number of boards on the first round: 85,097. With alpha-beta pruning.
//  2nd round: ~22,000.
//  3rd round: ~3,500.
//  4th round: ~1000.
//  5th round: ~200.
//  6th round: ~60.
//  7th round: ~20.
//  8th round: ~5;
//  9th round: <= 1;

#import "TTTBot.h"

static NSString *const kNextPossibleBoardsKey = @"kNextPossibleMovesKey";
static NSString *const kScoreKey = @"kScoreKey";
static NSString *const kBoardKey = @"kBoardKey";
static NSString *const kDepthKey = @"kDepthKey";
static NSString *const kPositionIndex = @"kPositionIndex";
static NSString *const kO = @"O";
static NSString *const kX = @"X";
static NSInteger count = 0;

@interface TTTBot()
@property (nonatomic, strong) const NSDictionary *emptyBoard;
@property (nonatomic, strong, readwrite) NSMutableDictionary *playingBoard;
@property (nonatomic, readwrite) NSInteger numberOfRoundsLeft;
@end

@implementation TTTBot

#pragma mark - Visible Methods

- (instancetype)init {
    return [self initWithBotSymbol:kX playerSymbol:kO botStartsTheGame:NO];
}

- (instancetype)initWithBotSymbol:(NSString *)botSymbol playerSymbol:(NSString *)playerSymbol botStartsTheGame:(BOOL)botStartsTheGame {
    self = [super init];
    if (self) {
//        NSLog(@"Bot is loading...");
        self.botSymbol = botSymbol;
        self.playerSymbol = playerSymbol;
        self.botStartsTheGame = botStartsTheGame;
        
        self.emptyBoard = @{
                            @0 : @0,
                            @1 : @1,
                            @2 : @2,
                            @3 : @3,
                            @4 : @4,
                            @5 : @5,
                            @6 : @6,
                            @7 : @7,
                            @8 : @8,
                            };
        self.playingBoard = [NSMutableDictionary dictionaryWithCapacity:9];
        self.numberOfRoundsLeft = 9;
    }
//    NSLog(@"Bot finished loading...");
    return self;
}

- (NSInteger)botMovedAtIndex {
    // Fill the board with the values that should be in.
    __block NSMutableDictionary *filledBoard = [self.emptyBoard mutableCopy];
    [self.playingBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        filledBoard[key]= obj;
    }];
    
    // Load alpha-beta scores.
    NSMutableDictionary *availableMoves = [NSMutableDictionary dictionary];
    NSDictionary *emptyPositions = [self emptyPositionsWithBoard:filledBoard];
    [emptyPositions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull positionIndex, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *board = [self markBoard:filledBoard positionIndex:positionIndex symbol:self.botSymbol];
        NSNumber *score = [self alphaBetaScoreWithBoard:board alpha:@(NSIntegerMin) beta:@(NSIntegerMax) depthLevel:@(9 - self.numberOfRoundsLeft) depthToStopAtInclusively:@(9)];
        
        availableMoves[positionIndex] = score;
        count++;
    }];
    
    // Get the highest possible score for bot.
    __block NSInteger biggestScore = NSIntegerMin;
    __block BOOL setScore = NO;
    [availableMoves enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger score = [obj integerValue];
        if (biggestScore < score || !setScore) {
            biggestScore = score;
            setScore = YES;
        }
    }];
    
    // Randomize all the possible moves for the highest score.
    __block NSMutableArray *bestMoves = [NSMutableArray arrayWithCapacity:9];
    [availableMoves enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger index = [key integerValue];
        NSInteger score = [obj integerValue];
        
        if (biggestScore == score) {
            [bestMoves addObject:@(index)];
        }
    }];
    
    // There must be at least one move and it must be bot's turn.
    if (bestMoves.count == 0 || [self botsTurnWithDepthLevel:@(9 - self.numberOfRoundsLeft + 1)]) {
        return -1;
    }
    
    // Get a random move
    NSInteger intKey = [bestMoves[arc4random_uniform(bestMoves.count)] integerValue];
    
    // Make the move
    NSLog(@"Count: %i", count);
    count = 0;
    self.playingBoard[@(intKey)] = self.botSymbol;
    self.numberOfRoundsLeft--;
    return intKey;
}

- (NSInteger)botMovedAtIndexWithPlayerMove:(NSInteger)index {
    NSInteger moveIndex = [self playerMovedAtIndex:index];
    
    // Fill the board with the values that should be in.
    __block NSMutableDictionary *filledBoard = [self.emptyBoard mutableCopy];
    
    [self.playingBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        filledBoard[key]= obj;
    }];
    
    if (moveIndex != -1 && ![self gameIsCompleteWithBoard:filledBoard]) {
        moveIndex = [self botMovedAtIndex];
    }
    return moveIndex;
}

- (NSInteger)playerMovedAtIndex:(NSInteger)index {
    if ([self.playingBoard[@(index)] isKindOfClass:[NSString class]]) {
        return -1;
    }
    
    self.playingBoard[@(index)] = self.playerSymbol;
    self.numberOfRoundsLeft--;
    return index;
}

- (BOOL)botsTurnInGame {
    BOOL botsTurn = NO;
    
    if (self.botStartsTheGame) {
        botsTurn = self.numberOfRoundsLeft % 2 == 1 ? YES : NO;
    } else {
        botsTurn = self.numberOfRoundsLeft % 2 == 0 ? YES : NO;
    }
    return botsTurn;
}

- (NSString *)checkForWinner {
    __block NSMutableDictionary *board = [self.emptyBoard mutableCopy];
    [self.playingBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        board[key]= obj;
    }];
    
    BOOL isItBotsTurn = [self botsTurnWithDepthLevel:@(9 - self.numberOfRoundsLeft + 1)];
    NSString *winner = [self winnerWithBoard:board botDidMove:isItBotsTurn];
    if (winner) {
        self.numberOfRoundsLeft = 0;
    }
    return winner;
}

- (void)restartGame {
    self.playingBoard = [NSMutableDictionary dictionaryWithCapacity:9];
    self.numberOfRoundsLeft = 9;
}

#pragma mark - Private Methods Below This Line

- (NSDictionary *)nextPossibleBoardsWithBoard:(NSDictionary *)parentBoard depthLevel:(NSNumber *)depthLevel {
    if ([self gameIsCompleteWithBoard:parentBoard]) {
        return nil;
    }
    
    NSMutableDictionary *availableBoards = [NSMutableDictionary dictionary];
    NSDictionary *emptyPositions = [self emptyPositionsWithBoard:parentBoard];
    [emptyPositions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary *eachBoard = [NSMutableDictionary dictionary];
        
        // Board: eachBoard represents a SINGLE branch from parent board.
        NSString *symbol = [self whoWillMove:depthLevel];
        NSDictionary *board = [self markBoard:parentBoard positionIndex:key symbol:symbol];
        eachBoard[kDepthKey] = depthLevel;
        eachBoard[kBoardKey] = board;
        eachBoard[kPositionIndex] = key;
        
        // Children Boards:
        eachBoard[kNextPossibleBoardsKey] = [self nextPossibleBoardsWithBoard:board depthLevel:@(depthLevel.integerValue + 1)];
        
        // Average Score
        //        eachBoard[kScoreKey] = [self scoreFromNextPossibleBoard:eachBoard[kNextPossibleBoardsKey]
        //                                                          board:board
        //                                                     botDidMove:[symbol isEqualToString:self.botTTTSymbol] ? YES : NO ];
        
        // Minimax Score
        eachBoard[kScoreKey] = [self miniMax:eachBoard[kNextPossibleBoardsKey]
                                       board:board
                                  botDidMove:[symbol isEqualToString:self.botSymbol] ? YES : NO ];
        
        count++;
        availableBoards[obj] = eachBoard;
    }];
    
    // availableBoards == eachBoard[kNextPossibleBoardsKey]
    return availableBoards;
}

- (BOOL)gameIsCompleteWithBoard:(NSDictionary *)board {
    if ([self winningIndicesWithBoard:board]) {
        return YES;
    }
    
    __block BOOL boardIsComplete = YES;
    [board enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            boardIsComplete = NO;
            *stop = YES;
        }
    }];
    
    return boardIsComplete;
}

- (NSDictionary *)emptyPositionsWithBoard:(NSDictionary *)board {
    __block NSMutableDictionary *emptyIndices = [NSMutableDictionary dictionary];
    [board enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            emptyIndices[key] = key;
        }
    }];
    
    return emptyIndices;
}

- (NSString *)whoWillMove:(NSNumber *)depthLevel {
    return [self botsTurnWithDepthLevel:@(depthLevel.integerValue - 1)] ? self.botSymbol : self.playerSymbol;
}

- (NSDictionary *)markBoard:(NSDictionary *)board positionIndex:(NSNumber *)positionIndex symbol:(NSString *)symbol {
    NSMutableDictionary *newBoard = [board mutableCopy];
    [newBoard setObject:symbol forKey:positionIndex];
    return newBoard;
}

#pragma mark - Alpha Beta Score

- (NSNumber *)alphaBetaScoreWithBoard:(NSDictionary *)parentBoard alpha:(NSNumber *)alpha beta:(NSNumber *)beta depthLevel:(NSNumber *)depthLevel depthToStopAtInclusively:(NSNumber *)depthToStopAt{
    BOOL botWillMove = NO;
    if ([[self whoWillMove:depthLevel] isEqualToString:[self botSymbol]]) {
        botWillMove = YES;
    }
    
    if ([self gameIsCompleteWithBoard:parentBoard] || [depthLevel isEqualToNumber:depthToStopAt]) {
        return [self scoreWithBoard:parentBoard botDidMove:botWillMove ? NO : YES];
    }
    
    __block NSNumber *score;
    __block NSNumber *blockAlpha = alpha;
    __block NSNumber *blockBeta = beta;
    NSDictionary *emptyPositions = [self emptyPositionsWithBoard:parentBoard];
    
    // Move has been made. Now we will get the score accordingly.
    if (botWillMove) {
        // Bot made the move. Look for higher score.
        [emptyPositions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // Board: eachBoard represents a SINGLE branch from parent board.
            NSString *symbol = botWillMove ? self.botSymbol : self.playerSymbol;
            NSDictionary *board = [self markBoard:parentBoard positionIndex:key symbol:symbol];
            score = [self alphaBetaScoreWithBoard:board alpha:blockAlpha beta:blockBeta depthLevel:@([depthLevel integerValue] + 1) depthToStopAtInclusively:depthToStopAt];
            
            // Bot made the move. Look for higher score.
            if ([score integerValue] > [blockAlpha integerValue]) {
                blockAlpha = score;
            }
            
            if ([blockAlpha integerValue] >= [blockBeta integerValue]) {
                *stop = YES;
            }
            count++;
        }];
        
        // This is the bot's best move.
        return blockAlpha;
    } else {
        // Player made the move. Look for the worse scorer that player can get us.
        [emptyPositions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            // Board: eachBoard represents a SINGLE branch from parent board.
            NSString *symbol = botWillMove ? self.botSymbol : self.playerSymbol;
            NSDictionary *board = [self markBoard:parentBoard positionIndex:key symbol:symbol];
            score = [self alphaBetaScoreWithBoard:board alpha:alpha beta:beta depthLevel:@([depthLevel integerValue] + 1) depthToStopAtInclusively:depthToStopAt];
            
            // Player made the move. Look for the worse scorer that player can get us.
            if ([score integerValue] < [blockBeta integerValue]) {
                blockBeta = score;
            }
            
            if ([blockAlpha integerValue] >= [blockBeta integerValue]) {
                *stop = YES;
            }
            count++;
        }];
        
        // This is the player's worst move.
        return blockBeta;
    }
}

#pragma mark - miniMax Score

- (NSNumber *)miniMax:(NSDictionary *)nextPossibleBoard board:(NSDictionary *)board botDidMove:(BOOL)botDidMove {
    if (!nextPossibleBoard) {
        //Get score of the board. Return that number.
        return [self scoreWithBoard:board botDidMove:botDidMove];
    }
    
    NSNumber *score;
    if (botDidMove) {
        score = [self minScoreFromNextPossibleBoard:nextPossibleBoard];
    } else {
        score = [self maxScoreFromNextPossibleBoard:nextPossibleBoard];
    }
    
    return score;
}

- (NSNumber *)maxScoreFromNextPossibleBoard:(NSDictionary *)nextPossibleBoard {
    // Returns: -1, 0, 1 if there are valid elements. -99 if there's no objects in element.
    
    if ([nextPossibleBoard count] == 0) {
        NSLog(@"nextPossibleBoard objects with no element at line: %d", __LINE__);
    }
    
    __block NSInteger maximumScore = -99;
    __block BOOL isFirstNumber = YES;
    
    [nextPossibleBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger score = [obj[kScoreKey] integerValue];
        if (isFirstNumber) {
            maximumScore = score;
            isFirstNumber = NO;
        } else if (maximumScore < score) {
            maximumScore = score;
        }
    }];
    
    return @(maximumScore);
}

- (NSNumber *)minScoreFromNextPossibleBoard:(NSDictionary *)nextPossibleBoard {
    // Precondition: nextPossibleBoard != nil
    // Returns: -1, 0, 1 if there are valid elements. 99 if there's no objects in element.
    
    if ([nextPossibleBoard count] == 0) {
        NSLog(@"nextPossibleBoard objects with no element at line: %d", __LINE__);
    }
    
    __block NSInteger minimumScore = 99;
    __block BOOL isFirstNumber = YES;
    
    [nextPossibleBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger score = [obj[kScoreKey] integerValue];
        if (isFirstNumber) {
            minimumScore = score;
            isFirstNumber = NO;
        } else if (minimumScore > score) {
            minimumScore = score;
        }
    }];
    
    return @(minimumScore);
}

#pragma mark - Average Score

- (NSNumber *)scoreFromNextPossibleBoard:(NSDictionary *)nextPossibleBoard board:(NSDictionary *)board botDidMove:(BOOL)botDidMove {
    if (!nextPossibleBoard) {
        //Get score of the board. Return that number.
        return [self scoreWithBoard:board botDidMove:botDidMove];
    }
    
    //Get the average score
    __block float score = 0;
    [nextPossibleBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        score += [obj[kScoreKey] floatValue];
    }];
    score /= [nextPossibleBoard count];
    return @(score);
}

- (NSNumber *)scoreWithBoard:(NSDictionary *)board botDidMove:(BOOL)botDidMove {
    NSInteger score = 0;
    NSString *result = [self winnerWithBoard:board botDidMove:botDidMove];
    
    if ([result isEqualToString:self.botSymbol]) {
        score = 1;
    } else if ([result isEqualToString:self.playerSymbol]) {
        score = -1;
    }
    
    return @(score);
}

- (NSString *)winnerWithBoard:(NSDictionary *)board botDidMove:(BOOL)botDidMove {
    NSString *winner = nil;
    
    // If there's a winner.
    if ([self winningIndicesWithBoard:board]) {
        
        // The person who made the move wins
        winner = botDidMove ? self.botSymbol : self.playerSymbol;
    }
    return winner;
}

#pragma mark - Helper Methods

- (BOOL) botsTurnWithDepthLevel:(NSNumber *)depthLevel {
    BOOL isItBotsTurn = NO;
    
    //Even
    if (depthLevel.integerValue % 2 == 0) {
        
        if (self.botStartsTheGame) {
            isItBotsTurn = YES;
        }
    } else {
        //Odd
        if (!self.botStartsTheGame) {
            isItBotsTurn = YES;
        }
    }
    
    return isItBotsTurn;
}

- (NSArray<NSNumber *> *)winningIndicesWithBoard:(NSDictionary *)board {
    if (board[@0] == board[@4] && board[@4] == board[@8]) {
        NSArray<NSNumber *> *winningIndices = @[@0,@4,@8];
        return winningIndices;
    }
    if (board[@2] == board[@4] && board[@4] == board[@6]) {
        NSArray<NSNumber *> *winningIndices = @[@2,@4,@6];
        return winningIndices;
    }
    if (board[@0] == board[@1] && board[@1] == board[@2]) {
        NSArray<NSNumber *> *winningIndices = @[@0,@1,@2];
        return winningIndices;
    }
    if (board[@3] == board[@4] && board[@4] == board[@5]) {
        NSArray<NSNumber *> *winningIndices = @[@3,@4,@5];
        return winningIndices;
    }
    if (board[@6] == board[@7] && board[@7] == board[@8]) {
        NSArray<NSNumber *> *winningIndices = @[@6,@7,@8];
        return winningIndices;
    }
    if (board[@0] == board[@3] && board[@3] == board[@6]) {
        NSArray<NSNumber *> *winningIndices = @[@0,@3,@6];
        return winningIndices;
    }
    if (board[@1] == board[@4] && board[@4] == board[@7]) {
        NSArray<NSNumber *> *winningIndices = @[@1,@4,@7];
        return winningIndices;
    }
    if (board[@2] == board[@5] && board[@5] == board[@8]) {
        NSArray<NSNumber *> *winningIndices = @[@2,@5,@8];
        return winningIndices;
    }
    
    return nil;
}

@end

