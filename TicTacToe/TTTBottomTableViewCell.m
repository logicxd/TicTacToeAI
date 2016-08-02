//
//  TTTBottomTableViewCell.m
//  TicTacToe
//
//  Created by Alaric Gonzales on 8/1/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import "TTTBottomTableViewCell.h"
#import "Masonry.h"

@implementation TTTBottomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.centerButton = [[UIButton alloc] init];
        self.centerButton.backgroundColor = [UIColor cyanColor];
        [self.centerButton setTitle:@"8" forState:UIControlStateNormal];
        [self.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.centerButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
        self.centerButton.showsTouchWhenHighlighted = YES;
        [self.contentView addSubview:self.centerButton];
        
        self.leftButton = [[UIButton alloc] init];
        self.leftButton.backgroundColor = [UIColor cyanColor];
        [self.leftButton setTitle:@"7" forState:UIControlStateNormal];
        [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.leftButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
        self.leftButton.showsTouchWhenHighlighted = YES;
        [self.contentView addSubview:self.leftButton];
        
        self.rightButton = [[UIButton alloc] init];
        self.rightButton.backgroundColor = [UIColor cyanColor];
        [self.rightButton setTitle:@"9" forState:UIControlStateNormal];
        [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.rightButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
        self.rightButton.showsTouchWhenHighlighted = YES;
        [self.contentView addSubview:self.rightButton];
        
        self.leftColumn = [[UIView alloc] init];
        self.leftColumn.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.leftColumn];
        
        self.rightColumn = [[UIView alloc] init];
        self.rightColumn.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.rightColumn];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.centerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView.mas_left).offset(120);
        make.right.equalTo(self.contentView.mas_right).offset(-120);
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
    }];
    
    [self.leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.centerButton.mas_left).offset(-30);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.top.equalTo(self.centerButton.mas_top);
        make.bottom.equalTo(self.centerButton.mas_bottom);
    }];
    
    [self.rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerButton.mas_right).offset(30);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.top.equalTo(self.centerButton.mas_top);
        make.bottom.equalTo(self.centerButton.mas_bottom);
    }];
    
    [self.leftColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftButton.mas_right).offset(10);
        make.right.equalTo(self.centerButton.mas_left).offset(-10);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    [self.rightColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightButton.mas_left).offset(-10);
        make.left.equalTo(self.centerButton.mas_right).offset(10);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    
    [super updateConstraints];
}


@end
