//
//  TTTBot.h
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTBot : NSObject

// Holds the current TTT board
@property (nonatomic, strong, readonly) NSMutableDictionary *playingBoard;

// Returns how many rounds are left 0 - 9. If 0, then the game is finished.
@property (nonatomic, readonly) NSInteger numberOfRoundsLeft;

// Initializes bot with bot symbol as "X" and player symbol as "O" and assumes player starts the game.
- (instancetype)init;

// Initializes bot with given bot symbol and player symbol.
- (instancetype)initWithBotTTTSymbol:(NSString *)botSymbol playerTTTSymbol:(NSString *)playerSymbol botStartsTheGame:(BOOL)botStartsTheGame NS_DESIGNATED_INITIALIZER;

// Bot makes a move and returns the index where it marked.
- (NSInteger)botMovedAtIndex;

// Player passes in the index where it marked, and returns the same index.
- (NSInteger)playerMovedAtIndex:(NSInteger)index;

// nil == no winners yet.    Player's Symbol == player wins.    Bot's Symbol == bot wins.
- (NSString *)checkForWinner;

// Resets playingBoard back to emptyBoard.
- (void)resetBoard;

@end



















