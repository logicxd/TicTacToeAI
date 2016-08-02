////
////  ViewController.m
////  SkyscannerTripDetails
////
////  Created by Alaric Gonzales on 6/30/16.
////  Copyright © 2016 Alaric Gonzales. All rights reserved.
////
//
//#import "ViewController.h"
//#import "FBShimmeringView.h"
//
//
//@interface ViewController ()
//
//@end
//
//@implementation ViewController {
//    
//    FBShimmeringView *_shimmeringView;
//    UILabel *fancyLabel;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:229/255.0 blue:189/255.0 alpha:1.0];
//    
//    CGRect valueFrame = self.view.bounds;
//    valueFrame.size.height = valueFrame.size.height * 0.25;
//    
//    _shimmeringView = [[FBShimmeringView alloc] init];
//    _shimmeringView.shimmering = YES;
//    _shimmeringView.shimmeringBeginFadeDuration = 0.2;
//    _shimmeringView.shimmeringOpacity = 0.2;
//    [self.view addSubview:_shimmeringView];
//    
//    fancyLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
//    fancyLabel.text = @"VOGUE";
//    fancyLabel.font = [UIFont fontWithName:@"Didot-Bold" size:50.0];
//    fancyLabel.textColor = [UIColor redColor];
//    fancyLabel.textAlignment = NSTextAlignmentCenter;
//    fancyLabel.backgroundColor = [UIColor clearColor];
//    _shimmeringView.contentView = fancyLabel;
//    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapped:)];
//    [self.view addGestureRecognizer:tapRecognizer];
//    
//}
//
//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    
//    CGRect shimmeringFrame = self.view.bounds;
//    shimmeringFrame.origin.y = shimmeringFrame.size.height * 0.40;
//    shimmeringFrame.size.height = shimmeringFrame.size.height * 0.10;
//    _shimmeringView.frame = shimmeringFrame;
//}
//
//- (void)_tapped:(UITapGestureRecognizer *)tapRecognizer {
//    _shimmeringView.shimmering = !_shimmeringView.shimmering;
//}
//
//@end
