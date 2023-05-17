//
//  CostomScrollViewBar.m
//  迷你微博
//
//  Created by jimmy on 5/13/23.
//

#import "CostomScrollViewBar.h"

static CGFloat const kBarHeight = 100.0;

static CGFloat const kSliderHeight = 5.0;

static CGFloat const kSliderToBarDistance = 10.0;

@interface CostomScrollViewBar()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UIButton *sendWeiboButton;
@property (nonatomic, strong) NSMutableArray *allLabels;
@property (nonatomic, readwrite) NSInteger selectedIndex;
@property (nonatomic, readwrite )CGFloat sliderProgress;

@end

@implementation CostomScrollViewBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 1.0;
        self.selectedIndex = 0;
        self.sliderProgress = 0;
        
        // 初始化标题
        self.leftLabel = [self createLabelWithText:@"关注" frame:CGRectMake(70, 40, (frame.size.width-140) / 3, kBarHeight - 10)];
        self.centerLabel = [self createLabelWithText:@"推荐" frame:CGRectMake(70 + (frame.size.width-140) / 3, 40, (frame.size.width-140) / 3, kBarHeight - 10)];
        self.rightLabel = [self createLabelWithText:@"其他" frame:CGRectMake(70 + (frame.size.width-140) * 2 / 3, 40, (frame.size.width-140) / 3, kBarHeight - 10)];
        
        
        [self addSubview:self.leftLabel];
        [self addSubview:self.centerLabel];
        [self addSubview:self.rightLabel];
        self.allLabels = [NSMutableArray array];
        [self.allLabels addObject:self.leftLabel];
        [self.allLabels addObject:self.centerLabel];
        [self.allLabels addObject:self.rightLabel];
     
        // 初始化发送按钮
//        self.sendWeiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.sendWeiboButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 52, 28, 28);
//        UIImage *senderImage = [UIImage imageNamed:@"jiahao.png"];
//        UIImage *senderImageTouched = [UIImage imageNamed:@"jiahao-2.png"];
//        [self.sendWeiboButton setImage:senderImage forState:UIControlStateNormal];
//        [self.sendWeiboButton setImage:senderImageTouched forState:UIControlStateSelected];
//        self.sendWeiboButton.enabled = YES;
//        [self.sendWeiboButton addTarget:self action:@selector(senderButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.userInteractionEnabled = NO;
        
 
        // 初始化滑块
        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - self.leftLabel.frame.size.width / 2, self.leftLabel.frame.size.height - kSliderHeight - kSliderToBarDistance, self.leftLabel.frame.size.width, kSliderHeight)];
        self.sliderView.backgroundColor = [UIColor orangeColor];
        [self addSubview:self.sliderView];
        
        // 监听页面切换的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedIndexDidChange:) name:@"SelectedIndexDidChangeNotification" object:nil];
        
        // 监听页面间滑动的进度通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderProgressDidChange:) name:@"PagingScrollViewDidScrollNotification" object:nil];
        [self addSubview:self.sendWeiboButton];
    }
    return self;
}

- (void)dealloc {
    // 页面销毁时移除通知的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)createLabelWithText:(NSString *)text frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = text;
    label.textColor = [UIColor blackColor];
    return label;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self updateLabels];
}

- (void)setSliderProgress:(CGFloat)progress {
    _sliderProgress = progress;
    [self updateSlider];
}

- (void)selectedIndexDidChange:(NSNotification *)notification {
    // 获取选中的索引值
    NSInteger selectedIndex = [notification.userInfo[@"selectedIndex"] integerValue];
    self.selectedIndex = selectedIndex;
}

- (void)sliderProgressDidChange:(NSNotification *)notification {
    // 获取滑动的进度值
    CGFloat progress = [notification.userInfo[@"progress"] floatValue];
    self.sliderProgress = progress;
    NSInteger selectedIndex = [notification.userInfo[@"currentPage"] integerValue];
    self.selectedIndex = selectedIndex;
    [self updateSlider];
    [self updateLabels];
}
- (void)updateSlider {
    // 根据滑动进度更新滑块的位置和大小
    
    UILabel *currentLabel = self.allLabels[self.selectedIndex];
    NSInteger objetiveLablelIndex = self.selectedIndex + (self.sliderProgress < 0 ? -1 : 1 ) ;
    UILabel *objetiveLabel = self.allLabels[(objetiveLablelIndex + 1) < self.allLabels.count ? objetiveLablelIndex : self.allLabels.count - 1 ];
    CGFloat x;
    CGFloat width;
    
    // 计算滑动的位置和长度
    
    if (self.sliderProgress > 0) {
        if(fabs(self.sliderProgress)<=0.5) {
            CGFloat progress = self.sliderProgress / 0.5;
            x = currentLabel.frame.origin.x;
            width = currentLabel.frame.size.width + ((objetiveLabel.frame.origin.x + objetiveLabel.frame.size.width) - (currentLabel.frame.origin.x + currentLabel.frame.size.width)) * progress;
        } else {
            CGFloat progress = (1 - self.sliderProgress) / 0.5;
            x = currentLabel.frame.origin.x + (objetiveLabel.frame.origin.x - currentLabel.frame.origin.x) * (1 - progress);
            width = objetiveLabel.frame.size.width + (objetiveLabel.frame.origin.x - currentLabel.frame.origin.x) * progress;
        }
    } else if (self.sliderProgress < 0) {
        if (fabs(self.sliderProgress)<=0.5) {
            CGFloat progress = self.sliderProgress / 0.5;
            x = objetiveLabel.frame.origin.x + (currentLabel.frame.origin.x - objetiveLabel.frame.origin.x) * (1 + progress);
            width = currentLabel.frame.size.width + (objetiveLabel.frame.origin.x - currentLabel.frame.origin.x) *  progress;
        } else {
            CGFloat progress = (1 + self.sliderProgress) / 0.5;
            x = objetiveLabel.frame.origin.x;
            width = objetiveLabel.frame.size.width + ((currentLabel.frame.origin.x + currentLabel.frame.size.width) - (objetiveLabel.frame.origin.x + objetiveLabel.frame.size.width)) *  progress ;
        }
    } else {
        x = currentLabel.frame.origin.x;
        width = currentLabel.frame.size.width;
    }
    
    
    CGFloat height = kSliderHeight ;
    CGFloat y = self.frame.size.height - height - kSliderToBarDistance;
    self.sliderView.frame = CGRectMake(x, y, width, height);
    

}

- (void)updateLabels {
    // 更新标题的字体样式
    switch (self.selectedIndex) {
        case 0:
            self.leftLabel.font = [UIFont boldSystemFontOfSize:17.0];
            self.centerLabel.font = [UIFont systemFontOfSize:17.0];
            self.rightLabel.font = [UIFont systemFontOfSize:17.0];
            break;
        case 1:
            self.leftLabel.font = [UIFont systemFontOfSize:17.0];
            self.centerLabel.font = [UIFont boldSystemFontOfSize:17.0];
            self.rightLabel.font = [UIFont systemFontOfSize:17.0];
            break;
        case 2:
            self.leftLabel.font = [UIFont systemFontOfSize:17.0];
            self.centerLabel.font = [UIFont systemFontOfSize:17.0];
            self.rightLabel.font = [UIFont boldSystemFontOfSize:17.0];
            break;
        default:
            break;
    }
}

- (void)senderButtonTapped:(UIButton *)sender{
    NSLog(@"touched");
}

@end


