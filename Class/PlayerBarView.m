//
//  PlayerBarView.m
//  StreamingAudio
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "PlayerBarView.h"

@implementation PlayerBarView{
    NSTimer *localTimer;
}
@synthesize playerURL = _playerURL;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4.0];
    
    UIColor *color = [UIColor colorWithRed:255/255.0 green:243/255.0 blue:230/255.0 alpha:1.0];
    [color setFill];
    [path fill];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [_playbutton setPlayDelegate:self];
}

-(void)stop
{
    if (_category == kCategory_Internet) {
        if (_internetPlayer) {
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            [_internetPlayer removeObserver:self forKeyPath:@"status"];
            
            [_internetPlayer pause];
            _internetPlayer = nil;
        }
    }
    else{
        [_audioPlayer stop];
    }
}

-(void)dealloc
{
    if (_internetPlayer) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_internetPlayer removeObserver:self forKeyPath:@"status"];
        
        [_internetPlayer pause];
        _internetPlayer = nil;
    }
}

-(void)loadContent{
    
    if (_category == kCategory_Internet) {
        
        Reachability *network = [Reachability reachabilityWithHostName:@"https://github.com"];
        if ([network currentReachabilityStatus] != NotReachable) {
            
        }
        else{
            [self showNetworkError];
        }
    }
    else{
        NSURL *soundFileURL = [NSURL fileURLWithPath:_playerURL];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:NULL];
        [_audioPlayer setDelegate:self];
        [_audioPlayer setVolume:1.0];
    }
}

-(void)showNetworkError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
                                                    message:@"Check your internet connection and try again!"
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)didReachtoEnd{
    
    if (_category == kCategory_Internet) {

        [_internetPlayer seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    }
    else{
        
    }
    
    [localTimer invalidate];
    
    [_playbutton setPlayState:kPlay];
    [_playbutton setNeedsDisplay];
    
    [self resetProgressBar];
    
    //callback for check score
    if (_playerBarDelegate) {
        [_playerBarDelegate didFinishPlayer];
    }
}

#pragma mark - Update Progress

-(void)initProgressBar{
    
    double duration;
    
    if (_category == kCategory_Internet) {
        duration = CMTimeGetSeconds(_internetPlayer.currentItem.asset.duration);
    }
    else{
        duration = [_audioPlayer duration];
    }
    
    [_timeSlider setMaximumValue:duration];
    [_timeSlider setMinimumValue:0];
    [_timeSlider setValue:0];
}

-(void)resetProgressBar{
    if (_category == kCategory_Internet) {
        
    }
    else{
        
    }
    
    [_timeSlider setValue:0];
}

-(void)updateAudioProgress{
    if (_category == kCategory_Internet) {
        double currentTime = CMTimeGetSeconds(_internetPlayer.currentItem.currentTime);
        
        [_timeSlider setValue:currentTime];
        
        //callback for update progress
        if (_playerBarDelegate) {
            [_playerBarDelegate didUpdateCurrentTime:currentTime];
        }
    }
    else{
        [_timeSlider setValue:[_audioPlayer currentTime]];
        
        //callback for update progress
        if (_playerBarDelegate) {
            [_playerBarDelegate didUpdateCurrentTime:[_audioPlayer currentTime]];
        }
    }
}

#pragma mark - Player Notification
-(void)playeritemDidReachtoEnd:(NSNotification*)notification{
    NSLog(@"end of audio");
    
    [self didReachtoEnd];
}

#pragma mark - Play Button delegate
-(void)play{
    
    if (_category == kCategory_Internet) {
        
        if (!_internetPlayer) {
            AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:_playerURL]];
            self.internetPlayer = player;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.internetPlayer currentItem]];
            
            _internetPlayerItem = [self.internetPlayer currentItem];
            [self.internetPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
            localTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioProgress) userInfo:nil repeats:YES];
            
            [self.internetPlayer play];
            
            //callback for show loading
            if (_playerBarDelegate) {
                [_playerBarDelegate didClickPlayer];
            }
        }
        else{
            [_internetPlayer play];
        }
        
    }
    else{
        [self initProgressBar];
        
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        
        localTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioProgress) userInfo:nil repeats:YES];
        
        //callback for show loading
        if (_playerBarDelegate) {
            [_playerBarDelegate didClickPlayer];
        }
    }
}

-(void)pause{
    if (_category == kCategory_Internet) {
        [_internetPlayer pause];
    }
    else{
        [_audioPlayer pause];
    }
}

#pragma mark - AVAudioPlayerDelegate - Local
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self didReachtoEnd];
}

#pragma mark - AVAudioPlayerDelegate - Internet
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.internetPlayer && [keyPath isEqualToString:@"status"]) {
        
        [_playbutton setPlayState:kPlay];
        
        if (self.internetPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (self.internetPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            
            [self initProgressBar];
            [_playbutton setPlayState:kPause];
            
        } else if (self.internetPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
        
        //callback for show result
        if (_playerBarDelegate) {
            [_playerBarDelegate canClickPlayer];
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    [self didReachtoEnd];
}

@end
