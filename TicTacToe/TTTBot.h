//
//  TTTBot.h
//  TicTacToe
//
//  Created by Aung Moe on 8/2/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTBot : NSObject
-(instancetype)initWithBotTTTSymbol:(NSString *)symbol botStartsTheGame:(BOOL)botStarts NS_DESIGNATED_INITIALIZER;
-(NSInteger)nextMoveWithBoard:(NSDictionary *)board;
@end
