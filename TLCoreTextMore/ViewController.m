//
//  ViewController.m
//  TLCoreTextMore
//
//  Created by andezhou on 15/7/31.
//  Copyright (c) 2015年 andezhou. All rights reserved.
//

#import "ViewController.h"

#import "TLDisplayView.h"

@interface ViewController () <TLDisplayViewDelegate>

@property (nonatomic, strong) TLDisplayView *displayView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _displayView = [[TLDisplayView alloc] init];
    _displayView.delegate = self;
    _displayView.backgroundColor = [UIColor yellowColor];
    _displayView.numberOfLines = 2;
    [_displayView setText:@"新浪2微博(www.weibo.com)在美国纳斯达克正式挂牌上asdasdasd市了！新浪2微博(www.weibo.com)在美国纳斯达克正！"];
    [_displayView setOpenString:@"［查看更多］" closeString:@"［点击收起］" font:[UIFont systemFontOfSize:16] textColor:[UIColor blueColor]];
    
    CGSize size = [_displayView sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT)];
    _displayView.frame = CGRectMake(10, 100, size.width, size.height);
    [self.view addSubview:_displayView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -
#pragma mark TLDisplayViewDelegate
- (void)displayView:(TLDisplayView *)label closeHeight:(CGFloat)height {
    CGRect frame = _displayView.frame;
    frame.size.height = height;
    self.displayView.frame = frame;
}

- (void)displayView:(TLDisplayView *)label openHeight:(CGFloat)height {
    CGRect frame = _displayView.frame;
    frame.size.height = height;
    self.displayView.frame = frame;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
