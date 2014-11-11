//
//  ViewController.m
//  TicTacToe
//
//  Created by miganbec on 06/11/14.
//  Copyright (c) 2014 miganbec. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIAlertViewDelegate>
@property CGPoint originalCenter;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@property (weak, nonatomic) IBOutlet UILabel *labelFour;
@property (weak, nonatomic) IBOutlet UILabel *labelFive;
@property (weak, nonatomic) IBOutlet UILabel *labelSix;
@property (weak, nonatomic) IBOutlet UILabel *labelSeven;
@property (weak, nonatomic) IBOutlet UILabel *labelEight;
@property (weak, nonatomic) IBOutlet UILabel *labelNine;
@property (weak, nonatomic) IBOutlet UILabel *secondsLeft;
@property (weak, nonatomic) IBOutlet UILabel *computerLabel;
@property (weak, nonatomic) IBOutlet UILabel *whichPlayerLabel;
@property NSTimer *timer;
@property NSArray *gridLabelsArray;
@property NSArray *winningCombinations;
@property NSMutableArray *openCornersArray;
@property NSMutableArray *originalColorsArray;
@property NSMutableArray *computerChoicesArray;
@property int time;
@property int turn;
@property BOOL isComputerMode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originalCenter = self.whichPlayerLabel.center;
    self.whichPlayerLabel.text = @"X";
    self.whichPlayerLabel.textColor = [UIColor blueColor];
    self.gridLabelsArray = [NSArray arrayWithObjects:self.labelOne, self.labelTwo, self.labelThree, self.labelFour, self.labelFive, self.labelSix, self.labelSeven, self.labelEight, self.labelNine, nil];
    self.originalColorsArray = [[NSMutableArray alloc] init];
    for (UILabel *label in self.gridLabelsArray) {
        UIColor *color = label.backgroundColor;
        [self.originalColorsArray addObject:color];
    }
    self.winningCombinations = [[NSArray alloc] initWithObjects:
                                @[self.labelOne, self.labelTwo, self.labelThree],
                                @[self.labelFour, self.labelFive, self.labelSix],
                                @[self.labelSeven, self.labelEight, self.labelNine],
                                @[self.labelOne, self.labelFour, self.labelSeven],
                                @[self.labelTwo, self.labelFive, self.labelEight],
                                @[self.labelThree, self.labelSix, self.labelNine],
                                @[self.labelOne, self.labelFive, self.labelNine],
                                @[self.labelThree, self.labelFive, self.labelSeven], nil];
    self.openCornersArray = [[NSMutableArray alloc] initWithObjects:self.labelOne, self.labelThree, self.labelSeven, self.labelNine, nil];
    self.turn = 1;
    self.isComputerMode = NO;
    [self startTimer:10];
}

- (UILabel *)findLabelUsingPoint:(CGPoint)point {
    for (UILabel *label in self.gridLabelsArray) {
        if (CGRectContainsPoint(label.frame, point)) {
            return label;
        }
    }
    return nil;
}

- (IBAction)onDragToLabel:(UIPanGestureRecognizer *)panGesture {
    CGPoint point = [panGesture locationInView:self.view];
    if (CGRectContainsPoint(self.whichPlayerLabel.frame, point)) {
        self.whichPlayerLabel.center = point;
        if (panGesture.state == UIGestureRecognizerStateEnded) {
            UILabel *selectedLabel = [self findLabelUsingPoint:point];
            self.whichPlayerLabel.center = self.originalCenter;
            if (selectedLabel != nil && [selectedLabel.text isEqualToString:@""]) {
                selectedLabel = [self labelWasSelected:selectedLabel];
                BOOL gameOver = [self whoWon:self.whichPlayerLabel.text];
                if (gameOver == NO) {
                    [self changePlayerTurn:self.whichPlayerLabel];
                    [self computerMove];
                }
            }
        }
    }
}

- (IBAction)onLabelTapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.view];
    UILabel *selectedLabel = [self findLabelUsingPoint:point];
    if (selectedLabel != nil && [selectedLabel.text isEqualToString:@""]) {
        selectedLabel = [self labelWasSelected:selectedLabel];
        BOOL gameOver = [self whoWon:self.whichPlayerLabel.text];
        if (gameOver == NO) {
            [self changePlayerTurn:self.whichPlayerLabel];
            [self computerMove];
        }
    }
    if (CGRectContainsPoint(self.computerLabel.frame, point)) {
        if (self.isComputerMode == NO) {
            //[self newGame];
            self.computerLabel.text = @"Play with friend";
            self.isComputerMode = YES;
        } else {
            //[self newGame];
            self.computerLabel.text = @"Play computer";
            self.isComputerMode = NO;
        }
        self.isComputerMode = !self.isComputerMode;
        [self newGame];
    }
}

- (UILabel *)labelWasSelected:(UILabel *)label {
    label.text = self.whichPlayerLabel.text;
    label.textColor = [UIColor greenColor];
    label.backgroundColor = self.whichPlayerLabel.textColor;
    return label;
}

