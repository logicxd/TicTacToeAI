//
//  TicTacToeTableViewController.m
//  TicTacToe
//
//  Created by Alaric Gonzales on 8/1/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import "TicTacToeTableViewController.h"
#import "TTTCell.h"
#import "TTTBot.h"
#import "TTTInformationCell.h"
#import "Masonry.h"

@interface TicTacToeTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *view;
@property (nonatomic) NSInteger nextTurn;
@property (nonatomic, strong) TTTBot *bot;
//@property (nonatomic, strong, readonly) UISwitch *switchButton;
@end

@implementation TicTacToeTableViewController

@dynamic view;

- (void)loadView {
    self.view = [[UITableView alloc] init];
    self.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.separatorColor = [UIColor blackColor];
    
    [self.view registerClass:[TTTCell class] forCellReuseIdentifier:@"TTTCell"];
    [self.view registerClass:[TTTInformationCell class] forCellReuseIdentifier:@"TTTInformationCell"];

}

- (void)viewDidLoad {
    [super viewDidLoad];        
    
    self.view.userInteractionEnabled = NO;
    
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    [backgroundQueue addOperationWithBlock:^{
        TTTBot *bot = [[TTTBot alloc] initWithBotSymbol:@"O" playerSymbol:@"X" botStartsTheGame:YES];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.view.userInteractionEnabled = YES;
            NSLog(@"Loading...");
            self.bot = bot;
            [self.view reloadData];
            NSLog(@"Data reloaded");
        }];
    }];
    
    self.view.delegate = self;
    self.view.dataSource = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    TTTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TTTCell" forIndexPath:indexPath];
    cell.rowIndex = indexPath.row;
    if (self.bot.botStartsTheGame && self.bot.numberOfRoundsLeft == 9) {
        [self.bot botMovedAtIndex];
    }
    cell.buttonHit = ^(NSInteger index)
    {
        if ([weakSelf.bot numberOfRoundsLeft] > 0) {
            if ([weakSelf.bot botsTurnInGame]) {
                // Bot's turn
                NSInteger indexOfBotsMove = [weakSelf.bot botMovedAtIndex];
                NSLog(@"Bot moved at index: %i", indexOfBotsMove);
            } else {
                // Player's turn
                NSInteger indexOfBotsMove = [weakSelf.bot botMovedAtIndexWithPlayerMove:index];
                NSLog(@"Player moved at index: %i", index);
                NSLog(@"Bot moved at index: %i", indexOfBotsMove);
            }
            
            NSLog(@"Number of Rounds Left: %i", [weakSelf.bot numberOfRoundsLeft]);
            
        } else {
            // numberOfRoundsLeft == 0
            [weakSelf.bot restartGame];
        }
        
        NSString *winner = [weakSelf.bot checkForWinner];
        if (winner) {
            NSLog(@"Winner is %@", winner);
        } else if (!winner && [weakSelf.bot numberOfRoundsLeft] == 0) {
            NSLog(@"Game is a tie");
        }
        
        [weakSelf.view reloadData];
    };
    
    if (indexPath.row == 2) {
        cell.showsBottomLine = NO;
    } else {
        cell.showsBottomLine = YES;
    }
    
    [cell.leftButton setTitle:self.bot.playingBoard[@(0 + indexPath.row * 3)] forState:UIControlStateNormal];
    [cell.centerButton setTitle:self.bot.playingBoard[@(1 + indexPath.row * 3)] forState:UIControlStateNormal];
    [cell.rightButton setTitle:self.bot.playingBoard[@(2 + indexPath.row * 3)] forState:UIControlStateNormal];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    __weak typeof(self) weakSelf = self;
  TTTInformationCell *footerCell = [tableView dequeueReusableCellWithIdentifier:@"TTTInformationCell"];
    
    footerCell.pressedResetButton = ^(){
        [weakSelf.bot restartGame];
        [weakSelf.view reloadData];
//        [weakSelf.view reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//        weakSelf.view reloadRowsAtIndexPaths:[NSArray 0,1,2] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    footerCell.pressedPlayerStartButton = ^(){
        TTTBot *bot = [[TTTBot alloc] initWithBotSymbol:@"O" playerSymbol:@"X" botStartsTheGame:NO];
        NSLog(@"Loading...");
        self.bot = bot;
        [weakSelf.bot restartGame];
        [weakSelf.view reloadData];
        NSLog(@"Ready!");
    };
    
    footerCell.pressedBotStartButton = ^(){
        TTTBot *bot = [[TTTBot alloc] initWithBotSymbol:@"O" playerSymbol:@"X" botStartsTheGame:YES];
        NSLog(@"Loading...");
        self.bot = bot;
        [weakSelf.bot restartGame];
        [weakSelf.view reloadData];
        NSLog(@"Ready!");
    };
//    footerCell.pressedSwitchButton = ^(UISwitch *buttonSwitch){
//        if ([buttonSwitch isOn]){
//            NSLog(@"Button Switch ON");
//            TTTBot *bot = [[TTTBot alloc] initWithBotSymbol:@"O" playerSymbol:@"X" botStartsTheGame:YES];
//            self.bot = bot;
//        } else {
//            NSLog(@"Button Switch OFF");
//            TTTBot *bot = [[TTTBot alloc] initWithBotSymbol:@"O" playerSymbol:@"X" botStartsTheGame:NO];
//            self.bot = bot;
//        }
//        [weakSelf.view reloadData];
//        
//    };
//    
//    if (weakSelf.bot.botStartsTheGame == YES) {
//        NSLog(@"BOT Starts the game");
//    } else if (weakSelf.bot.botStartsTheGame == NO){
//        NSLog(@"PLAYER Starts the game");
//    }
    return footerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 90;
}


@end
