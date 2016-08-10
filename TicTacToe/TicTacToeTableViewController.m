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

@interface TicTacToeTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *view;
@property (nonatomic) NSInteger nextTurn;
@property (nonatomic, strong) NSMutableDictionary *board;
@property (nonatomic, strong) TTTBot *bot;
@end

@implementation TicTacToeTableViewController

@dynamic view;

- (void)loadView {
    self.view = [[UITableView alloc] init];
    self.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.separatorColor = [UIColor blackColor];
    
    [self.view registerClass:[TTTCell class] forCellReuseIdentifier:@"TTTCell"];
}

- (void)viewDidLoad {
    [super viewDidLoad];        
    
    self.view.userInteractionEnabled = NO;
    
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    [backgroundQueue addOperationWithBlock:^{
        TTTBot *bot = [[TTTBot alloc] initWithBotTTTSymbol:@"X" playerTTTSymbol:@"O" botStartsTheGame:NO];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.view.userInteractionEnabled = YES;
            self.bot = bot;
            [self.view reloadData];
            NSLog(@"Data reloaded");
        }];
    }];
    
    self.board = [@{
                    @0 : @"0",
                    @1 : @"1",
                    @2 : @"2",
                    @3 : @"3",
                    @4 : @"4",
                    @5 : @"5",
                    @6 : @"6",
                    @7 : @"7",
                    @8 : @"8",
                   } mutableCopy];
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"Tic-Tac-Toe";
    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    
    TTTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TTTCell" forIndexPath:indexPath];
    cell.rowIndex = indexPath.row;
    cell.buttonHit = ^(NSInteger index) {
        
        // Assuming player starts first --> Players turn on Even Rounds
        
        if ([weakSelf.bot numberOfRoundsLeft] > 0) {
            
            if ([weakSelf.bot numberOfRoundsLeft] % 2 == 0) {
                NSInteger indexOfBotsMove = [weakSelf.bot botMovedAtIndex];
//                weakSelf.bot.playingBoard[@(indexOfBotsMove)] = @"X";
                NSLog(@"Bot moved at index: %i", indexOfBotsMove);
                
            } else {
                NSInteger indexOfPlayersMove = [weakSelf.bot playerMovedAtIndex:index];
//                weakSelf.bot.playingBoard[@(indexOfPlayersMove)] = @"O";
                NSLog(@"Player moved at index: %i", indexOfPlayersMove);
                
                if ([weakSelf.bot numberOfRoundsLeft] > 0 && [weakSelf.bot checkForWinner] == nil) {
                    NSInteger indexOfBotsMove = [weakSelf.bot botMovedAtIndex];
//                    weakSelf.bot.playingBoard[@(indexOfBotsMove)] = @"X";
                    NSLog(@"Bot moved at index: %i", indexOfBotsMove);
                }
            }
            NSLog(@"Number of Rounds Left: %i", [weakSelf.bot numberOfRoundsLeft]);
        } else {
            [weakSelf.bot resetBoard];
        }
        
        NSString *winner = [weakSelf.bot checkForWinner];
        if (winner) {
            NSLog(@"Winner is %@", winner);
        } else if (!winner && [weakSelf.bot numberOfRoundsLeft] == 0){
            NSLog(@"Game is a tie");
        }
        
        [weakSelf.view reloadData];
    };
    
    if (indexPath.row == 2) {
        cell.showsBottomLine = NO;
    } else {
        cell.showsBottomLine = YES;
    }
    
    if (!self.bot) {
//        [cell.leftButton setTitle:self.board[@(0 + indexPath.row * 3)] forState:UIControlStateNormal];
//        [cell.centerButton setTitle:self.board[@(1 + indexPath.row * 3)] forState:UIControlStateNormal];
//        [cell.rightButton setTitle:self.board[@(2 + indexPath.row * 3)] forState:UIControlStateNormal];
    } else {
        NSNumber *index0 = @(0 + indexPath.row * 3);
        NSNumber *index1 = @(1 + indexPath.row * 3);
        NSNumber *index2 = @(2 + indexPath.row * 3);
        
        NSString *title0, *title1, *title2;
        
        if ([self.bot.playingBoard[index0] isKindOfClass:[NSNumber class]]) {
            title0 = [self.bot.playingBoard[index0] stringValue];
        } else {
            title0 = self.bot.playingBoard[index0];
        }
        
        if ([self.bot.playingBoard[index1] isKindOfClass:[NSNumber class]]) {
            title1 = [self.bot.playingBoard[index1] stringValue];
        } else {
            title1 = self.bot.playingBoard[index1];
        }
        
        if ([self.bot.playingBoard[index2] isKindOfClass:[NSNumber class]]) {
            title2 = [self.bot.playingBoard[index2] stringValue];
        } else {
            title2 = self.bot.playingBoard[index2];
        }
        
        if ([title0 isEqualToString:@"X"] || [title0 isEqualToString:@"O"]) {
            [cell.leftButton setTitle:title0 forState:UIControlStateNormal];
        } else {
            [cell.leftButton setTitle:@"" forState:UIControlStateNormal];
        }
        if ([title1 isEqualToString:@"X"] || [title1 isEqualToString:@"O"]) {
            [cell.centerButton setTitle:title1 forState:UIControlStateNormal];
        } else {
            [cell.centerButton setTitle:@"" forState:UIControlStateNormal];
        }
        if ([title2 isEqualToString:@"X"] || [title2 isEqualToString:@"O"]) {
            [cell.rightButton setTitle:title2 forState:UIControlStateNormal];
        } else {
            [cell.rightButton setTitle:@"" forState:UIControlStateNormal];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

@end
