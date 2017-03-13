//
//  TLPageViewController.h
//  PageView
//
//  Created by NguyenThanhLuan on 12/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TLPageViewControllerDelegate <NSObject>

-(void)GetStart;

@end

@interface TLPageViewController : UIViewController

@property id<TLPageViewControllerDelegate>          delegate;

@property (assign,nonatomic) NSInteger              index;
@property (weak, nonatomic) IBOutlet UIButton       *btnStart;
@property (weak, nonatomic) IBOutlet UIImageView    *avata;
@property (weak, nonatomic) IBOutlet UILabel *pageDescription;

- (IBAction)getStart:(id)sender;

@end
