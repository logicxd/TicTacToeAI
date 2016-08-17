//
//  TTTBot.m
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//
//  Theoretical Computation: (First try)
//  1 + 9 + 9 * 8 + (9 * 8) * 7 + ... + 9!
//  1 + Summation(9!/K!) where K == 0 until K == 8
//  1 + 986409 == 986410 (Same as actual computation)
//
//  Number of boards: 549,945. No alpha-beta pruning. Stops once a winner is found.
//  Time elasped (in seconds): 9.668, 9.819, 9.435
//
//
//

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
@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong, readwrite) NSMutableDictionary *playingBoard;
@property (nonatomic, readwrite) NSInteger numberOfRoundsLeft;
@property (nonatomic, strong) NSDictionary *currentTreePointer;
@end

@implementation TTTBot

#pragma mark - Visible Methods

- (instancetype)init {
    return [self initWithBotSymbol:kX playerSymbol:kO botStartsTheGame:NO];
}

- (instancetype)initWithBotSymbol:(NSString *)botSymbol playerSymbol:(NSString *)playerSymbol botStartsTheGame:(BOOL)botStartsTheGame {
    self = [super init];
    if (self) {
        NSLog(@"Bot is loading...");
        self.tree = [NSMutableDictionary dictionary];
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
        self.currentTreePointer = self.tree;
        self.numberOfRoundsLeft = 9;
        
        self.tree[kDepthKey] = @0;
        self.tree[kBoardKey] = [self.emptyBoard copy];
        self.tree[kPositionIndex] = nil;
        self.tree[kNextPossibleBoardsKey] = [self nextPossibleBoardsWithBoard:[self.emptyBoard copy] depthLevel:@1];
        // Average Score
        //        self.tree[kScoreKey] = [self scoreFromNextPossibleBoard:self.tree[kNextPossibleBoardsKey]
        //                                                          board:initialBoard
        //                                                     botDidMove:self.botStartsTheGame ? YES : NO];
        // Minimax Score
        self.tree[kScoreKey] = [self miniMax:self.tree[kNextPossibleBoardsKey]
                                       board:[self.emptyBoard copy]
                                  botDidMove:self.botStartsTheGame ? YES : NO];
    }
    NSLog(@"Bot finished loading...");
    return self;
}

- (NSInteger)botMovedAtIndex {
    // Get the highest possible score for bot.
    NSDictionary *temporaryPointer = self.currentTreePointer[kNextPossibleBoardsKey];
    __block NSInteger biggestScore = NSIntegerMin;    
    __block BOOL setScore = NO;
    [temporaryPointer enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull board, BOOL * _Nonnull stop) {
        NSInteger score = [board[kScoreKey] integerValue];
        
        if (biggestScore < score || !setScore) {
            biggestScore = score;
            setScore = YES;
        }
    }];
    
    // Randomize all the possible moves for the highest score.
    __block NSMutableArray *bestMoves = [NSMutableArray arrayWithCapacity:9];
    [temporaryPointer enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull board, BOOL * _Nonnull stop) {
        NSInteger score = [board[kScoreKey] integerValue];

        if (biggestScore == score) {
            [bestMoves addObject:board];
        }
    }];
    
    // There must be at least one move and it must be bot's turn.
    if (bestMoves.count == 0 || [self botsTurnWithDepthLevel:@(9 - self.numberOfRoundsLeft + 1)]) {
        return -1;
    }
    
    // Get a random move
    NSDictionary *randomMove = bestMoves[arc4random_uniform(bestMoves.count)];
    NSInteger moveIndex = [randomMove[kPositionIndex] integerValue];
    
    // Make the move
    self.currentTreePointer = self.currentTreePointer[kNextPossibleBoardsKey][@(moveIndex)];
    self.playingBoard[@(moveIndex)] = self.botSymbol;
    self.numberOfRoundsLeft--;
    return moveIndex;
}

- (NSInteger)botMovedAtIndexWithPlayerMove:(NSInteger)index {
    NSInteger moveIndex = [self playerMovedAtIndex:index];
    if (moveIndex != -1) {
        moveIndex = [self botMovedAtIndex];
    }
    return moveIndex;
}

- (NSInteger)playerMovedAtIndex:(NSInteger)index {
    if (!self.currentTreePointer[kNextPossibleBoardsKey][@(index)]) {
        return -1;
    }
    
    self.currentTreePointer = self.currentTreePointer[kNextPossibleBoardsKey][@(index)];
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
    self.currentTreePointer = self.tree;
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
        
        availableBoards[obj] = eachBoard;
        
        count++;
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

