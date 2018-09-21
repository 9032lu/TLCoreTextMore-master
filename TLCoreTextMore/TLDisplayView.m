//
//  TLDisplayView.m
//  TLMove
//
//  Created by andezhou on 15/7/29.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "TLDisplayView.h"
#import "TLAttributedLabelUtils.h"
#import "NSMutableAttributedString+Config.h"
#import "NSMutableAttributedString+CTFrameRef.h"

static NSString * const kEllipsesCharacter = @"\u2026";
static NSUInteger const kMaxNumberOfLines = 100000;

@interface TLDisplayView ()

@property (nonatomic, strong) NSMutableAttributedString *attributedString, *currentAttString, *closeAttString;
@property (nonatomic, strong) NSMutableAttributedString *attributedOpenString, *attributedCloseString;
@property (nonatomic, assign) NSRange moreRange;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSUInteger currentNumberOfLines;
@property (nonatomic, assign) CTFrameRef frameRef;
@property (assign, nonatomic) CGFloat width;

@end

@implementation TLDisplayView

#pragma mark -
#pragma mark lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configSettings];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSettings];
    }
    return self;
}

- (void)configSettings {
    self.numberOfLines = kMaxNumberOfLines;
    _lineSpace = 3.0f;
    _paragraphSpacing = 0.0f;
    _font = [UIFont systemFontOfSize:16.0f];
    _textColor = [UIColor blackColor];
    _textAlignment = kCTTextAlignmentLeft;
    _lineBreakMode = kCTLineBreakByWordWrapping | kCTLineBreakByCharWrapping;
}

#pragma mark -
#pragma mark set and get
- (void)setFont:(UIFont *)font {
    if (font != _font) {
        _font = font;
        [_attributedString setFont:font];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor != _textColor) {
        _textColor = textColor;
        [_attributedString setTextColor:textColor];
    }
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    _currentNumberOfLines = numberOfLines;
}

- (void)setFrame:(CGRect)frame {
    self.width = frame.size.width;
    [self setNeedsDisplay];
    [super setFrame:frame];
}

#pragma mark - 设置文本
- (void)setText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    _currentAttString = [_attributedString mutableCopy];
}

- (NSMutableAttributedString *)attributedString:(NSString *)text {
    return [self attributedString:text font:_font textColor:_textColor];
}

- (NSMutableAttributedString *)attributedString:(NSString *)text
                                           font:(UIFont *)font
                                      textColor:(UIColor *)textColor {
    if (!text && !text.length) {
        return nil;
    }
    
    // 初始化NSMutableAttributedString
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString setFont:font];
    [attributedString setTextColor:textColor];
    
    return attributedString;
}

// 添加展开和收起
- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString {
    [self setOpenString:openString
            closeString:closeString
                   font:self.font
              textColor:self.textColor];
}

- (void)setOpenString:(NSString *)openString
          closeString:(NSString *)closeString
                 font:(UIFont *)font
            textColor:(UIColor *)textColor {
    self.attributedOpenString = [self attributedString:openString font:font textColor:textColor];
    self.attributedCloseString = [self attributedString:closeString font:font textColor:textColor];
    
    [self setNeedsDisplay];
}

- (NSMutableAttributedString *)parseAttributedWithAttributedString:(NSMutableAttributedString *)attributedString {
    [attributedString setAttributedsWithLineSpacing:self.lineSpace
                                    paragraphSpacing:self.paragraphSpacing
                                       textAlignment:self.textAlignment
                                       lineBreakMode:self.lineBreakMode];
    return attributedString;
}

- (NSMutableAttributedString *)createdrawAttributedString {
    NSMutableAttributedString *attString = [self attributedString:[NSString stringWithFormat:@"%@%@", _attributedString.string, @"\n"]];
    NSMutableAttributedString *drawString = [[self parseAttributedWithAttributedString:attString] mutableCopy];
    
    NSMutableAttributedString *closeString = [_attributedCloseString mutableCopy];
    [closeString setAttributedsWithLineSpacing:self.lineSpace
                              paragraphSpacing:self.paragraphSpacing
                                 textAlignment:kCTTextAlignmentCenter
                                 lineBreakMode:self.lineBreakMode];
    [drawString appendAttributedString:closeString];
    
    return drawString;
}

