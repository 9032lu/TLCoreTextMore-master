//
//  NSMutableAttributedString+Config.h
//  TLMove
//
//  Created by andezhou on 15/7/29.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (Config)

- (void)setTextColor:(UIColor *)color;
- (void)setTextColor:(UIColor *)color range:(NSRange)range;

- (void)setFont:(UIFont *)font;
- (void)setFont:(UIFont *)font range:(NSRange)range;

- (NSMutableAttributedString *)setAttributedsWithLineSpacing:(CGFloat)lineSpacing
                                            paragraphSpacing:(CGFloat)paragraphSpacing
                                               textAlignment:(CTTextAlignment)textAlignment
                                               lineBreakMode:(CTLineBreakMode)lineBreakMode;

@end
