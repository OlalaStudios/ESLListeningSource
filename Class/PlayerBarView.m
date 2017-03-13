//
//  PlayerBarView.m
//  StreamingAudio
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "PlayerBarView.h"

static void *MyStreamingMovieViewControllerTimedMetadataObserverContext = &MyStreamingMovieViewControllerTimedMetadataObserverContext;
static void *MyStreamingMovieViewControllerRateObservationContext = &MyStreamingMovieViewControllerRateObservationContext;
static void *MyStreamingMovieViewControllerCurrentItemObservationContext = &MyStreamingMovieViewControllerCurrentItemObservationContext;
static void *MyStreamingMovieViewControllerPlayerItemStatusObserverContext = &MyStreamingMovieViewControllerPlayerItemStatusObserverContext;

NSString *kTracksKey		= @"tracks";
NSString *kStatusKey		= @"status";
NSString *kRateKey			= @"rate";
NSString *kPlayableKey		= @"playable";
NSString *kCurrentItemKey	= @"currentItem";
NSString *kTimedMetadataKey	= @"currentItem.timedMetadata";

@implementation PlayerBarView
@synthesize playerURL = _playerURL;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    
//    [super drawRect:rect];
//}

-(void)awakeFromNib{
    [self disablePlayerBar];
}

-(void)stop
{
    if (playerItem) {
        
        if ([player status] == AVPlayerStatusReadyToPlay) {
            [playerItem removeObserver:self forKeyPath:kStatusKey];
        }
        
        if ([(NSDictionary*)[[NSNotificationCenter defaultCenter] observationInfo] valueForKey:AVPlayerItemDidPlayToEndTimeNotification]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification context:(__bridge void *)(playerItem)];
        }
        
        playerItem = nil;
    }
    
    [self removePlayerTimeObserver];
    
    if (player) {
        [player pause];
        player = nil;
    }
}

-(void)dealloc
{
    if (playerItem) {
        
        if ([player status] == AVPlayerStatusReadyToPlay) {
            [playerItem removeObserver:self forKeyPath:kStatusKey];
        }

        if ([(NSDictionary*)[[NSNotificationCenter defaultCenter] observationInfo] valueForKey:AVPlayerItemDidPlayToEndTimeNotification]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification context:(__bridge void *)(playerItem)];
        }
        
        playerItem = nil;
    }
    
    [self removePlayerTimeObserver];
    
    if (player) {
        [player pause];
        player = nil;
    }
}

-(void)loadContent{
    
    Reachability *network = [Reachability reachabilityWithHostName:@"https://github.com"];
    
    if ([network currentReachabilityStatus] != NotReachable) {
        
        NSURL *streamURL = [NSURL URLWithString:_playerURL];
        if ([streamURL scheme]) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:streamURL options:nil];
            NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];

            [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
             ^{
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                                    [self prepareToPlayAsset:asset withKeys:requestedKeys];
                                });
             }];
        }
    }
    else{
        [self showNetworkError];
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

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
    
    playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [playerItem addObserver:self
                 forKeyPath:kStatusKey
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:MyStreamingMovieViewControllerPlayerItemStatusObserverContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playeritemDidReachtoEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
    
    if (!player) {
        player = [AVPlayer playerWithPlayerItem:playerItem];
    }
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self disablePlayerBar];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(CMTime)Streamduration{
    AVPlayerItem *item = [player currentItem];
    if (item.status == AVPlayerStatusReadyToPlay) {
        return item.duration;
    }
    
    return kCMTimeInvalid;
}

-(void)enablePlayerBar{
    [_playbutton setEnabled:YES];
    [_timeSlider setEnabled:YES];
    
    [_playbutton setPlayDelegate:self];
    
    if (_playerBarDelegate) {
        [_playerBarDelegate canClickPlayer];
    }
}

-(void)disablePlayerBar{
    [_playbutton setEnabled:NO];
    [_timeSlider setEnabled:NO];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext){
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");
                [self enablePlayerBar];
                [self initScrubberTimer];
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"AVPlayerStatusFailed");
                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark Scrubber control
-(void)initScrubberTimer
{
    double interval = .1f;
    
    CMTime playerDuration = [self Streamduration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    [_timeSlider setMaximumValue:duration];
    [_timeSlider setMinimumValue:0];
    [_timeSlider setValue:0];
    
    NSLog(@"duration : %f",duration);
    
    /* Update the scrubber during normal playback. */
    timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                        queue:NULL
                                                   usingBlock:^(CMTime time) {
                                                       [self syncScrubber];
                                                   }];
}

- (void)syncScrubber
{
    CMTime playerDuration = [self Streamduration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0))
    {
        double time = CMTimeGetSeconds([player currentTime]);
        [_timeSlider setValue:time];
    }
}

-(void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
}

#pragma mark - Player Notification
-(void)playeritemDidReachtoEnd:(NSNotification*)notification{
    NSLog(@"end of audio");
    
    [_playbutton setPlayState:kPlay];
    [_playbutton setNeedsDisplay];
    
    [player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
    
    //callback for check score
    if (_playerBarDelegate) {
        [_playerBarDelegate didFinishPlayer];
    }
}


#pragma mark - Play Button delegate
-(void)play{
    [player play];
    
    //callback for show result
    if (_playerBarDelegate) {
        [_playerBarDelegate didClickPlayer];
    }
}

-(void)pause{
    [player pause];
}

#pragma mark - UINavigationBar


@end
