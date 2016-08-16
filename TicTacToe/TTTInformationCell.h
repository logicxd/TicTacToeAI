//
//  TTTInformationCell.h
//  TicTacToe
//
//  Created by Aung Moe on 8/12/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTInformationCell : UITableViewCell
@property (nonatomic, strong) UILabel *gameStatus;
@property (nonatomic, strong) UIButton *playerStartButton;
@property (nonatomic, strong) UIButton *botStartButton;
@property (nonatomic, strong, readonly) UIButton *resetButton;

@property (nonatomic, copy) void (^pressedPlayerStartButton)();
@property (nonatomic, copy) void (^pressedResetButton)();
@property (nonatomic, copy) void (^pressedBotStartButton)();


@end