- (void)changePlayerTurn:(UILabel *)currentPlayerLabel {
    if ([currentPlayerLabel.text isEqual:@"X"]) {
        currentPlayerLabel.text = @"O";
        currentPlayerLabel.textColor = [UIColor redColor];
    } else {
        currentPlayerLabel.text = @"X";
        currentPlayerLabel.textColor = [UIColor blueColor];
    }
    [self resetTimerToFive];
}

- (BOOL)whoWon:(NSString *)previousMovePlayer {
    for (NSArray *combo in self.winningCombinations) {
        int count = 0;
        for (UILabel *label in combo) {
            if (label.backgroundColor == self.whichPlayerLabel.textColor) {
                count++;
                if (count == 3) {
                    UIAlertView *alertView = [[UIAlertView alloc] init];
                    alertView.delegate = self;
                    if ([previousMovePlayer isEqualToString:@"Computer"]) {
                        alertView.title = [NSString stringWithFormat:@"%@ has won", previousMovePlayer];
                    } else {
                        alertView.title = [NSString stringWithFormat:@"Player %@ has won!", previousMovePlayer];
                    }
                    alertView.message = @"Tic Tac Toe, Three in a row!";
                    [alertView addButtonWithTitle:@"New game"];
                    [alertView show];
                    return YES;
                }
            }
        }
    }
    BOOL tie = NO;
    for (UILabel *label in self.gridLabelsArray) {
        if (![label.text isEqualToString:@""]) {
            tie = NO;
            break;
        } else {
            tie = YES;
        }
    }
//    if (![self.labelOne.text isEqualToString:@""] &&
//        ![self.labelTwo.text isEqualToString:@""] &&
//        ![self.labelThree.text isEqualToString:@""] &&
//        ![self.labelFour.text isEqualToString:@""] &&
//        ![self.labelFive.text isEqualToString:@""] &&
//        ![self.labelSix.text isEqualToString:@""] &&
//        ![self.labelSeven.text isEqualToString:@""] &&
//        ![self.labelEight.text isEqualToString:@""] &&
//        ![self.labelNine.text isEqualToString:@""]) {
//        UIAlertView *alertViewTie = [[UIAlertView alloc] init];
//        alertViewTie.delegate = self;
//        alertViewTie.title = @"Tie!";
//        alertViewTie.message = @"That was close! Play again.";
//        [alertViewTie addButtonWithTitle:@"New game"];
//        [alertViewTie show];
//        return YES;
//    }
    if (tie == YES) {
        UIAlertView *alertViewTie = [[UIAlertView alloc] init];
        alertViewTie.delegate = self;
        alertViewTie.title = @"Tie!";
        alertViewTie.message = @"That was close! Play again.";
        [alertViewTie addButtonWithTitle:@"New game"];
        [alertViewTie show];
        return YES;
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self newGame];
    }
}

- (void)newGame {
    self.whichPlayerLabel.text = @"X";
    self.whichPlayerLabel.textColor = [UIColor blueColor];
    for (int i = 0; i < 9; i++) {
        ((UILabel *)[self.gridLabelsArray objectAtIndex:i]).backgroundColor = self.originalColorsArray[i];
        ((UILabel *)[self.gridLabelsArray objectAtIndex:i]).text = @"";
    }
    [self resetTimerToFive];
    self.turn = 1;
}

- (void)resetTimerToFive {
    [self.timer invalidate];
    [self startTimer:5];
}

- (void)startTimer:(int)length {
    self.time = length;
    self.secondsLeft.text = [NSString stringWithFormat:@"%d", length];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void)countDown {
    self.time -= 1;
    self.secondsLeft.text = [NSString stringWithFormat:@"%d", self.time];
    self.secondsLeft.textColor = [UIColor blackColor];
    if (self.time == 0) {
        self.whichPlayerLabel.center = self.originalCenter;
        [self changePlayerTurn:self.whichPlayerLabel];
        [self computerMove];
        [self.timer invalidate];
        [self startTimer:5];
    }
}

- (void)computerMove {
    if (self.isComputerMode == YES) {
        switch (self.turn) {
            case 1:
                if ([self.labelFive.text isEqualToString:@""]) {
                    self.labelFive = [self labelWasSelected:self.labelFive];
                } else {
                    int random = arc4random_uniform((int32_t)(self.openCornersArray.count));
                    UILabel *selectedLabel = self.openCornersArray[random];
                    selectedLabel = [self labelWasSelected:selectedLabel];
                }
                break;
            case 2:
                for (UILabel *corner in self.openCornersArray) {
                    if ([corner.text isEqualToString:@""]) {
                        UILabel *selectedLabel = corner;
                        selectedLabel = [self labelWasSelected:selectedLabel];
                        break;
                    }
                }
                break;
            default:
                self.computerChoicesArray = [[NSMutableArray alloc] init];
                for (UILabel *label in self.gridLabelsArray) {
                    if ([label.text isEqualToString:@""]) {
                        [self.computerChoicesArray addObject:label];
                    }
                    int random = arc4random_uniform((int32_t)(self.computerChoicesArray.count));
                    self.computerChoicesArray[random] = [self labelWasSelected:self.computerChoicesArray[random]];
                    break;
                }
                [self whoWon:@"Computer"];
                [self changePlayerTurn:self.whichPlayerLabel];
                self.turn ++;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
