//
//  ViewController.m
//  ESLListening
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //page
    [self setupPageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupPageView{
    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstLaunch"];
    BOOL firstlaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunch"];
    
    if (!firstlaunch) {
        self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        
        self.pageController.dataSource = self;
        self.pageController.delegate = self;
        
        [[self.pageController view] setFrame:[[self view] bounds]];
        
        TLPageViewController *initialView = [self viewControllerAtIndex:0];
        
        NSArray *viewControllers = [NSArray arrayWithObject:initialView];
        
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        [self addChildViewController:self.pageController];
        [[self view] addSubview:[self.pageController view]];
        
        [self.pageController didMoveToParentViewController:self];
        [self addPageControll];
    }
    else{
        [self GetStart];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLaunch"];
}

#pragma mark
#pragma mark PageViewControllerDelegate
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    TLPageViewController *pageContentView = (TLPageViewController*)pendingViewControllers[0];
    [self.pageControll setCurrentPage:[pageContentView index]];
    [self.pageControll updateCurrentPageDisplay];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [(TLPageViewController*)viewController index];
    
    index++;
    
    if (index > 4) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [(TLPageViewController*)viewController index];
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    
    return [self viewControllerAtIndex:index];
}

-(TLPageViewController*)viewControllerAtIndex:(NSInteger)index
{
    TLPageViewController *pageviewcontroller = [[TLPageViewController alloc] initWithNibName:@"TLPageViewController" bundle:nil];
    [pageviewcontroller setDelegate:self];
    pageviewcontroller.index = index;
    [pageviewcontroller.view setFrame:[[self view] frame]];
    
    return pageviewcontroller;
}

-(void)addPageControll
{
    self.pageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    [self.pageControll setTintColor:[UIColor orangeColor]];
    [self.pageControll setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [self.pageControll setHidesForSinglePage:YES];
    [self.pageControll setNumberOfPages:5];
    [self.pageControll setCurrentPage:0];
    [self.view addSubview:self.pageControll];
}

-(void)GetStart
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.pageController.view setAlpha:0.0];
        [self.pageControll setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.pageController.view removeFromSuperview];
        [self.pageControll removeFromSuperview];
        
        //mainview
        TLMainViewController *mainviewcontroller = (TLMainViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"mainview"];
        UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:mainviewcontroller];
        [self presentViewController:navigationController animated:YES completion:nil];
    }];
}

@end
