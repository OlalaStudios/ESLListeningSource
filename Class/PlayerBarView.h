//
//  PlayerBarView.h
//  StreamingAudio
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerBarButton.h"
#import "Reachability.h"

@protocol PlayerBarViewDelegate <NSObject>

-(void)didClickPlayer;
-(void)didFinishPlayer;
-(void)canClickPlayer;
-(void)didUpdateCurrentTime:(NSTimeInterval)ctime;

@end

typedef enum : NSUInteger {
    kCategory_None,
    kCategory_Local,
    kCategory_Internet,
} CategoryFile;

@interface PlayerBarView : UIView <PlayerButtonDelegate,AVAudioPlayerDelegate>{
    AVPlayer *player;
    AVPlayerItem *playerItem;
    
    id timeObserver;
}

@property id<PlayerBarViewDelegate>         playerBarDelegate;

@property(nonatomic, retain) AVAudioPlayer *audioPlayer;
@property(nonatomic, assign) CategoryFile  category;

@property NSString     *playerURL;
@property IBOutlet     PlayerBarButton      *playbutton;
@property IBOutlet     UISlider             *timeSlider;

-(void)loadContent;
-(void)start;
-(void)stop;

@end
