//
//  PaperToast.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 26/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "PaperToast.h"
@interface PaperToast()
@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UILabel *label;
@end
@implementation PaperToast

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void) setup
{

    self.backgroundColor  = [UIColor clearColor];
    [self addSubview:self.background];
    [self addSubview:self.label];
    [self updateConstraints];
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:194.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:58.0]];
    
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-21]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:174]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:35]];
}

- (void) setText:(NSString *)text
{
    _text = text;
    self.label.text = _text;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 0;
//    [self.label sizeToFit];
//    [self updateConstraints];
}

- (UILabel *) label
{
    if (!_label)
    {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:12];
        _label.textColor = [UIColor blackColor];

        _label.textAlignment = NSTextAlignmentCenter;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = 0;
        //_label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
       // [_label sizeToFit];
    }
    return _label;
}


- (UIImageView *) background
{
    if (!_background)
    {
        _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paper-toast.png"]];
        _background.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _background;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
