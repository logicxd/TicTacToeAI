//
//  TicTacToeTableViewController.m
//  TicTacToe
//
//  Created by Alaric Gonzales on 8/1/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import "TicTacToeTableViewController.h"
#import "TTTTopTableViewCell.h"
#import "TTTMiddleTableViewCell.h"
#import "TTTBottomTableViewCell.h"

@interface TicTacToeTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *view;

@end

@implementation TicTacToeTableViewController

- (void)loadView {
    self.view = [[UITableView alloc] init];
    self.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.separatorColor = [UIColor blackColor];
    
    [self.view registerClass:[TTTTopTableViewCell class] forCellReuseIdentifier:@"TicTacToeTopCell"];
    [self.view registerClass:[TTTMiddleTableViewCell class] forCellReuseIdentifier:@"TicTacToeMiddleCell"];
    [self.view registerClass:[TTTBottomTableViewCell class] forCellReuseIdentifier:@"TicTacToeBottomCell"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    if (indexPath.row == 0) {
    
        TTTTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicTacToeTopCell" forIndexPath:indexPath];
        
        return cell;
        
    } else if (indexPath.row == 1) {
        
        TTTMiddleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicTacToeMiddleCell" forIndexPath:indexPath];
        
        return cell;
    }
    
        TTTBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TicTacToeBottomCell" forIndexPath:indexPath];
        
        return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}


@end
