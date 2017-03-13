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

typedef enum Answer: NSUInteger {
    AnswerA,
    AnswerB,
    AnswerC,
} Answer;

@interface TLListeningViewController ()

@end

@implementation TLListeningViewController
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
    [_tableQuestion setSeparatorColor:[UIColor orangeColor]];
    [_tableQuestion registerNib:[UINib nibWithNibName:@"TLQuestionTableViewCell" bundle:nil] forCellReuseIdentifier:@"idcellquestion"];
    [_tableQuestion registerNib:[UINib nibWithNibName:@"TLQuestionHeaderCell" bundle:nil] forHeaderFooterViewReuseIdentifier:@"idheaderquestion"];
    
    [self.navigationController.navigationBar setTintColor:[UIColor orangeColor]];
    [self.navigationController setTitle:self.title];
    
    [_playerBar setPlayerURL:playerPath];
    [_playerBar setPlayerBarDelegate:self];
    [_playerBar loadContent];
    
    //show ads
    _interstitial = [self createAndLoadInterstitial];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    _adsloaded = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if (!_adsloaded) {
        [_playerBar stop];
    }
    
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
    if (!_startLearning) {
        [ad presentFromRootViewController:self];
        _adsloaded = YES;
    }
    else{
        _interstitial = ad;
        _adsloaded = NO;
    }
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
    UIAlertView *scoreAlert = [[UIAlertView alloc] initWithTitle:@"Your Score" message:messageAnswer delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [scoreAlert show];
    
    if (!_adsloaded) {
        [_interstitial presentFromRootViewController:self];
        _adsloaded = YES;
    }
}

-(void)didClickPlayer
{
    _startLearning = YES;
}

-(void)canClickPlayer
{
    
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

-(void)setPlayerURL:(NSString *)url{
    playerPath = url;
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
    }
    else{
        [_transcripView setHidden:YES];
        [_tableQuestion setHidden:NO];
    }
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
