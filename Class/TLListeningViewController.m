//
//  TLListeningViewController.m
//  ESLListening
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import "TLListeningViewController.h"
#import "TLQuestionTableViewCell.h"
#import "TLQuestionHeaderCell.h"
#import "UIImage+PKDownloadButton.h"
#import <DRPLoadingSpinner/DRPLoadingSpinner.h>
#import <SCLAlertView_Objective_C/SCLAlertView.h>
#import <RZSquaresLoading/RZSquaresLoading.h>

#define ESLFolderName  @"ESLAudio"

typedef enum Answer: NSUInteger {
    AnswerA,
    AnswerB,
    AnswerC,
} Answer;

@interface TLListeningViewController (){
    RZSquaresLoading *loadingView;
}

@end

@implementation TLListeningViewController{
    NSMutableData *receivedData;
    long long expectedBytes;
    
    CategoryFile _category;
}
@synthesize lessonDelegate = _lessonDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    score = 0;
    total = 0;
    
    _startLearning = false;
    
    [_transcripView setHidden:YES];
    
    [_tableQuestion setHidden:NO];
    [_tableQuestion setAutoresizesSubviews:YES];
    [[_tableQuestion tableHeaderView] setAutoresizesSubviews:YES];
    [[_tableQuestion tableHeaderView] setNeedsLayout];
    [[_tableQuestion tableHeaderView] layoutIfNeeded];
    [_tableQuestion setAllowsMultipleSelection:YES];
    [_tableQuestion registerNib:[UINib nibWithNibName:@"TLQuestionTableViewCell" bundle:nil] forCellReuseIdentifier:@"idcellquestion"];
    [_tableQuestion registerNib:[UINib nibWithNibName:@"TLQuestionHeaderCell" bundle:nil] forHeaderFooterViewReuseIdentifier:@"idheaderquestion"];
    
    [self.navigationController.navigationBar setTintColor:[UIColor orangeColor]];
    [self.navigationController setTitle:self.title];
    
    [self setupDownloadButton];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *audiopath = [[documentsDirectory stringByAppendingPathComponent:ESLFolderName] stringByAppendingPathComponent:[self.title stringByAppendingString:@".mp3"]];
    
    _category = kCategory_None;
    
    if ([self checklocalfile:audiopath]) {
        
        localPath = audiopath;
        _category = kCategory_Local;
        
        [_playerBar setPlayerURL:localPath];
        [_playerBar setPlayerBarDelegate:self];
        [_playerBar setCategory:_category];
        [_playerBar loadContent];
        
        [_btdownload setState:kPKDownloadButtonState_Downloaded];
    }
    else{
        
        _category = kCategory_Internet;
        
        [_playerBar setPlayerURL:internetPath];
        [_playerBar setPlayerBarDelegate:self];
        [_playerBar setCategory:_category];
        [_playerBar loadContent];
        
        [_btdownload setState:kPKDownloadButtonState_StartDownload];
    }
    
    //show ads
    if (_enableAds) {
        _interstitial = [self createAndLoadInterstitial];
    }
}

-(void)setupDownloadButton{

    self.btdownload.stopDownloadButton.tintColor = [UIColor orangeColor];
    self.btdownload.stopDownloadButton.filledLineStyleOuter = YES;
    
    self.btdownload.pendingView.tintColor = [UIColor orangeColor];
    self.btdownload.pendingView.radius = 24.f;
    self.btdownload.pendingView.emptyLineRadians = 2.f;
    self.btdownload.pendingView.spinTime = 3.f;
    self.btdownload.delegate = self;
    
    [self.btdownload.startDownloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [self.btdownload.downloadedButton setImage:[UIImage imageNamed:@"downloaded"] forState:UIControlStateNormal];
}

-(BOOL)checklocalfile:(NSString*)strUrl{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:strUrl]) {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    _adsloaded = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [_playerBar stop];
    
    if (_lessonDelegate && _startLearning) {
        [_lessonDelegate didFinishLessonWithScore:score total:5];
    }
}

-(GADInterstitial*)createAndLoadInterstitial
{
    _interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-4039533744360639/8118292903"];
    
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[kGADSimulatorID,@"aea500effe80e30d5b9edfd352b1602d"];
    
    [_interstitial setDelegate:self];
    [_interstitial loadRequest:request];
    
    _adsloaded = NO;
    
    return _interstitial;
}

