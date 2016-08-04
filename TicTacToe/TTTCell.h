//
//  TicTacToeTableViewCell.h
//  
//
//  Created by Alaric Gonzales on 8/1/16.
//
//

#import <UIKit/UIKit.h>

@interface TTTCell : UITableViewCell
@property (nonatomic, strong, readonly) UIButton *centerButton;
@property (nonatomic, strong, readonly) UIButton *leftButton;
@property (nonatomic, strong, readonly) UIButton *rightButton;

@property (nonatomic) NSInteger rowIndex;
@property (nonatomic) BOOL showsBottomLine;
@property (nonatomic, copy) void (^buttonHit)(NSInteger index);
@end
