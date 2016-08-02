//
//  TTTBottomTableViewCell.h
//  TicTacToe
//
//  Created by Alaric Gonzales on 8/1/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTBottomTableViewCell : UITableViewCell
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *leftColumn;
@property (nonatomic, strong) UIView *rightColumn;
@end