#pragma mark - Ads Delegate
-(void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
//    if (!_startLearning) {
//        [ad presentFromRootViewController:self];
//    }
//    else{
        _interstitial = ad;
//    }
    
    _adsloaded = YES;

    NSLog(@"Success to load interstitial ads");
}

-(void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad
{
    _adsloaded = NO;
    NSLog(@"Fail to load interstitial ads");
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PKDownloadButtonDelegate

- (void)downloadButtonTapped:(PKDownloadButton *)downloadButton
                currentState:(PKDownloadButtonState)state {
    switch (state) {
        case kPKDownloadButtonState_StartDownload:
            self.btdownload.state = kPKDownloadButtonState_Pending;
            [self startDownload:internetPath];
            break;
        case kPKDownloadButtonState_Pending:
            self.btdownload.state = kPKDownloadButtonState_StartDownload;
            break;
        case kPKDownloadButtonState_Downloading:
            self.btdownload.state = kPKDownloadButtonState_StartDownload;
            break;
        case kPKDownloadButtonState_Downloaded:
            self.btdownload.state = kPKDownloadButtonState_StartDownload;
            [self removeDownloaded:localPath];
            break;
        default:
            NSAssert(NO, @"unsupported state");
            break;
    }
}


#pragma mark - Player Bar Delegate
-(void)didFinishPlayer{
    
    //show score
    NSLog(@"Show score");
    
    NSUInteger totalquestion = [questions count];
    NSArray *answers = [_tableQuestion indexPathsForSelectedRows];
    
    score = 0;
    total = totalquestion;
    
    for (NSIndexPath *answer in answers) {
        
        NSDictionary *question;
        
        NSLog(@"question number %ld",(long)answer.section);
        question = [questions objectAtIndex:answer.section];
        
        NSString *dapan = [question valueForKey:@"answer"];
        
        score = score + [self checkAnswer:answer anwser:dapan];
    }
    
    NSString *messageAnswer = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)score,(unsigned long)totalquestion];
    SCLAlertView *scoreAlert = [[SCLAlertView alloc] initWithNewWindow];
    [scoreAlert addButton:@"Done" actionBlock:^{
        
        if (_adsloaded) {
            [_interstitial presentFromRootViewController:self];
            _adsloaded = NO;
        }
        
    }];
    
    [scoreAlert showCustom:[UIImage imageNamed:@"olalaicon"] color:[UIColor orangeColor] title:@"Your Score" subTitle:messageAnswer closeButtonTitle:nil duration:0.0f];
}

-(void)didUpdateCurrentTime:(NSTimeInterval)ctime{
    
    NSUInteger durationSeconds = ctime;
    NSUInteger minutes = floor(durationSeconds % 3600 / 60);
    NSUInteger seconds = floor(durationSeconds % 3600 % 60);
    NSString *time = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)minutes, seconds];
    
    [_currentTime setText:time];
}

-(void)didClickPlayer
{
    _startLearning = YES;
    
    CGRect rect = [self.view bounds];

    if (_category == kCategory_Internet) {
        loadingView = [[RZSquaresLoading alloc] initWithFrame:CGRectMake(rect.size.width/2 - 36, rect.size.height/2 - 36, 72, 72)];
        loadingView.color = [UIColor orangeColor];
        
        [self.view setAlpha:0.5];
        [self.view addSubview:loadingView];
    }
}

-(void)canClickPlayer
{
    if (_category == kCategory_Internet) {
        [self.view setAlpha:1.0];
        [loadingView removeFromSuperview];
    }
}

-(int)checkAnswer:(NSIndexPath*)selection anwser:(NSString*)anwser{
    
    int dapan = -1;
    
    if ([anwser isEqualToString:@"A"]) {
        dapan = 0;
    }
    else if ([anwser isEqualToString:@"B"]){
        dapan = 1;
    }
    else if ([anwser isEqualToString:@"C"]){
        dapan = 2;
    }
    
    if (dapan == selection.row) {
        return 1;
    }
    
    return 0;
}

-(void)setEnableAds:(BOOL)enableAds{
    _enableAds = enableAds;
}

-(void)setPlayerURL:(NSString *)url{
    internetPath = url;
}

-(void)setScriptURL:(NSString *)url{
    scriptPath = url;
}

