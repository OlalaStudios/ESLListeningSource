//
//  PlayerBarButton.m
//  StreamingAudio
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "PlayerBarButton.h"

@implementation PlayerBarButton
@synthesize playState = _playState;

-(void)awakeFromNib{
    _playState = kUnknow;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    if (_playState == kUnknow || _playState == kPlay) {
        [self.imageView setImage:[UIImage imageNamed:@"play"]];
    }
    else{
        [self.imageView setImage:[UIImage imageNamed:@"pause"]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (_playState == kUnknow || _playState == kPlay) {
        _playState = kPause;
        
        if (_playDelegate) {
            [_playDelegate play];
        }
    }
    else{
        _playState = kPlay;
        
        if (_playDelegate) {
            [_playDelegate pause];
        }
    }
    
    [self setNeedsDisplay];
}

@end
