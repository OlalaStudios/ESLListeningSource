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

@end

@interface PlayerBarView : UIView <PlayerButtonDelegate>{
    AVPlayer *player;
    AVPlayerItem *playerItem;
    
    id timeObserver;
}

@property id<PlayerBarViewDelegate>         playerBarDelegate;

@property NSString     *playerURL;
@property IBOutlet     PlayerBarButton      *playbutton;
@property IBOutlet     UISlider             *timeSlider;

-(void)loadContent;
-(void)stop;

@end
