//
//  MainViewController.m
//  qtum wallet
//
//  Created by Sharaev Vladimir on 18.11.16.
//  Copyright © 2016 Designsters. All rights reserved.
//

#import "MainViewController.h"
#import "HistoryTableViewCell.h"
#import "BlockchainInfoManager.h"
#import "NewPaymentViewController.h"
#import "HistoryElement.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL balanceLoaded;
@property (nonatomic) BOOL historyLoaded;
@property (nonatomic) NSArray *historyArray;

- (IBAction)refreshButtonWasPressed:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.balanceLabel.text = @"0";
    
    self.historyLoaded = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // get all dataForScreen
    [self refreshButtonWasPressed:nil];
}

- (IBAction)refreshButtonWasPressed:(id)sender
{
    [SVProgressHUD show];
    
    [self getBalance];
    [self getHistory];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryTableViewCell"];
    if (!cell) {
        cell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryTableViewCell"];
    }
    
    HistoryElement *element = self.historyArray[indexPath.row];
    cell.addressLabel.text = element.address;
    cell.amountLabel.text = element.amountString;
    cell.dateLabel.text = element.dateString;
    
    if (element.send) {
        cell.typeImage.image = [UIImage imageNamed:@"send"];
        cell.typeLabel.text = @"Sent";
    }else{
        cell.typeImage.image = [UIImage imageNamed:@"received"];
        cell.typeLabel.text = @"Received";
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.historyArray.count;
}

#pragma mark - Methods

- (void)getBalance
{
    self.balanceLoaded = NO;
    
    __weak typeof(self) weakSelf = self;
    [BlockchainInfoManager getBalanceForAllAddresesWithSuccessHandler:^(double responseObject) {
        weakSelf.balanceLabel.text = [NSString stringWithFormat:@"%lf", responseObject];
        weakSelf.balanceLoaded = YES;
        
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD dismiss];
        }
    } andFailureHandler:^(NSError *error, NSString *message) {
        weakSelf.balanceLoaded = YES;
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD showErrorWithStatus:@"Some error"];
        }
    }];
}

- (void)getHistory
{
    self.historyLoaded = NO;
    
    __weak typeof(self) weakSelf = self;
    [BlockchainInfoManager getHistoryForAllAddresesWithSuccessHandler:^(NSArray *responseObject) {
        weakSelf.historyLoaded = YES;
        weakSelf.historyArray = responseObject;
        [weakSelf.tableView reloadData];
        
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD dismiss];
        }
        NSLog(@"%@", responseObject);
    } andFailureHandler:^(NSError *error, NSString *message) {
        weakSelf.historyLoaded = YES;
        if (weakSelf.balanceLoaded && weakSelf.historyLoaded) {
            [SVProgressHUD showErrorWithStatus:@"Some error"];
        }
    }];
}

#pragma merk - Seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"FromMainToNewPayment"]) {
        NewPaymentViewController *vc = (NewPaymentViewController *)segue.destinationViewController;
        
        vc.currentBalance = self.balanceLabel.text;
    }
}
@end