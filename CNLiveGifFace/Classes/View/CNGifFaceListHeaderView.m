//
//  CNGifFaceListHeaderView.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2019/2/20.
//  Copyright © 2019年 cnlive. All rights reserved.
//

#import "CNGifFaceListHeaderView.h"
#import "UIColor+CNLiveExtension.h"
#import "CNLiveDefinesHeader.h"

@interface CNGifFaceListHeaderView()
/** 内部的label */
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIView *topLine;
@property (nonatomic, weak) UIView *bottomLine;

@end

@implementation CNGifFaceListHeaderView
static const NSInteger margin = 10;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, 200, 45*RATIO)];
        label.textColor = CNLiveColorWithHexString(@"000000");
        label.font = UIFontCNMake(17);
        label.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:label];
        self.label = label;
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.5)];
        topLine.backgroundColor = CNLiveColorWithHexString(@"EBEBEB");
        [self.contentView addSubview:topLine];
        self.topLine = topLine;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(margin, 45*RATIO-0.5, KScreenWidth-margin, 0.5)];
        bottomLine.backgroundColor = CNLiveColorWithHexString(@"EBEBEB");
        [self.contentView addSubview:bottomLine];
        self.bottomLine = bottomLine;
        
    }
    return self;
}
- (void)setIsHidden:(BOOL)isHidden{
    _isHidden = isHidden;
    _topLine.hidden = isHidden;
    _bottomLine.hidden = isHidden;
}
- (void)setBackgroundColor:(NSString *)backgroundColor{
    _backgroundColor = backgroundColor;
    self.contentView.backgroundColor = CNLiveColorWithHexString(backgroundColor);
    _label.backgroundColor = CNLiveColorWithHexString(backgroundColor);

}
- (void)setTextSize:(NSInteger)textSize{
    _label.font = UIFontCNMake(textSize);
}
- (void)setTextColor:(NSString *)textColor{
    _textColor = textColor;
    _label.textColor = CNLiveColorWithHexString(textColor);

}

- (void)setText:(NSString *)text{
    self.label.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
