//
//  ViewController.m
//  CustomGestureDemo
//
//  Created by Alex Shevlyakov on 17/09/15.
//  Copyright (c) 2015 Alex Shevlyakov. All rights reserved.
//

#import "ViewController.h"
#import "YMSquareGestureRecognizer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YMSquareGestureRecognizer *squareGesture = [[YMSquareGestureRecognizer alloc] initWithTarget:self action:@selector(squareGestureHandle:)];
    [self.view addGestureRecognizer:squareGesture];
}

- (void)squareGestureHandle:(id)sender
{
    NSLog(@"Square gesture recognized");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
