//
//  TLQuestionHeaderCell.m
//  ESLListening
//
//  Created by NguyenThanhLuan on 22/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "TLQuestionHeaderCell.h"

@implementation TLQuestionHeaderCell

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    UIColor *color = [UIColor colorWithRed:238/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    
    [color setFill];
    [path fill];
    
    [super drawRect:rect];
}

@end
