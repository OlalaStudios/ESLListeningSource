//
//  TLListeningViewController.h
//  ESLListening
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DownloadButton/PKDownloadButton.h>
#import "PlayerBarView.h"

@import GoogleMobileAds;

@protocol TLListeningViewDelegate <NSObject>

-(void)didFinishLessonWithScore:(NSUInteger)score total:(NSUInteger)total;

@end

@interface TLListeningViewController : UIViewController <PlayerBarViewDelegate,UITableViewDelegate,UITableViewDataSource,GADInterstitialDelegate,PKDownloadButtonDelegate>{
    
    NSString *internetPath;
    NSString *localPath;
    NSString *scriptPath;
    
    NSArray *questions;
    NSUInteger score;
    NSUInteger total;
    
    BOOL       _startLearning;
    
    GADInterstitial *_interstitial;
    BOOL        _adsloaded;
}

@property id<TLListeningViewDelegate>   lessonDelegate;

@property (weak, nonatomic) IBOutlet PlayerBarView  *playerBar;
@property (weak, nonatomic) IBOutlet UITextView     *transcripView;
@property (weak, nonatomic) IBOutlet UITableView    *tableQuestion;
@property (weak, nonatomic) IBOutlet UILabel        *currentTime;
@property (weak, nonatomic) IBOutlet PKDownloadButton *btdownload;

-(void)setPlayerURL:(NSString*)url;
-(void)setScriptURL:(NSString*)url;
-(void)setQuestions:(NSArray*)question;

- (IBAction)showScript:(id)sender;

- (void)stopListening;

@end
