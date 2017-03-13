//
//  ViewController.h
//  ESLListening
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLPageViewController.h"
#import "TLMainViewController.h"

@interface ViewController : UIViewController <UIPageViewControllerDelegate,UIPageViewControllerDataSource,TLPageViewControllerDelegate>{
    NSMutableArray          *_itemList;
}

@property (strong,nonatomic) UIPageViewController   *pageController;
@property (strong,nonatomic) UIPageControl          *pageControll;



@end

