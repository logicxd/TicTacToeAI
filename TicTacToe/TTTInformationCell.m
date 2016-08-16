//
//  TTTInformationCell.m
//  TicTacToe
//
//  Created by Aung Moe on 8/12/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import "TicTacToeTableViewController.h"
#import "TTTInformationCell.h"
#import "TTTBot.h"
#import "Masonry.h"

@interface TTTInformationCell ()

@property (nonatomic, strong) TTTBot *bot;
@end

@implementation TTTInformationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.playerStartButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.playerStartButton setTitle:@"Player Starts" forState:UIControlStateNormal];
        [self.gameStatus setBackgroundColor:[UIColor greenColor]];
        [self.playerStartButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.playerStartButton addTarget:self action:@selector(pressedPlayerStartButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.playerStartButton.titleLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0]];
        [self.contentView addSubview:self.playerStartButton];
        
        self.botStartButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.botStartButton setTitle:@"Bot Starts" forState:UIControlStateNormal];
        [self.gameStatus setBackgroundColor:[UIColor greenColor]];
        [self.botStartButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.botStartButton addTarget:self action:@selector(pressedBotStartButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.botStartButton.titleLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0]];
        [self.contentView addSubview:self.botStartButton];

        self.gameStatus = [[UILabel alloc] init];
        [self.gameStatus setBackgroundColor:[UIColor orangeColor]];
        [self.gameStatus setTextColor:[UIColor grayColor]];
        [self.gameStatus setFont:[UIFont fontWithName:@"Chalkduster" size:14.0]];
        [self.contentView addSubview:self.gameStatus];
        
        _resetButton = [[UIButton alloc] init];
        self.resetButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:14.0];
        self.resetButton.backgroundColor = [UIColor redColor];
        [self.resetButton setTitle:@"RESET" forState:UIControlStateNormal];
    
        [self.resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.resetButton addTarget:self action:@selector(pressedResetButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.resetButton];

        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (BOOL)needsUpdateConstraints {
    return YES;
}

- (void)updateConstraints {
    const float EDGE_INSETS = 10.f;
    NSNumber *const kLabelWidth = @100;
    NSNumber *const kLabelHeight = @20;
    NSNumber *const resetButtonWidth = @90;
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(EDGE_INSETS, EDGE_INSETS, EDGE_INSETS, EDGE_INSETS));
    }];
    
    [self.playerStartButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY);
        make.centerY.equalTo(self.playerStartButton);
        make.left.equalTo(self.contentView);
        make.width.equalTo(kLabelWidth);
        make.height.equalTo(kLabelHeight);
    }];
    
    [self.botStartButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerStartButton);
        make.centerY.equalTo(self.playerStartButton);
        make.right.equalTo(self.contentView);
        make.width.equalTo(kLabelWidth);
        make.height.equalTo(kLabelHeight);
    }];
    
    [self.resetButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.playerStartButton.mas_bottom);
        make.width.equalTo(resetButtonWidth);
    }];
    
    [self.gameStatus mas_remakeConstraints:^(MASConstraintMaker *make) {
        
    }];
    
    [super updateConstraints];
}

- (void)pressedResetButton:(UIButton *)button {
    if (button == self.resetButton) {
        NSLog(@"Game has reset!");
        self.pressedResetButton();
    }

}

- (void)pressedPlayerStartButton:(UIButton *)button {
    if (button == self.playerStartButton){
            NSLog(@"Player starts next!");
            [self.playerStartButton setBackgroundColor:[UIColor yellowColor]];
            [self.botStartButton setBackgroundColor:[UIColor clearColor]];
    }
    self.pressedPlayerStartButton();
}

- (void)pressedBotStartButton:(UIButton *)button {
    if (button == self.botStartButton){
        NSLog(@"Bot starts next!");
        [self.botStartButton setBackgroundColor:[UIColor yellowColor]];
        [self.playerStartButton setBackgroundColor:[UIColor clearColor]];
    }
    self.pressedBotStartButton();
}


@end
