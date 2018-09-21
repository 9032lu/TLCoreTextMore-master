//
//  TLDisplayView.h
//  TLMove
//
//  Created by andezhou on 15/7/29.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLDisplayView;

@protocol TLDisplayViewDelegate <NSObject>

@required
- (void)displayView:(TLDisplayView *)label openHeight:(CGFloat)height;
- (void)displayView:(TLDisplayView *)label closeHeight:(CGFloat)height;

@end

@interface TLDisplayView : UIView

/**
 *  代理
 */
@property (weak, nonatomic) id<TLDisplayViewDelegate> delegate;

/**
 *  展示行数
 */
@property (assign, nonatomic) NSUInteger numberOfLines;

/**
 *  文字的字体， 默认系统字体16
 */
@property (nonatomic,strong) UIFont *font;

/**
 *  行间距，默认3.0f
 */
@property (assign, nonatomic) CGFloat lineSpace;

/**
 *  段间距, 默认3.0f
 */
@property (assign, nonatomic) CGFloat paragraphSpacing;

/**
 *  文字排版样式, 默认kCTTextAlignmentLeft
 */
@property (assign, nonatomic) CTTextAlignment textAlignment;

/**
 *  断行模式，默认kCTLineBreakByWordWrapping | kCTLineBreakByCharWrapping
 */
@property (assign, nonatomic) CTLineBreakMode lineBreakMode;

/**
 *  文字颜色，默认[UIColor blackColor];
 */
@property (strong, nonatomic) UIColor *textColor;

//大小
- (CGSize)sizeThatFits:(CGSize)size;

//普通文本
- (void)setText:(NSString *)text;

//属性文本
- (void)setAttributedText:(NSAttributedString *)attributedText;

// 添加展开关闭按钮
- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString;

- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString
                 font:(UIFont *)font
            textColor:(UIColor *)textColor;

@end
