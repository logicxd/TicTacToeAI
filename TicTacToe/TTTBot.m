//
//  TTTBot.m
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import "TTTBot.h"

static NSString *const kNextPossibleBoardsKey = @"kNextPossibleMovesKey";
static NSString *const kScoreKey = @"kScoreKey";
static NSString *const kBoardKey = @"kBoardKey";
static NSString *const kDepthKey = @"kDepthKey";
static NSString *const kPositionIndex = @"kPositionIndex";
static NSString *const kO = @"O";
static NSString *const kX = @"X";

@interface TTTBot()
@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong) NSString *botTTTSymbol;
@property (nonatomic, strong) NSString *playerTTTSymbol;
@property (nonatomic) BOOL botStartsTheGame;

@property (nonatomic, strong) NSDictionary *emptyBoard;
@property (nonatomic, strong, readwrite) NSMutableDictionary *playingBoard;
@property (nonatomic, strong) NSDictionary *treeCursor;
@property (nonatomic, readwrite) NSInteger numberOfRoundsLeft;
@end

@implementation TTTBot

#pragma mark - Visible Methods

- (instancetype)init {
    return [self initWithBotTTTSymbol:kX playerTTTSymbol:kO botStartsTheGame:NO];
}

- (instancetype)initWithBotTTTSymbol:(NSString *)botSymbol playerTTTSymbol:(NSString *)playerSymbol botStartsTheGame:(BOOL)botStartsTheGame {
    self = [super init];
    if (self) {
        self.tree = [NSMutableDictionary dictionary];
        self.botTTTSymbol = botSymbol;
        self.playerTTTSymbol = playerSymbol;
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
        self.treeCursor = self.tree;
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
    
    return self;
}

- (NSInteger)botMovedAtIndex {
    self.treeCursor = self.treeCursor[kNextPossibleBoardsKey];
    
    __block NSInteger moveIndex = NSIntegerMin;
    __block BOOL isFirstNumber = YES;
    [self.treeCursor enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger score = [obj[kScoreKey] integerValue];
        
        if (isFirstNumber) {
            moveIndex = score;
            isFirstNumber = NO;
        } else if (moveIndex < score) {
            moveIndex = score;
        }
    }];
    
    self.numberOfRoundsLeft--;
    return moveIndex;
}

- (NSInteger)playerMovedAtIndex:(NSInteger)index {
    self.playingBoard[@(index)] = self.playerTTTSymbol;
    self.treeCursor = self.treeCursor[kNextPossibleBoardsKey][@(index)];
    self.numberOfRoundsLeft--;
    return index;
}

- (NSString *)checkForWinner {
    BOOL isItBotsTurn = [self itsBotsTurn:@(9 - self.numberOfRoundsLeft)];
    return [self winnerWithBoard:self.playingBoard botDidMove:isItBotsTurn];
}

- (void)resetBoard {
    self.playingBoard = [self.emptyBoard copy];
    self.treeCursor = self.tree;
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
                                 botDidMove:[symbol isEqualToString:self.botTTTSymbol] ? YES : NO ];
        
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
    return [self itsBotsTurn:@(depthLevel.integerValue - 1)] ? self.botTTTSymbol : self.playerTTTSymbol;
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
    
    if ([result isEqualToString:self.botTTTSymbol]) {
        score = 1;
    } else if ([result isEqualToString:self.playerTTTSymbol]) {
        score = -1;
    }
    
    return @(score);
}

- (NSString *)winnerWithBoard:(NSDictionary *)board botDidMove:(BOOL)botDidMove {
    NSString *winner = nil;
    
    // If there's a winner.
    if ([self winningIndicesWithBoard:board]) {
        
        // The person who made the move wins
        winner = botDidMove ? self.botTTTSymbol : self.playerTTTSymbol;
    }
    return winner;
}

#pragma mark - Helper Methods

- (BOOL) itsBotsTurn:(NSNumber *)depthLevel {
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

