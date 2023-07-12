//
//  HomePageTableViewCell.m
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import "HomePageTableViewCell.h"
#import "ImageLoader.h"
#import "ShoucangManager.h"
#import <UIView+SDAutoLayout.h>

@interface HomePageTableViewCell ()

@property (nonatomic, strong) UIImageView *userProfileImageView;
@property (nonatomic, strong) UIButton *dinazanButton;
@property (nonatomic, strong) ShoucangManager *shoucangManager;
@property (nonatomic, readwrite) BOOL isShoucanged;

@end

@implementation HomePageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andwith:(NSString*)text andwith:(NSString*)name andwith:(NSMutableArray*)picUrlArray{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 传了个寂寞
    }
    return self;
}

// 布置cell的显示
- (void)layoutSubViewWith:(NSString*)text andWith:(NSString *)name andWith:(NSMutableArray*)picUrlArray andWith:(NSURL*)profileImageUrl{
    // 先将原先的所有subview移除
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [super layoutSubviews];
    
    
    // 头像的初始化
    self.profileImageUrl = profileImageUrl;
    self.userProfileImageView = [[UIImageView alloc] init];
    [[ImageLoader sharedInstance] loadImageWithURL:self.profileImageUrl completion:^(UIImage * _Nonnull image) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userProfileImageView.image = image;
            });
        } else {
            NSLog(@"Failed to load image");
        }
    }];
    self.userProfileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userProfileImageView.layer.cornerRadius = 20.0;
    self.userProfileImageView.layer.masksToBounds = YES;
    
    
    // 头像的布局
    NSLayoutConstraint *profileImageLeft = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:13];
    NSLayoutConstraint *profileImageTop = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:13];
    NSLayoutConstraint *profileImagewidth = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
    NSLayoutConstraint *profileImageheight = [NSLayoutConstraint constraintWithItem:self.userProfileImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
    [self.contentView addSubview:self.userProfileImageView];
    [self.contentView addConstraints:@[profileImageLeft, profileImageTop]];
    [ self.userProfileImageView addConstraints:@[profileImagewidth, profileImageheight]];
    
    
    // 用户名的初始化和布局
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = name;
    self.nameLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *nameLabelLeft = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.userProfileImageView attribute:NSLayoutAttributeRight multiplier:1 constant:13];
    NSLayoutConstraint *nameLabelTop = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
    [self.contentView addConstraints:@[nameLabelLeft, nameLabelTop]];

    // 微博文字信息的初始化和布局
    self.textContentLabel = [[UILabel alloc] init];
    self.textContentLabel.text = text;
    self.orignalText = text;
    self.textContentLabel.numberOfLines = 0;
    self.textContentLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:self.textContentLabel];
    self.textContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textContentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *textLabelLeft = [NSLayoutConstraint constraintWithItem:self.textContentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    NSLayoutConstraint *textLabelRight = [NSLayoutConstraint constraintWithItem:self.textContentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
    NSLayoutConstraint *textLabelTop = [NSLayoutConstraint constraintWithItem:self.textContentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:35];
    [self.contentView addConstraints:@[textLabelLeft, textLabelRight, textLabelTop]];
    
    // 添加点击事件，进入文末链接
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTextLabel:)];
    [self.textContentLabel addGestureRecognizer:tapGesture];
    
    
    // 用正则表达式匹配文末的 URL
    NSString *pattern = @"(http://|https://){0,1}[a-zA-Z0-9\\-.]+\\.[a-zA-Z]{2,3}(/\\S*){0,1}";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    
    NSInteger lengthOffset = 0;  // 用于记录长度的偏差值
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        // 计算位置的时候减去偏差
        matchRange.location -= lengthOffset;
        NSString *urlString = [text substringWithRange:matchRange];
        NSURL *url = [NSURL URLWithString:urlString];
        NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName: [UIColor blueColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
        [attributedText addAttributes:linkAttributes range:matchRange];
        // 将文字末尾的 URL 替换成“网络连接”
        [attributedText replaceCharactersInRange:matchRange withString:@"网络链接"];
        NSInteger lengthDifference = matchRange.length - [@"网络链接" length];
        // 加上偏差值
        lengthOffset += lengthDifference;
    }
    self.textContentLabel.attributedText = attributedText;
    self.textContentLabel.userInteractionEnabled = YES;

    
    // 点赞按钮的初始化
    self.dinazanButton = [[UIButton alloc]init];
    self.dinazanButton.frame = CGRectMake((self.contentView.bounds.size.width) * 3 / 4 - 10, self.contentView.bounds.size.height-25, 20, 20);
    self.dinazanButton.backgroundColor = [UIColor whiteColor];

    // 判断点赞图标
    self.isShoucanged = [[ShoucangManager sharedManager] isDataShoucangedWith:self.status];
    UIImage *dinazan = [UIImage imageNamed:@"dianzan-2.png"];
    UIImage *dinazaned = [UIImage imageNamed:@"dianzan_kuai.png"];
    if (self.isShoucanged) {
        [self.dinazanButton setImage:dinazaned forState:UIControlStateNormal];
    } else {
        [self.dinazanButton setImage:dinazan forState:UIControlStateNormal];
    }
    [self.dinazanButton addTarget:self action:@selector(dinazanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 点赞按钮的布局
    [self.dinazanButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.dinazanButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:(self.contentView.bounds.size.width) * 3 / 4 - 10];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.dinazanButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.dinazanButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.dinazanButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20];
    [self.contentView addSubview:self.dinazanButton];
    [self.contentView addConstraints:@[left, top]];
    [self.dinazanButton addConstraints:@[width, height]];

    
    // 初始化所需的 ImageView
    self.imagesUrl = picUrlArray;
    self.imageViews = [NSMutableArray array];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
    
    // 根据图片 URL 添加图片和布局
    [self setImageViewWithImageUrls:self.imagesUrl];
    

}