-(void)setQuestions:(NSArray *)question{
    questions = question;
}

- (IBAction)showScript:(id)sender {
    
    if ([_transcripView isHidden]) {
        
        [_transcripView setHidden:NO];
        [_tableQuestion setHidden:YES];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:scriptPath ofType:@"rtf"];
        _transcripView.attributedText =[[NSAttributedString alloc] initWithFileURL:[NSURL fileURLWithPath:filePath] options:nil documentAttributes:nil error:nil];
        
        [sender setTitle:@"question"];
    }
    else{
        [_transcripView setHidden:YES];
        [_tableQuestion setHidden:NO];
        
        [sender setTitle:@"script"];
    }
}

#pragma mark - Download Delegate
-(void)startDownload:(NSString*)strUrl{
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest
                                                                   delegate:self
                                                           startImmediately:YES];
    
    [connection start];
}

-(void)removeDownloaded:(NSString*)strUrl{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:strUrl]) {
        [[NSFileManager defaultManager] removeItemAtPath:strUrl error:nil];
        
        _category = kCategory_Internet;
        
        [_playerBar setPlayerURL:internetPath];
        [_playerBar setPlayerBarDelegate:self];
        [_playerBar setCategory:_category];
        [_playerBar loadContent];
        
        [_btdownload setState:kPKDownloadButtonState_StartDownload];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [receivedData setLength:0];
    expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    self.btdownload.state = kPKDownloadButtonState_Downloading;
    
    [receivedData appendData:data];
    float progressive = (float)[receivedData length] / (float)expectedBytes;
    
    self.btdownload.stopDownloadButton.progress = progressive;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.btdownload.state = kPKDownloadButtonState_Pending;
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.btdownload.state = kPKDownloadButtonState_Downloaded;
    
    
    // Use GCD's background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *audiopath = [[documentsDirectory stringByAppendingPathComponent:ESLFolderName] stringByAppendingPathComponent:[self.title stringByAppendingString:@".mp3"]];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if([receivedData writeToFile:audiopath atomically:YES]){
            NSLog(@"save file success");
            
            localPath = audiopath;
            _category = kCategory_Local;
            
            [_playerBar setPlayerURL:localPath];
            [_playerBar setPlayerBarDelegate:self];
            [_playerBar setCategory:_category];
            [_playerBar loadContent];
            
            [_btdownload setState:kPKDownloadButtonState_Downloaded];
        }
        else{
            NSLog(@"save file fail");
        }
    });
}

#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return questions.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    TLQuestionHeaderCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"idheaderquestion"];
    
    /* Section header is in 0th index... */
    NSDictionary *qDic = [questions objectAtIndex:section];
    
    [cell.label setText:[qDic valueForKey:@"question"]];
    [cell.label setTextColor:[UIColor grayColor]];
    
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idcellquestion"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.label setFont:[UIFont systemFontOfSize:12]];
    [cell.label setTextColor:[UIColor grayColor]];
    
    if([[tableView indexPathsForSelectedRows] containsObject:indexPath]){
        cell.label.textColor = [UIColor orangeColor];
    }
    
    NSDictionary *qDic = [questions objectAtIndex:indexPath.section];
    NSString    *qNum = @"";
    
    switch (indexPath.row) {
        case 0:
            qNum = [NSString stringWithFormat:@"A. %@",[qDic valueForKey:@"A"]];
            break;
        case 1:
            qNum = [NSString stringWithFormat:@"B. %@",[qDic valueForKey:@"B"]];
            break;
        case 2:
            qNum = [NSString stringWithFormat:@"C. %@",[qDic valueForKey:@"C"]];
            break;
        default:
            break;
    }
    
    cell.label.text = qNum;
    
    return cell;
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *indexpaths = [tableView indexPathsForSelectedRows];
    for (NSIndexPath* path in indexpaths) {
        
        if (path.section == indexPath.section)
        {
            [tableView deselectRowAtIndexPath:path animated:NO];
            
            [(TLQuestionTableViewCell*)[tableView cellForRowAtIndexPath:path] label].textColor = [UIColor grayColor];
        }
    }
    
    TLQuestionTableViewCell *cell = (TLQuestionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.label.textColor = [UIColor orangeColor];
    
    return indexPath;
}

-(NSIndexPath*)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
