//
//  NSMutableAttributedString+CTFrameRef.m
//  TLMove
//
//  Created by andezhou on 15/7/29.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "NSMutableAttributedString+CTFrameRef.h"

@implementation NSMutableAttributedString (CTFrameRef)

#pragma mark - NSRange / CFRange
NSRange NSRangeFromCFRange(CFRange range) {
    return NSMakeRange((NSUInteger)range.location, (NSUInteger)range.length);
}

#pragma mark - CoreText CTLine/CTRun utils
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range) {
    NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
    NSRange intersectedRange = NSIntersectionRange(runRange, range);
    return (intersectedRange.length <= 0);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range) {
    NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
    NSRange intersectedRange = NSIntersectionRange(lineRange, range);
    return (intersectedRange.length <= 0);
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin) {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
    
    return CGRectMake(lineOrigin.x + xOffset - leading,
                      lineOrigin.y - descent,
                      width + leading,
                      height);
}

CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin) {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(lineOrigin.x,
                      lineOrigin.y - descent,
                      width,
                      height);
}

CGRect CTRunGetTypographicBoundsForLinkRect(CTLineRef line, NSRange range, CGPoint lineOrigin) {
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    for (CFIndex k = 0; k < runCount; k++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        if (CTRunContainsCharactersFromStringRange(run, range)) {
            continue;
        }
        
        CGRect linkRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigin);
        
        linkRect.origin.y = roundf(linkRect.origin.y);
        linkRect.origin.x = roundf(linkRect.origin.x);
        linkRect.size.width = roundf(linkRect.size.width);
        linkRect.size.height = roundf(linkRect.size.height);
        
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
    }
    
    return rectForRange;
}

- (CTFrameRef)prepareFrameRefWithWidth:(CGFloat)width {
    // 创建 CTFramesetterRef 实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
        
    CTFrameRef frameRef = [self createFrameWithFramesetter:framesetter width:width height:coreTextSize.height];
    
    return frameRef;
}

- (CGFloat)prepareDisplayViewHeightWithWidth:(CGFloat)width {
    // 创建 CTFramesetterRef 实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    
    return coreTextSize.height;
}

- (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                   width:(CGFloat)width
                                  height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, CGRectMake(0, 0, width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    
    return frame;
}

@end
