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
    
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    [backgroundQueue addOperationWithBlock:^{
        TTTBot *bot = [[TTTBot alloc] init];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.bot = bot;
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
        weakSelf.board[@(index)] = @"X";
        
        NSInteger botPlay = 0;
        weakSelf.board[@(botPlay)] = @"O";
        
        [weakSelf.view reloadData];
    };
    
    if (indexPath.row == 2) {
        cell.showsBottomLine = NO;
    } else {
        cell.showsBottomLine = YES;
    }
    
    [cell.leftButton setTitle:self.board[@(0 + indexPath.row * 3)] forState:UIControlStateNormal];
    [cell.centerButton setTitle:self.board[@(1 + indexPath.row * 3)] forState:UIControlStateNormal];
    [cell.rightButton setTitle:self.board[@(2 + indexPath.row * 3)] forState:UIControlStateNormal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

@end
