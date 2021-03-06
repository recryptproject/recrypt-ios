//
//  NewPaymentOutputEntity.h
//  recrypt wallet
//
//  Created by Vladimir Lebedevich on 27.11.2017.
//  Copyright © 2017 RECRYPT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewPaymentOutputEntity : NSObject

@property (assign, nonatomic, getter=isTokenChoosen) BOOL tokenChoosen;
@property (assign, nonatomic, getter=isTokensExists) BOOL tokensExists;
@property (copy, nonatomic) NSString* tokenName;
@property (copy, nonatomic) NSString* tokenSymbol;
@property (copy, nonatomic) NSString* amount;
@property (copy, nonatomic) NSString* receiverAddress;
@property (strong, nonatomic) RECRYPTBigNumber* walletBalance;
@property (strong, nonatomic) RECRYPTBigNumber* unconfirmedWalletBalance;
@property (strong, nonatomic) NSString* contractBalanceString;
@property (strong, nonatomic) NSString* shortContractBalanceString;
@property (strong, nonatomic) NSArray <ContracBalancesObject *> *tokenBalancesInfo;
@property (strong, nonatomic) ContracBalancesObject* choosenTokenBalance;

@end
