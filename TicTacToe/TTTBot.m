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
@property (nonatomic, strong) NSString *botTTTSymbol;         //Generic "X" and "O" are considered to be used.
@property (nonatomic, strong) NSString *playerTTTSymbol;
@property (nonatomic) BOOL botStartsTheGame;
@end

@implementation TTTBot

-(instancetype)init {
    self.playerTTTSymbol = kO;
    return [self initWithBotTTTSymbol:kX botStartsTheGame:YES];
}

-(instancetype)initWithBotTTTSymbol:(NSString *)symbol botStartsTheGame:(BOOL)botStartsTheGame{
    self = [super init];
    if (self) {
        self.botStartsTheGame = botStartsTheGame;
        self.botTTTSymbol = symbol;
        if ([self.botTTTSymbol isEqualToString:kO]) {
            self.playerTTTSymbol = kX;
        } else {
            self.playerTTTSymbol = kO;
        }
        
        self.tree = [NSMutableDictionary dictionary];
        NSDictionary *initialBoard = @{
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
        self.tree[kDepthKey] = @0;
        self.tree[kBoardKey] = initialBoard;
        self.tree[kPositionIndex] = nil;
        self.tree[kNextPossibleBoardsKey] = [self nextPossibleBoardsWithBoard:initialBoard depthLevel:@1];
        self.tree[kScoreKey] = [self scoreFromNextPossibleBoard:self.tree[kNextPossibleBoardsKey]
                                                          board:initialBoard
                                                     depthLevel:@1];
    }
    
    return self;
}

#pragma mark - Private Methods Below This Line

-(NSDictionary *)nextPossibleBoardsWithBoard:(NSDictionary *)parentBoard depthLevel:(NSNumber *)depthLevel {
    if ([self gameIsCompleteWithBoard:parentBoard]) {
        return nil;
    }
    
    NSMutableDictionary *availableBoards = [NSMutableDictionary dictionary];
    NSDictionary *emptyPositions = [self emptyPositionsWithBoard:parentBoard];
    [emptyPositions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary *eachBoard = [NSMutableDictionary dictionary];
        
        // Board: eachBoard represents a SINGLE branch from parent board.
        NSString *symbol = [self whoMadeTheMove:depthLevel];
        NSDictionary *board = [self markBoard:parentBoard positionIndex:key symbol:symbol];
        eachBoard[kDepthKey] = depthLevel;
        eachBoard[kBoardKey] = board;
        eachBoard[kPositionIndex] = key;
        
        // Children Boards:
        eachBoard[kNextPossibleBoardsKey] = [self nextPossibleBoardsWithBoard:board depthLevel:@(depthLevel.integerValue + 1)];
        
        // Score
        eachBoard[kScoreKey] = [self scoreFromNextPossibleBoard:eachBoard[kNextPossibleBoardsKey] board:board whoMadeTheMove:symbol];
        
        availableBoards[obj] = eachBoard;
    }];
    
    // availableBoards == eachBoard[kNextPossibleBoardsKey]
    return availableBoards;
}

-(NSNumber *)scoreFromNextPossibleBoard:(NSDictionary *)nextPossibleBoard board:(NSDictionary *)board whoMadeTheMove:(NSString *)whoMadeTheMove{
    if (!nextPossibleBoard) {
        //Get score of the board. Return that number.
        return [self scoreWithBoard:board whoMadeTheMove:whoMadeTheMove];
    }
    
    //Get the average score
    __block float score = 0;
    [nextPossibleBoard enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        score += [obj[kScoreKey] floatValue];
    }];
    score /= [nextPossibleBoard count];
    return @(score);
}

-(NSNumber *)scoreWithBoard:(NSDictionary *)board whoMadeTheMove:(NSString *)whoMadeTheMove{
    float score = 0.f;
    NSString *result = [self winnerWithBoard:board whoMadeTheMove:whoMadeTheMove];
    
    if ([result isEqualToString:self.botTTTSymbol]) {
        score = 1.f;
    } else if ([result isEqualToString:self.playerTTTSymbol]) {
        score = -1;
    }
    
    return @(score);
}

