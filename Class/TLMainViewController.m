//
//  TLMainViewController.m
//  ESLListening
//
//  Created by NguyenThanhLuan on 20/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "TLMainViewController.h"

@interface TLMainViewController ()

@end

@implementation TLMainViewController{
    NSDictionary *metaDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor colorWithRed:213.0f/255.0f
                                                   green:216.0f/255.0f
                                                    blue:220.0f/255.0f
                                                   alpha:1.0f]];
    [_tableView setAllowsMultipleSelection:NO];
    
    [_tableView registerNib:[UINib nibWithNibName:@"TLTableViewCell" bundle:nil] forCellReuseIdentifier:@"idCellNormal"];
    
    NSString *metadataPath = [[NSBundle mainBundle] pathForResource:@"metadata" ofType:@"plist"];
    
    _level = kEasy;
    
    metaDic = [[NSDictionary alloc] initWithContentsOfFile:metadataPath];
    NSString *strlevel = [self convertStringLevel:_level];
    _itemList = [metaDic valueForKey:strlevel];
    
    //User data
    _userData = [[NSMutableDictionary alloc] initWithDictionary:[self userData]];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor orangeColor]];
}

-(GADBannerView*)createBanner{
    //load banner ads
    
    GADBannerView *banner;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
    }
    else{
        banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    
    [banner setAdUnitID:@"ca-app-pub-4039533744360639/6641559708"];
    [banner setDelegate:self];
    [banner setRootViewController:self];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID,@"aea500effe80e30d5b9edfd352b1602d"];
    [banner loadRequest:request];
    
    return banner;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self writeUserData];
    
    [self runRateApp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)convertStringLevel:(TLevel)lev
{
    if (lev == kEasy) {
        return @"easy";
    }
    else if (lev == kMedium){
        return @"medium";
    }
    else if (lev == kDifficult){
        return @"difficult";
    }
    
    return @"easy";
}

-(void)writeUserData{
    NSString *strPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    strPath = [strPath stringByAppendingPathComponent:@"esllisteningUserData.plist"];
    
    if([_userData writeToFile:strPath atomically:YES]){
        NSLog(@"Save user data success");
    }
    else{
        NSLog(@"Save user data fail");
    }
}

-(NSDictionary*)userData{
    NSString *strPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    strPath = [strPath stringByAppendingPathComponent:@"esllisteningUserData.plist"];
    
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc] initWithContentsOfFile:strPath];
    
    if (!userDic) {
        userDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [userDic setValue:[[NSMutableDictionary alloc] initWithCapacity:0] forKey:[self convertStringLevel:kEasy]];
        [userDic setValue:[[NSMutableDictionary alloc] initWithCapacity:0] forKey:[self convertStringLevel:kMedium]];
        [userDic setValue:[[NSMutableDictionary alloc] initWithCapacity:0] forKey:[self convertStringLevel:kDifficult]];
    }
    
    return userDic;
}

#pragma mark - GADS Delegate
-(void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"Banner load successfull");
    
//    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, bannerView.bounds.size.height*2);
//    bannerView.transform = transform;
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        bannerView.transform = CGAffineTransformIdentity;
//    }];
}

-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"load banner fail");
    NSLog(@"%@",error);
}

#pragma mark - TLListeningView Delegate
-(void)didFinishLessonWithScore:(NSUInteger)score total:(NSUInteger)total{
    
    NSIndexPath *currentLesson = [_tableView indexPathForSelectedRow];
    NSDictionary *item = [_itemList objectAtIndex:currentLesson.section];
    NSString *title     = [item objectForKey:@"title"];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[_userData valueForKey:[self convertStringLevel:_level]]];
    
    NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:score],@"score",
                                                                        [NSNumber numberWithUnsignedInteger:total],@"total",
                                                                        nil];
    
    [dic setObject:result forKey:title];
    [_userData setValue:dic forKey:[self convertStringLevel:_level]];
    
    [_tableView reloadData];
}

#pragma mark - UITableView Delegate
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor colorWithRed:213.0f/255.0f
                                          green:216.0f/255.0f
                                           blue:220.0f/255.0f
                                          alpha:1.0f]];
    return v;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section % 7 == 6) {
        return [self createBanner];
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section % 7 == 6) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 100;
        }
        else{
            return 50;
        }
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_itemList count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellNormal"];
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    cell.textLabel.textColor = [UIColor grayColor];
    
    NSDictionary *item = [_itemList objectAtIndex:indexPath.section];
    NSString *title     = [item objectForKey:@"title"];
    
    [[cell title] setText:title];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[_userData valueForKey:[self convertStringLevel:_level]]];

    if (![dic valueForKey:title]) {
        [cell setState:kNone];
    }
    else{
        
        NSDictionary *lesson = [dic valueForKey:title];
        int score = [[lesson valueForKey:@"score"] intValue];
        int total = [[lesson valueForKey:@"total"] intValue];
        NSString *result = [NSString stringWithFormat:@"Result : %ld/%ld",(long)score,(long)total];
        
        if (((double)score/(double)total)*100 >= 80) {
            [cell setState:kPass];
        }
        else{
            [cell setState:kFail];
        }
        
        [[cell lastOpenDate] setText:result];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_itemList objectAtIndex:indexPath.section];
    
    NSString *title     = [item objectForKey:@"title"];
    NSString *playerurl = [item objectForKey:@"url"];
    NSString *scripturl = [item objectForKey:@"script"];
    NSArray  *questions = [item objectForKey:@"question"];
    
    TLListeningViewController *listeningController = (TLListeningViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"listeningview"];
    [listeningController setLessonDelegate:self];
    [listeningController setTitle:title];
    [listeningController setPlayerURL:playerurl];
    [listeningController setScriptURL:scripturl];
    [listeningController setQuestions:questions];
    
    [self.navigationController pushViewController:listeningController animated:YES];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)leverSelect_Action:(id)sender {
    
    if([_segmentLevel selectedSegmentIndex] == 0){
        _level = kEasy;
    }
    else if ([_segmentLevel selectedSegmentIndex] == 1){
        _level = kMedium;
    }
    else if ([_segmentLevel selectedSegmentIndex] == 2){
        _level = kDifficult;
    }
    
    NSString *strlevel = [self convertStringLevel:_level];
    _itemList = [metaDic valueForKey:strlevel];
    [_tableView reloadData];
}

-(void)runRateApp
{
    //1190545147
    [Appirater setAppId:@"1190545147"];    // Change for your "Your APP ID"
    [Appirater setDaysUntilPrompt:1];     // Days from first entered the app until prompt
    [Appirater setUsesUntilPrompt:12];     // Number of uses until prompt
    [Appirater setTimeBeforeReminding:2]; // Days until reminding if the user taps "remind me"
    //[Appirater setDebug:YES];           // If you set this to YES it will display all the time
    
    //... Perhaps do stuff
    
    [Appirater appLaunched:YES];
}
@end
