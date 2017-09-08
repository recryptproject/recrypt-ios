//
//  TransactionBuilder.h
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 06.09.17.
//  Copyright © 2017 PixelPlex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionScriptBuilder.h"

typedef NS_ENUM(NSInteger, TransactionManagerErrorType) {
    TransactionManagerErrorTypeNone,
    TransactionManagerErrorTypeNoInternetConnection,
    TransactionManagerErrorTypeServer,
    TransactionManagerErrorTypeOups,
    TransactionManagerErrorTypeNotEnoughMoney,
    TransactionManagerErrorTypeInvalidAddress
};

@interface TransactionBuilder : NSObject

-(instancetype)initWithScriptBuilder:(TransactionScriptBuilder*) scriptBuilder;

- (BTCTransaction *)createSmartContractUnspentOutputs:(NSArray *)unspentOutputs
                                               amount:(CGFloat) amount
                                              bitcode:(NSData*) bitcode
                                           walletKeys:(NSArray<BTCKey*>*) walletKeys;

- (BTCTransaction *)sendToTokenWithUnspentOutputs:(NSArray <BTCTransactionOutput*>*)unspentOutputs
                                           amount:(CGFloat) amount
                                  contractAddress:(NSData*) contractAddress
                                        toAddress:(NSString*) toAddress
                                    fromAddresses:(NSArray<NSString*>*) fromAddresses
                                          bitcode:(NSData*) bitcode
                                       walletKeys:(NSArray<BTCKey*>*) walletKeys;

- (void)regularTransactionWithUnspentOutputs:(NSArray <BTCTransactionOutput*>*)unspentOutputs
                                      amount:(CGFloat) amount
                          amountAndAddresses:(NSArray*) amountAndAddresses
                                  walletKeys:(NSArray<BTCKey*>*) walletKeys
                                  andHandler:(void(^)(TransactionManagerErrorType errorType, BTCTransaction *transaction)) completion;

@end