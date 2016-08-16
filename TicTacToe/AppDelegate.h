//
//  AppDelegate.h
//  TicTacToe
//
//  Created by Alaric Gonzales on 8/1/16.
//  Copyright © 2016 Alaric Gonzales. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TicTacToeTableViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TicTacToeTableViewController *viewController;
@property (nonatomic, strong) UIImageView *splashView;


@end

