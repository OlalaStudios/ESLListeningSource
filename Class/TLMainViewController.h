//
//  TLMainViewController.h
//  ESLListening
//
//  Created by NguyenThanhLuan on 20/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLListeningViewController.h"
#import "TLTableViewCell.h"
#import "Appirater.h"
#import "AppiraterDelegate.h"

@import GoogleMobileAds;

typedef enum TLevel: NSUInteger {
    kEasy,
    kMedium,
    kDifficult,
} TLevel;

@interface TLMainViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,TLListeningViewDelegate,GADBannerViewDelegate,AppiraterDelegate,GADInterstitialDelegate>{
    
    NSMutableArray          *_itemList;
    TLevel                  _level;
    
    NSMutableDictionary     *_userData;
    
    GADBannerView           *_adBannerView;
    GADInterstitial         *_interstitial;
    
    NSInteger               displayCount;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnLevel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *setting;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentLevel;

- (IBAction)levelSelect:(id)sender;
- (IBAction)settingApp:(id)sender;
- (IBAction)leverSelect_Action:(id)sender;


@end
