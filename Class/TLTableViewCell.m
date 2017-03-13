//
//  TLTableViewCell.m
//  ESLListening
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "TLTableViewCell.h"

@implementation TLTableViewCell
@synthesize state = _state;
@synthesize avata = _avata;
@synthesize title = _title;

-(void)setState:(LessonState)state{
    _state = state;
    
    //code here
    if (_state == kNone) {
        [_avata setImage:[UIImage imageNamed:@"music.png"]];
        [_lastOpenDate setText:@""];
    }
    else if (_state == kPass){
        [_avata setImage:[UIImage imageNamed:@"pass.png"]];
    }
    else if (_state == kFail){
        [_avata setImage:[UIImage imageNamed:@"fail.png"]];
    }
}

-(LessonState)state{
    return _state;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _state = kNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
