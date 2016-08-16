//
//  TTTBot.h
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTBot : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSMutableDictionary *playingBoard;  // Holds current TTT board
@property (nonatomic, readonly) NSInteger numberOfRoundsLeft;               // Returns 0 - 9. Game's completed at round 0.
@property (nonatomic, strong) NSString *botSymbol;                          // Bot's character symbol.
@property (nonatomic, strong) NSString *playerSymbol;                       // Player's character symbol.
@property (nonatomic) BOOL botStartsTheGame;                                // YES if bot starts the game. NO otherwise. 

#pragma mark - Inits

- (instancetype)init;   // Player is "X" and the Bot is "O". Player starts the game.
- (instancetype)initWithBotSymbol:(NSString *)botSymbol playerSymbol:(NSString *)playerSymbol botStartsTheGame:(BOOL)botStartsTheGame NS_DESIGNATED_INITIALIZER;

#pragma mark - Interaction with bot

- (NSInteger)botMovedAtIndex;                                   // Bot makes a move and returns the index where it marked. Returns -1 if invalid.
- (NSInteger)botMovedAtIndexWithPlayerMove:(NSInteger)index;    // Player makes a move at index, and then the bot moves. Returns -1 if invalid.
- (NSInteger)playerMovedAtIndex:(NSInteger)index;               // Player passes in the index where it marked. Returns -1 if invalid.
- (BOOL)botsTurnInGame;                                         // Returns true if it's bot's turn.
- (NSString *)checkForWinner;                                   // Returns the winner's symbol if a winner is determined. Nil otherwise.
- (void)restartGame;                                            // Restarts the game.
- (NSArray<NSNumber *> *)winningIndicesWithBoard:(NSDictionary *)board;
@end



















