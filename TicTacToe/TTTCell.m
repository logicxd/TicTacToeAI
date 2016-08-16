//
//  TicTacToeTableViewCell.m
//  
//
//  Created by Alaric Gonzales on 8/1/16.
//
//

#import "TTTCell.h"
#import "Masonry.h"

@interface TTTCell()
@property (nonatomic, strong) UIView *leftVerticalLine;
@property (nonatomic, strong) UIView *rightVerticalLine;
@property (nonatomic, strong) UIView *bottomLine;
@end

@implementation TTTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        _leftButton = [[UIButton alloc] init];
        self.leftButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
        [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(buttonHit:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.leftButton];
        
        _centerButton = [[UIButton alloc] init];
        self.centerButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
        [self.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.centerButton addTarget:self action:@selector(buttonHit:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.centerButton];
        
        _rightButton = [[UIButton alloc] init];
        self.rightButton.titleLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
        [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(buttonHit:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.rightButton];
        
        self.leftVerticalLine = [[UIView alloc] init];
        self.leftVerticalLine.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.leftVerticalLine];
        
        self.rightVerticalLine = [[UIView alloc] init];
        self.rightVerticalLine.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.rightVerticalLine];
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.bottomLine];
        
//        _switchButton = [[UISwitch alloc] init];
//        [self.switchButton addTarget:self action:@selector(switchPress:) forControlEvents:UIControlEventTouchUpInside];
        
        
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
    
    [self.leftVerticalLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftButton.mas_right).offset(10);
        make.right.equalTo(self.centerButton.mas_left).offset(-10);
        make.top.bottom.equalTo(self.contentView);
    }];
    [self.rightVerticalLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightButton.mas_left).offset(-10);
        make.left.equalTo(self.centerButton.mas_right).offset(10);
        make.top.bottom.equalTo(self.contentView);
    }];
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@5);
    }];
    
    [super updateConstraints];
}

- (void)setShowsBottomLine:(BOOL)showsBottomLine {
    self.bottomLine.hidden = !showsBottomLine;
}

- (void)buttonHit:(UIButton *)button {
    if (button == self.leftButton) {
        self.buttonHit(0 + self.rowIndex * 3);
    } else if (button == self.centerButton) {
        self.buttonHit(1 + self.rowIndex * 3);
    } else if (button == self.rightButton) {
        self.buttonHit(2 + self.rowIndex * 3);
    }
}

@end
