//
//  TTTBot.m
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import "TTTBot.h"

static NSString *const kNextPossibleMovesKey = @"kNextPossibleMovesKey";
static NSString *const kScoreKey = @"kScoreKey";
static NSString *const kBoardKey = @"kBoardKey";
static NSString *const kDepthKey = @"kDepthKey";
static NSString *const kO = @"O";
static NSString *const kX = @"X";

//static const NSUInteger MAX_NUMBER_OF_ROUNDS = 9;

@interface TTTBot()
@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong) NSString *botTTTSymbol;         //Generic "X" and "O" are considered to be used.
@property (nonatomic, strong) NSString *playerTTTSymbol;
@property (nonatomic) BOOL botStartsTheGame;
@property  (nonatomic) NSUInteger amountOfBoardsMade;
@property  (nonatomic) NSUInteger numberOfComparisons;
@end

@implementation TTTBot

-(instancetype)init {
    self.playerTTTSymbol = kX;
    return [self initWithBotTTTSymbol:kO botStartsTheGame:YES];
}

-(instancetype)initWithBotTTTSymbol:(NSString *)symbol botStartsTheGame:(BOOL)botStartsTheGame{
    self = [super init];
    if (self) {
        self.botTTTSymbol = symbol;
        if ([self.botTTTSymbol isEqualToString:kO]) {
            self.playerTTTSymbol = kX;
        } else if ([self.botTTTSymbol isEqualToString:kX]) {
            self.playerTTTSymbol = kO;
        } else {
            self.playerTTTSymbol = @"Z";
        }
        self.botStartsTheGame = botStartsTheGame;
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
        NSUInteger depthLevel = 0;
        self.tree[kBoardKey] = initialBoard;
        self.tree[kDepthKey] = @(depthLevel);
        NSDictionary<NSString *, id> *boardInformation = [self nextPossibleBoardsWithBoard:initialBoard depthLevel:depthLevel+1];
        self.tree[kScoreKey] = boardInformation[kScoreKey];
        self.tree[kNextPossibleMovesKey] = boardInformation[kNextPossibleMovesKey];
    }
    
    return self;
}

-(NSNumber *)playBot:(NSArray *)gameBoard {
    
    return 0;
}

-(NSInteger)nextMoveWithBoard:(NSDictionary *)board {
    return arc4random_uniform(8);
}

#pragma mark - Private Methods

-(NSDictionary<NSString *, id> *)nextPossibleBoardsWithBoard:(NSDictionary *)parentBoard depthLevel:(NSUInteger)depthLevel {
    if ([self gameIsCompleteWithBoard:parentBoard]) {
        return @{
                 kNextPossibleMovesKey : [NSNull null],
                 kScoreKey : [self scoreWithBoard:parentBoard]
                 };
    }
    
    
    NSMutableArray<NSDictionary *> *nextPossibleBoards = [[NSMutableArray alloc] init];
    __block float score = 0.f;
    
    NSArray<NSNumber *> *emptyPositions = [self emptyPositionsWithBoard:parentBoard];
    for (NSNumber *emptyPosition in emptyPositions) {
        NSMutableDictionary *eachMove = [NSMutableDictionary dictionary];
        NSDictionary *board = [self boardWithBoard:parentBoard
                                    positionToMark:[emptyPosition unsignedIntegerValue]
                                        depthLevel:depthLevel];
        eachMove[kBoardKey] = board;
        eachMove[kDepthKey] = @(depthLevel);
        
        NSDictionary *possibleBoards = [self nextPossibleBoardsWithBoard:board depthLevel:depthLevel + 1];
        score += [possibleBoards[kScoreKey] floatValue];
        
        eachMove[kScoreKey] = possibleBoards[kScoreKey];
        eachMove[kNextPossibleMovesKey] = possibleBoards;
        
        self.amountOfBoardsMade++;
        [nextPossibleBoards addObject:eachMove];
    }

    score /= emptyPositions.count;
    
    return @{
             kNextPossibleMovesKey : nextPossibleBoards,
             kScoreKey : @(score)
             };
}

-(NSNumber *)maxScoreFromFirstGenerationChildren:(NSDictionary *)possibleBoards {
    if ([possibleBoards[kNextPossibleMovesKey] isKindOfClass:[NSNull class]]) {
        return possibleBoards[kScoreKey];
    }
    
    //Scores are either -1, 0, or 1. Lowest is -1.
    float firstBiggestScore;
    NSArray *nextPossibleMoves = possibleBoards[kNextPossibleMovesKey];
    
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
    if ([possibleBoards[kNextPossibleMovesKey] isKindOfClass:[NSNull class]]) {
        return possibleBoards[kScoreKey];
    }
    
    //Scores are either -1, 0, or 1. Biggest is 1.
    float firstSmallestScore;
    NSArray *nextPossibleMoves = possibleBoards[kNextPossibleMovesKey];
    
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

-(NSDictionary *)boardWithBoard:(NSDictionary *)parentBoard positionToMark:(const NSUInteger)positionToMark depthLevel:(NSUInteger)depthLevel{
    NSMutableDictionary *board = [parentBoard mutableCopy];
    
    if (depthLevel % 2 == 1) {
        board[@(positionToMark)] = self.botStartsTheGame ? self.botTTTSymbol : self.playerTTTSymbol;
    } else {
        board[@(positionToMark)] = self.botStartsTheGame ? self.playerTTTSymbol : self.botTTTSymbol;
    }
    
    return board;
}

// Checks if the board is full or someone won the game
-(BOOL)gameIsCompleteWithBoard:(NSDictionary *)board {
    __block BOOL hasEmptyPositions = NO;
    
    [board enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            hasEmptyPositions = YES;
            *stop = YES;
        }
    }];
    
    if (hasEmptyPositions) {
        return NO;
    } else if ([self winningIndicesWithBoard:board]) {
        return YES;
    }
    
    return NO;
}

