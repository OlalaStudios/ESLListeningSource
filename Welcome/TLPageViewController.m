//
//  TLPageViewController.m
//  PageView
//
//  Created by NguyenThanhLuan on 12/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "TLPageViewController.h"

@interface TLPageViewController()

@end

@implementation TLPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_btnStart setHidden:YES];
    [_pageDescription setHidden:NO];
    
    switch (self.index) {
        case 0:
            [_avata setImage:[UIImage imageNamed:@"checklist.png"]];
            [_pageDescription setText:@"This app have over 200 lessons with three level (easy, medium, difficult)"];
            break;
        case 1:
            [_avata setImage:[UIImage imageNamed:@"listening.png"]];
            [_pageDescription setText:@"Each lesson is a conversations that help you improve listening skill and new vocabrary in context"];
            break;
        case 2:
            [_avata setImage:[UIImage imageNamed:@"reading.png"]];
            [_pageDescription setText:@"Have 5 question you should answer for practice"];
            break;
        case 3:
            [_avata setImage:[UIImage imageNamed:@"transcript.png"]];
            [_pageDescription setText:@"You can view transcript to verify something after complete lesson"];
            break;
        case 4:
            [_avata setImage:[UIImage imageNamed:@"esl.png"]];
            [_pageDescription setHidden:YES];
            [_btnStart setHidden:NO];
            break;
        default:
            break;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getStart:(id)sender {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(GetStart)]) {
        [_delegate GetStart];
    }
}
@end
