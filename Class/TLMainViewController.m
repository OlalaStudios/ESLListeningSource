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
    
    //load banner ads
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _adBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
    }
    else{
        _adBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    }
    
    [_adBannerView setAdUnitID:@"ca-app-pub-4039533744360639/6641559708"];
    [_adBannerView setDelegate:self];
    [_adBannerView setRootViewController:self];
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAllowsMultipleSelection:NO];
    [_tableView setSeparatorColor:[UIColor orangeColor]];
    
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

-(void)viewDidAppear:(BOOL)animated{
    
    [self writeUserData];
    
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[kGADSimulatorID,@"aea500effe80e30d5b9edfd352b1602d"];
    [_adBannerView loadRequest:request];
    
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
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, bannerView.bounds.size.height*2);
    bannerView.transform = transform;
    
    [UIView animateWithDuration:0.5 animations:^{
        bannerView.transform = CGAffineTransformIdentity;
    }];
}

-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"load banner fail");
    NSLog(@"%@",error);
}

#pragma mark - TLListeningView Delegate
-(void)didFinishLessonWithScore:(NSUInteger)score total:(NSUInteger)total{
    
    NSIndexPath *currentLesson = [_tableView indexPathForSelectedRow];
    NSDictionary *item = [_itemList objectAtIndex:currentLesson.row];
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
    return nil;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return _adBannerView.frame.size.height;
//}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _adBannerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return _adBannerView.frame.size.height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemList count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellNormal"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.textColor = [UIColor grayColor];
    
    NSDictionary *item = [_itemList objectAtIndex:indexPath.row];
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
    NSDictionary *item = [_itemList objectAtIndex:indexPath.row];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ActionSheet Level
- (IBAction)levelSelect:(id)sender {
    UIActionSheet *level = [[UIActionSheet alloc] initWithTitle:@"Choose level"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Easy",@"Medium",@"Difficult", nil];
    [level showInView:self.view];
}

- (IBAction)settingApp:(id)sender {
    
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //easy
        {
            [_btnLevel setTitle:@"easy"];
            _level = kEasy;
        }
            break;
        case 1: //medium
        {
            [_btnLevel setTitle:@"medium"];
            _level = kMedium;
        }
            break;
        case 2: //difficult
        {
            [_btnLevel setTitle:@"difficult"];
            _level = kDifficult;
        }
            break;
        default:
            break;
    }
    
    NSString *strlevel = [self convertStringLevel:_level];
    _itemList = [metaDic valueForKey:strlevel];
    [_tableView reloadData];
}
@end