// Returns an array of winning indices, e.g., @[@1, @2, @3]
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

// Returns @"X", @"O", or nil
-(NSString *)winnerWithCompleteBoard:(NSDictionary *)board {
    NSString *winner = nil;
    // If there's a winner.
    if ([self winningIndicesWithBoard:board]) {
        //Get who won.
        if ([self emptyPositionsWithBoard:board].count % 2 == 0) {
            winner = self.botStartsTheGame ? self.botTTTSymbol : self.playerTTTSymbol;
        } else {
            winner = self.botStartsTheGame ? self.playerTTTSymbol : self.botTTTSymbol;
        }
    }
    
    return winner;
}

-(NSArray<NSNumber *> *)emptyPositionsWithBoard:(NSDictionary *)board {
    __block NSMutableArray<NSNumber *> *emptyPositions = [NSMutableArray array];
    
    [board enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [emptyPositions addObject:key];
        }
    }];
    
    return emptyPositions;
}

-(NSNumber *)scoreWithBoard:(NSDictionary *)board {
    float score = 0.f;
    NSString *result = [self winnerWithCompleteBoard:board];
    
    if ([result isEqualToString:self.botTTTSymbol]) {
        score = 1;
    } else if ([result isEqualToString:self.playerTTTSymbol]) {
        score = -1;
    }
    
    return @(score);
}

/*
 
 1 | 2 | 3
 - - - - -
 4 | 5 | 6
 - - - - -
 7 | 8 | 9
 
 Regular comparison compares 1-2-3, 4-5-6, 7-8-9, 1-4-7, 2-5-8, 3-6-9, 1-5-9, 3-5-7 == 8 comparisons.
 Each comparison would call to check if the index is a string, meaning it's marked so 8 x 3 = 24 statements.
 Also, they can only compare 2 things at a time, so each comparison runs 2 times so 24 x 2 = 48 statements.
 
 Instead, by checking if 1 is not filled, then we don't have to check for others except 6 and 8. Run count == 1.
 
 X | X | X
 - - - - -
 X | X | 6
 - - - - -
 X | 8 | X
 Fig.1
 
 1 | 2 | O
 - - - - -
 O | O | O
 - - - - -
 7 | 8 | O
 Fig.2
 
 1 | O | 3
 - - - - -
 4 | O | 6
 - - - - -
 O | O | O
 Fig.3
 
 Notice the intersection of Fig.2 and Fig.3 is 5 and 9 so we can just check those 2. (Run count += 2) == 3.
 
 Therefore in cases where 1, 5, 9 are null, instead of calling run 48 times for each figure generated, it'll call 3.
 Since there are 986410 figures being made, the original would take 986410 * 48 statement calls == 47,347,680 statements in this alone.
 In contrast to the Summation(6!/K!) where K == 0 until K == 5 possible cases where 1-5-9 are empty, which is 1956 figures.
 So the run time with this method is (1956 * 3) + ((986410 - 1956) * 48) = 5868 + 47253792 = 47,259,660 statements total.
 
 ... It only improved about 0.2% but this is only the best case scenario where all 1-5-9 are not marked.
 
 Theoretical Computation:
 1 + 9 + 9 * 8 + (9 * 8) * 7 + ... + 9!
 1 + Summation(9!/K!) where K == 0 until K == 8
 1 + 986409 == 986410
 
 Actual Computation: (By counting the number of times getCurrentTTTChartWithParentTTTChart:currentMoveNumber:depthLevel: is called)
 1 + 986409 == 986410
 
 Eliminating early whenever a victor has been determined reduces the amount of boards to 549,945. Reduces amount by about 45%
 2,768,336 - 2,839,184 comparisons depending on which comparisons are done first. (Diagonals first) - (Diagonals last) comparison.
 
 Getting the scores: (In float)
 1st move - Corners have 0.342857
 - Sides have 0.200000
 - Middle have 0.500000
 Corner - Adjacent side have 0.457143
 - All corners have 0.285714
 - Middle have 0.114286
 - Adjacent of middle that are not adjacent to the marked corner have 0.428571
 */


@end

