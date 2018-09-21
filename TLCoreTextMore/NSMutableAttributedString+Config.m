//
//  NSMutableAttributedString+Config.m
//  TLMove
//
//  Created by andezhou on 15/7/29.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "NSMutableAttributedString+Config.h"
#import <CoreText/CoreText.h>

@implementation NSMutableAttributedString (Config)

- (void)setTextColor:(UIColor *)color {
    [self setTextColor:color range:NSMakeRange(0, [self length])];
}

- (void)setTextColor:(UIColor *)color range:(NSRange)range {
    if (color.CGColor) {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
}

- (void)setFont:(UIFont *)font {
    [self setFont:font range:NSMakeRange(0, [self length])];
}

- (void)setFont:(UIFont *)font range:(NSRange)range {
    if (font) {
        [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (nil != fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

- (NSMutableAttributedString *)setAttributedsWithLineSpacing:(CGFloat)lineSpacing
                                            paragraphSpacing:(CGFloat)paragraphSpacing
                                               textAlignment:(CTTextAlignment)textAlignment
                                               lineBreakMode:(CTLineBreakMode)lineBreakMode {
    // 设置行间距
    const CFIndex kNumberOfSettings = 6;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(uint8_t), &lineBreakMode},
        {kCTParagraphStyleSpecifierAlignment, sizeof(uint8_t), &textAlignment},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing}
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    [self addAttribute:(id)kCTParagraphStyleAttributeName
                              value:(__bridge id)theParagraphRef
                              range:NSMakeRange(0, [self length])];
    CFRelease(theParagraphRef);
    
    return self;
    
}

@end
