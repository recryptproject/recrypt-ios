//
//  GradientView.h
//  recrypt wallet
//
//  Created by Sharaev Vladimir on 17.11.16.
//  Copyright © 2016 RECRYPT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ColorType) {
	Blue,
	Pink,
	Green,
	ForWallet,
	White,
	WhiteLong,
	DarkLong
};

@interface GradientView : UIView

@property (assign, nonatomic) ColorType colorType;

@end
