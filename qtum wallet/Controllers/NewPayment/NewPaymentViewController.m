//
//  NewPaymentViewController.m
//  qtum wallet
//
//  Created by Sharaev Vladimir on 18.11.16.
//  Copyright © 2016 Designsters. All rights reserved.
//

#import "NewPaymentViewController.h"
#import "TransactionManager.h"
#import "QRCodeViewController.h"
#import "TextFieldWithLine.h"

@interface NewPaymentViewController () <UITextFieldDelegate, QRCodeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet TextFieldWithLine *addressTextField;
@property (weak, nonatomic) IBOutlet UIView *adressUnderlineView;
@property (weak, nonatomic) IBOutlet TextFieldWithLine *amountTextField;
@property (weak, nonatomic) IBOutlet UIView *amountUnderlineView;
@property (weak, nonatomic) IBOutlet TextFieldWithLine *pinTextField;
@property (weak, nonatomic) IBOutlet UIView *pinUnderlineView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *residueValueLabel;
@property (strong,nonatomic) NSString* adress;
@property (strong,nonatomic) NSString* amount;


- (IBAction)backbuttonPressed:(id)sender;
- (IBAction)makePaymentButtonWasPressed:(id)sender;
@end

@implementation NewPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self addDoneButtonToAmountTextField];
    
    if (self.dictionary) {
        [self qrCodeScanned:self.dictionary];
    }
    self.residueValueLabel.text = self.currentBalance;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateControls];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

-(void)updateControls{
    self.addressTextField.text = self.adress;
    self.amountTextField.text = self.amount;
}

#pragma mark - iMessage

-(void)setAdress:(NSString*)adress andValue:(NSString*)amount{
    self.adress = adress;
    self.amount = amount;
    [self updateControls];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    UIColor* underlineColor = [UIColor colorWithRed:54/255. green:185/255. blue:200/255. alpha:1];

    if ([textField isEqual:self.addressTextField]) {
        self.adressUnderlineView.backgroundColor = underlineColor;
    }else if ([textField isEqual:self.amountTextField]) {
        self.amountUnderlineView.backgroundColor = underlineColor;
    }else if ([textField isEqual:self.pinTextField]) {
        self.pinUnderlineView.backgroundColor = underlineColor;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    UIColor* underlineColor = [UIColor colorWithRed:189/255. green:198/255. blue:207/255. alpha:1];
    if ([textField isEqual:self.addressTextField]) {
        self.adressUnderlineView.backgroundColor = underlineColor;
    }else if ([textField isEqual:self.amountTextField]) {
        self.amountUnderlineView.backgroundColor = underlineColor;
    }else if ([textField isEqual:self.pinTextField]) {
        self.pinUnderlineView.backgroundColor = underlineColor;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.amountTextField]) {
        NSMutableString *newString = [textField.text mutableCopy];
        [newString replaceCharactersInRange:range withString:string];
        NSString *complededString = [newString stringByReplacingOccurrencesOfString:@"," withString:@"."];
        [self calculateResidue:complededString];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)addDoneButtonToAmountTextField
{
    UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = [UIColor groupTableViewBackgroundColor];
    toolbar.items = @[
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                      [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)],
                      ];
    [toolbar sizeToFit];
    
    self.amountTextField.inputAccessoryView = toolbar;
}

- (void)done:(id)sender
{
    [self.amountTextField resignFirstResponder];
}

- (void)calculateResidue:(NSString *)string
{
    double amount;
    if (string) {
        amount = [string doubleValue];
    }else{
        amount = [self.amountTextField.text doubleValue];
    }
    double balance = [self.currentBalance doubleValue];
    
    double residue = balance - amount;
    self.residueValueLabel.text = [NSString stringWithFormat:@"%lf", residue];
}

#pragma mark - Action

- (IBAction)backbuttonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)makePaymentButtonWasPressed:(id)sender {
    
    NSNumber *amount = @([self.amountTextField.text doubleValue]);
    NSString *address = self.addressTextField.text;
    
    NSArray *array = @[@{@"amount" : amount, @"address" : address}];
        
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    [[TransactionManager sharedInstance] sendTransactionWalletKeys:[[WalletManager sharedInstance].getCurrentWallet getAllKeys] toAddressAndAmount:array andHandler:^(NSError *error, id response) {
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            [weakSelf backbuttonPressed:nil];
        } else {
            [SVProgressHUD dismiss];
            [weakSelf showAlertWithTitle:@"Error" mesage:response andActions:nil];
        }
    }];
}

- (IBAction)actionVoidTap:(id)sender{
    [self.view endEditing:YES];
}

#pragma mark - QRCodeViewControllerDelegate

- (void)qrCodeScanned:(NSDictionary *)dictionary{
    self.adress = dictionary[PUBLIC_ADDRESS_STRING_KEY];
    self.amount = dictionary[AMOUNT_STRING_KEY];
    [self updateControls];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"NewPaymentToQrCode"]) {
        QRCodeViewController *vc = (QRCodeViewController *)segue.destinationViewController;
        
        vc.delegate = self;
    }
}

-(IBAction)unwingToPayment:(UIStoryboardSegue *)segue {
//    StartNavigationCoordinator* coordinator = (StartNavigationCoordinator*)self.navigationController;
//    [coordinator clear];
}

@end