#pragma mark - 计算大小
- (CGSize)sizeThatFits:(CGSize)size {
    self.width = size.width;
    CGFloat height = 0.0f;

    if (_attributedString == nil) {
        return CGSizeZero;
    }
    // 第一次进去时
    else if (!self.frameRef) {
        
        NSMutableAttributedString *drawString = [self parseAttributedWithAttributedString:_currentAttString];
        CTFrameRef frameRef = [drawString prepareFrameRefWithWidth:self.width];
        
        CFArrayRef lines = CTFrameGetLines(frameRef);
        CFIndex lineCount = CFArrayGetCount(lines);
        
        if (_currentNumberOfLines < lineCount) {
            NSMutableAttributedString *attString = [self getColseStringWithFrameRef:frameRef];
            
            self.moreRange = [attString.string rangeOfString:_attributedOpenString.string];
            self.frameRef = [attString prepareFrameRefWithWidth:self.width];
            self.currentAttString = [attString mutableCopy];
            
            height = [attString prepareDisplayViewHeightWithWidth:self.width];
        }
        // 2. 当设置的行数大于文字本身的行数、为设置行数，直接绘制文字
        else {
            self.frameRef = frameRef;
            height = [drawString prepareDisplayViewHeightWithWidth:self.width];
        }
    }
    // 点击［点击收起］或［查看更多］时的视图刷新
    else {
        NSMutableAttributedString *drawString = [self parseAttributedWithAttributedString:_currentAttString];
        
        height = [drawString prepareDisplayViewHeightWithWidth:self.width];
    }
    return CGSizeMake(size.width, height);
}

// 获取关闭时的NSMutableAttributedString
- (NSMutableAttributedString *)getColseStringWithFrameRef:(CTFrameRef)frameRef {
    
    if (self.closeAttString) {
        return self.closeAttString;
    }
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);

    NSInteger numberOfLines = MIN(_currentNumberOfLines, lineCount);
    
    // 当只有一行的时候直接返回
    if (lineCount == 1 || _currentNumberOfLines == 0) {
        return _currentAttString;
    }

    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, numberOfLines), lineOrigins);
    NSAttributedString *attributedString = _currentAttString;
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // 处理最后一行的。。。
        if (lineIndex == numberOfLines - 1) {
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (lastLineRange.location + lastLineRange.length < (CFIndex)attributedString.length) {
                NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
                
                NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                                     effectiveRange:NULL];
                NSMutableAttributedString *tokenString = [[NSMutableAttributedString alloc] initWithString:kEllipsesCharacter
                                                                                                attributes:tokenAttributes];
                if (self.attributedOpenString) {
                    [tokenString appendAttributedString:self.attributedOpenString];
                }
                
                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                
                NSMutableAttributedString *newAttributedString = [self containsLineBreaksWithAttString:truncationString
                                                                                                 range:lastLineRange
                                                                                           tokenString:tokenString];
                self.closeAttString = [newAttributedString mutableCopy];
                
                return self.closeAttString;
            }
        }
    }
    
    return [[NSMutableAttributedString alloc] init];
}

// 判断是否包含/n
- (NSMutableAttributedString *)containsLineBreaksWithAttString:(NSMutableAttributedString *)truncationString
                                                         range:(CFRange)lastLineRange
                                                   tokenString:(NSMutableAttributedString *)tokenString {
    NSMutableAttributedString *newAttributedString = nil;
    // 判断有断行的情况
    if ([truncationString.string rangeOfString:@"\n"].location != NSNotFound) {
        
        NSString *string = [[truncationString.string componentsSeparatedByString:@"\n"] firstObject];
        truncationString = [[self attributedString:string] mutableCopy];
        
        NSUInteger newLength = lastLineRange.location + truncationString.length;
        newAttributedString = [[_currentAttString attributedSubstringFromRange:NSMakeRange(0, newLength)] mutableCopy];
        [newAttributedString appendAttributedString:_attributedOpenString];
        
    }else {
        
        NSRange range = NSMakeRange(lastLineRange.location, lastLineRange.length);
        newAttributedString = [self setCloseLinesFromTokenString:tokenString
                                                truncationString:truncationString
                                                   lastLineRange:range];
    }
    
    return newAttributedString;
}

