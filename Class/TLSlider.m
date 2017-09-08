//
//  TLSlider.m
//  ESLListening
//
//  Created by Olala on 9/5/17.
//  Copyright © 2017 Olala. All rights reserved.
//

#import "TLSlider.h"

@implementation TLSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
}

@end