// 文字的点击响应
- (void)handleTapOnTextLabel:(UITapGestureRecognizer *)gesture {
    UILabel *label = (UILabel *)gesture.view;
    NSString *text = self.orignalText;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http|https)://)[^\\s]+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (match) {
        NSURL *url = [NSURL URLWithString:[text substringWithRange:match.range]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            NSDictionary *userInfo = @{@"url": url};
            // 发送匹配到的 URL 到页面Controller
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenURLNotification" object:nil userInfo:userInfo];
        }
    }
}

// 点赞按钮的点击响应
- (void)dinazanButtonClicked:(UIButton *)sender{
    self.isShoucanged = [[ShoucangManager sharedManager] isDataShoucangedWith:self.status];
    UIImage *dinazan = [UIImage imageNamed:@"dianzan-2.png"];
    UIImage *dinazaned = [UIImage imageNamed:@"dianzan_kuai.png"];
    if (self.isShoucanged) {
        [self.dinazanButton setImage:dinazan forState:UIControlStateNormal];
    } else {
        [self.dinazanButton setImage:dinazaned forState:UIControlStateNormal];
    }
    // 发送微博信息到收藏
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddShoucangData" object:nil userInfo:self.status];
}

// 排版图片
- (void)setImageViewWithImageUrls:(NSArray *)imagesUrl {
    // 隐藏不需要的 ImageView
    NSInteger count = imagesUrl.count;
    if (imagesUrl == nil||count == 0) {
        for (UIImageView *imageView in self.imageViews) {
            imageView.hidden = YES;
        }
        return;
    }
    // 添加图片
    for (int i = 0; i < self.imagesUrl.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        if (i < count) {
            imageView.hidden = NO;
            // 默认加载图
            imageView.image = [UIImage imageNamed:@"loading-icon.jpg"];
            [[ImageLoader sharedInstance] loadImageWithURL:imagesUrl[i] completion:^(UIImage * _Nonnull image) {
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                    });
                } else {
                    NSLog(@"Failed to load image");
                }
            }];
        } else {
            imageView.hidden = YES;
        }
    }
    
    if (count == 1) {
        // 一张图片时根据边框缩放图片到合适的大小
        [[ImageLoader sharedInstance] loadImageWithURL:imagesUrl[0] completion:^(UIImage * _Nonnull imageLoaded) {
            if (imageLoaded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = imageLoaded;
                    CGFloat imageWidth = image.size.width;
                    CGFloat imageHeight = image.size.height;
                    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0;
                    CGFloat maxHeight = maxWidth * 0.5;
//                    if (imageWidth > maxWidth || imageHeight > maxHeight) {
                        CGFloat scale = MIN(maxWidth / imageWidth, maxHeight / imageHeight);
                        imageWidth *= scale;
                        imageHeight *= scale;
//                    }
                    UIImageView *imageView = self.imageViews.firstObject;
                    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
                    // 单图时的页面布局
                    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
                    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:15];
                    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageWidth];
                    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageHeight];
                    [self.contentView addSubview:imageView];
                    [self.contentView addConstraints:@[left, top]];
                    [imageView addConstraints:@[width, height]];
                });
            } else {
                NSLog(@"Failed to load image");
            }
        }];
        // 二到四图的情况，直接进行页面布局
    } else if (count >= 2 && count <= 4) {
        CGFloat margin = 10.0;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat imageSize = (screenWidth - margin * 4) / 3;
        for (int i = 0; i < count; i++) {
            CGFloat x = margin + (imageSize + margin) * (i % 2);
            CGFloat y = margin + (imageSize + margin) * (i / 2);
            UIImageView *imageView = self.imageViews[i];
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant: y + 5];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            [self.contentView addSubview:imageView];
            [imageView addConstraints:@[width, height]];
            [self.contentView addConstraints:@[left, top]];
        }
        // 五到九图的情况，直接进行页面布局
    } else if (self.imageNumber >= 5 && self.imageNumber <= 9) {
        CGFloat margin = 10.0;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat imageSize = (screenWidth - margin * 4) / 3;
        for (int i = 0; i < count; i++) {
            CGFloat x = margin + (imageSize + margin) * (i % 3);
            CGFloat y = margin + (imageSize + margin) * (i / 3);
            UIImageView *imageView = self.imageViews[i];
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:y+5];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            [self.contentView addSubview:imageView];
            [imageView addConstraints:@[width, height]];
            [self.contentView addConstraints:@[left, top]];
        }
        // 超过九张图将最后一张图模糊并告知还有多少张图
    } else {
        CGFloat margin = 10.0;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat imageSize = (screenWidth - margin * 4) / 3;
        for (int i = 0; i < 9; i++) {
            CGFloat x = margin + (imageSize + margin) * (i % 3);
            CGFloat y = margin + (imageSize + margin) * (i / 3);
            UIImageView *imageView = self.imageViews[i];
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:y+5];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            [self.contentView addSubview:imageView];
            [imageView addConstraints:@[width, height]];
            [self.contentView addConstraints:@[left, top]];
                if (i == 8) {
                    // 模糊最后一张图片
                    CIImage *inputImage = [[CIImage alloc] initWithImage:imageView.image];
                    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                    [blurFilter setValue:inputImage forKey:kCIInputImageKey];
                    [blurFilter setValue:@(5) forKey:kCIInputRadiusKey];
                    CIImage *outputImage = [blurFilter valueForKey:kCIOutputImageKey];
                    UIImage *blurredImage = [[UIImage alloc] initWithCIImage:outputImage];
                    imageView.image = blurredImage;
                    // 在中间添加数字
                    UILabel *countLabel = [[UILabel alloc] init];
                    countLabel.text = [NSString stringWithFormat:@"+%d", self.imageNumber - 9];
                    countLabel.textColor = [UIColor whiteColor];
                    countLabel.font = [UIFont systemFontOfSize:25];
                    countLabel.textAlignment = NSTextAlignmentCenter;
                    countLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                    [countLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
                    [imageView addSubview:countLabel];
                    NSLayoutConstraint *countLeft = [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
                    NSLayoutConstraint *countTop = [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
                    NSLayoutConstraint *countWidth = [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
                    NSLayoutConstraint *countHeight = [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
                    [imageView addConstraints:@[countLeft, countTop, countWidth, countHeight]];
                }
            }
        }
    }


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
