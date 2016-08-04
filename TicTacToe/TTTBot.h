//
//  TTTBot.h
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTBot : NSObject

@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong) NSString *botTTTSymbol;         //Generic "X" and "O" are considered to be used.
@property (nonatomic, strong) NSString *playerTTTSymbol;
@property (nonatomic) BOOL botStartsTheGame;

-(instancetype)initWithBotTTTSymbol:(NSString *)symbol botStartsTheGame:(BOOL)botStarts NS_DESIGNATED_INITIALIZER;

@end