-(NSString *)winnerWithBoard:(NSDictionary *)board whoMadeTheMove:(NSString *)whoMadeTheMove{
    NSString *winner = nil;
    
    // If there's a winner.
    if ([self winningIndicesWithBoard:board]) {
        
        //Get who won.
        //If it's bot's turn, then it means that the round ended on bot's turn. Player made the winning move.
        winner = [whoMadeTheMove isEqualToString:self.botTTTSymbol] ? self.playerTTTSymbol : self.botTTTSymbol;
    }
    return winner;
}

-(BOOL)gameIsCompleteWithBoard:(NSDictionary *)board {
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

-(NSDictionary *)emptyPositionsWithBoard:(NSDictionary *)board {
    __block NSMutableDictionary *emptyIndices = [NSMutableDictionary dictionary];
    [board enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            emptyIndices[key] = key;
        }
    }];
    
    return emptyIndices;
}

-(NSString *)whoMadeTheMove:(NSNumber *)depthLevel {
    return [self itsBotsTurn:@(depthLevel.integerValue - 1)] ? self.botTTTSymbol : self.playerTTTSymbol;
}

-(NSDictionary *)markBoard:(NSDictionary *)board positionIndex:(NSNumber *)positionIndex symbol:(NSString *)symbol {
    NSMutableDictionary *newBoard = [board mutableCopy];
    [newBoard setObject:symbol forKey:positionIndex];
    return newBoard;
}

#pragma mark - Helper Methods

-(BOOL) itsBotsTurn:(NSNumber *)depthLevel {
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

-(NSArray<NSNumber *> *)winningIndicesWithBoard:(NSDictionary *)board {
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

#pragma mark - Ignore

-(NSInteger)nextMoveWithBoard:(NSDictionary *)board {
    return arc4random_uniform(8);
}

-(NSNumber *)maxScoreFromFirstGenerationChildren:(NSDictionary *)possibleBoards {
    if ([possibleBoards[kNextPossibleBoardsKey] isKindOfClass:[NSNull class]]) {
        return possibleBoards[kScoreKey];
    }
    
    //Scores are either -1, 0, or 1. Lowest is -1.
    float firstBiggestScore;
    NSArray *nextPossibleMoves = possibleBoards[kNextPossibleBoardsKey];
    
    for (int index = 0; index < [nextPossibleMoves count]; index++) {
        NSDictionary *eachPossibleMove = nextPossibleMoves[index];
        
        if (index == 0) {
            firstBiggestScore = [eachPossibleMove[kScoreKey] floatValue];
        } else if (firstBiggestScore > [eachPossibleMove[kScoreKey] floatValue]){
            firstBiggestScore = [eachPossibleMove[kScoreKey] floatValue];
        }
    }
    
    return @(firstBiggestScore);
}

-(NSNumber *)minScoreFromFirstGenerationChildren:(NSDictionary *)possibleBoards {
    if ([possibleBoards[kNextPossibleBoardsKey] isKindOfClass:[NSNull class]]) {
        return possibleBoards[kScoreKey];
    }
    
    //Scores are either -1, 0, or 1. Biggest is 1.
    float firstSmallestScore;
    NSArray *nextPossibleMoves = possibleBoards[kNextPossibleBoardsKey];
    
    for (int index = 0; index < [nextPossibleMoves count]; index++) {
        NSDictionary *eachPossibleMove = nextPossibleMoves[index];
        
        if (index == 0) {
            firstSmallestScore = [eachPossibleMove[kScoreKey] floatValue];
        } else if (firstSmallestScore < [eachPossibleMove[kScoreKey] floatValue]){
            firstSmallestScore = [eachPossibleMove[kScoreKey] floatValue];
        }
    }
    
    return @(firstSmallestScore);
}


@end

