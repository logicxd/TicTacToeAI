//
//  TicTacToeTableViewCell.h
//  
//
//  Created by Alaric Gonzales on 8/1/16.
//
//

#import <UIKit/UIKit.h>

@interface TTTTopTableViewCell : UITableViewCell
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *leftColumn;
@property (nonatomic, strong) UIView *rightColumn;
@property (nonatomic, strong) UIView *bottomColumn;

@end