// 通过递归解决越界的问题
- (NSMutableAttributedString *)setCloseLinesFromTokenString:(NSMutableAttributedString *)tokenString
                                           truncationString:(NSMutableAttributedString *)truncationString
                                              lastLineRange:(NSRange)lastLineRange {
    
    NSMutableAttributedString *newAttributedString = nil;

    NSUInteger length = tokenString.length;
    NSRange range = NSMakeRange(truncationString.length - length, length);
    
    NSMutableAttributedString *newAttString = [truncationString mutableCopy];
    [newAttString replaceCharactersInRange:range withAttributedString:tokenString];
    
    NSUInteger newLength = lastLineRange.location + lastLineRange.length - tokenString.length;
    newAttributedString = [[_currentAttString attributedSubstringFromRange:NSMakeRange(0, newLength)] mutableCopy];
    [newAttributedString appendAttributedString:tokenString];
    
    CTFrameRef frameRef = [newAttributedString prepareFrameRefWithWidth:self.width];
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    if (lineCount == _currentNumberOfLines) {
        return newAttributedString;
    }
    else {
        [truncationString deleteCharactersInRange:NSMakeRange(truncationString.length - 1, 1)];
        lastLineRange = NSMakeRange(lastLineRange.location, lastLineRange.length - 1);
        return [self setCloseLinesFromTokenString:tokenString truncationString:truncationString lastLineRange:lastLineRange];
    }
    
    return newAttributedString;
}

#pragma mark -
#pragma mark 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    
    // 检查是否选中链接
    CFIndex index = [TLAttributedLabelUtils touchContentOffsetInView:self atPoint:point ctFrame:self.frameRef];
    
    if (NSLocationInRange(index, self.moreRange)) {
        self.isSelected = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    CGPoint point = [[touches anyObject] locationInView:self];
    CFIndex index = [TLAttributedLabelUtils touchContentOffsetInView:self atPoint:point ctFrame:self.frameRef];
    
    if (self.isSelected && NSLocationInRange(index, self.moreRange) && self.numberOfLines > 0) {

        // 当前显示的行数与初始设置行数相同时，此时显示的是［查看更多］，需要展示［点击收起］
        if (_currentNumberOfLines == _numberOfLines) {
            // 添加［点击收起］后需要展示的attributedString
            NSMutableAttributedString *drawString = [[self parseAttributedWithAttributedString:_attributedString] mutableCopy];
            
            // 初始行数
            CTFrameRef frameRef = [drawString prepareFrameRefWithWidth:self.width];
            CFIndex initLineCount = CFArrayGetCount(CTFrameGetLines(frameRef));
            
            // 添加［点击收起］
            [drawString appendAttributedString:_attributedCloseString];
            
            // 添加［点击收起］后的行数
            CTFrameRef closeFrameRef = [drawString prepareFrameRefWithWidth:self.width];
            CFIndex closeLineCount = CFArrayGetCount(CTFrameGetLines(closeFrameRef));
            
            // 能同行展示［点击收起］
            if (closeLineCount == initLineCount) {
                self.currentAttString  = [drawString mutableCopy];
                self.frameRef = closeFrameRef;
                self.currentNumberOfLines = closeLineCount;
            }
            // 不能同行展示， 需换行展示［点击收起］
            else {
                NSMutableAttributedString *drawString = [self createdrawAttributedString];
                self.currentAttString = [drawString mutableCopy];
                self.frameRef = [drawString prepareFrameRefWithWidth:self.width];
                self.currentNumberOfLines = CFArrayGetCount(CTFrameGetLines(self.frameRef));
            }
            
            self.moreRange = [_currentAttString.string rangeOfString:_attributedCloseString.string];
            CGSize size = [self sizeThatFits:CGSizeMake(self.width, MAXFLOAT)];
           
            // 代理重新设置高度
            if ([self.delegate respondsToSelector:@selector(displayView:openHeight:)]) {
                [self.delegate displayView:self openHeight:size.height];
            }
        }
        // 显示 ［点击收起］
        else {
            CTFrameRef frameRef = [_attributedString prepareFrameRefWithWidth:self.width];
            NSMutableAttributedString *drawString = [[self getColseStringWithFrameRef:frameRef] mutableCopy];

            self.currentNumberOfLines = _numberOfLines;
            self.frameRef = [drawString prepareFrameRefWithWidth:self.width];
            self.currentAttString = [drawString mutableCopy];
            self.moreRange = [drawString.string rangeOfString:_attributedOpenString.string];
            
            CGSize size = [self sizeThatFits:CGSizeMake(self.width, MAXFLOAT)];

            // 代理重新设置高度
            if ([self.delegate respondsToSelector:@selector(displayView:closeHeight:)]) {
                [self.delegate displayView:self closeHeight:size.height];
            }
        }
        
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark drawRect
- (void)drawRect:(CGRect)rect {

    // 1.获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 2.将坐标系上下翻转
    CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
    CGContextConcatCTM(context, transform);
    
    // 3.绘制
    CTFrameDraw(self.frameRef, context);
}



@end
