//
//  HomePageTableViewCell.m
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import "HomePageTableViewCell.h"
#import "ImageLoader.h"


@implementation HomePageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andwith:(NSString*)text andwith:(NSString*)name andwith:(NSMutableArray*)picUrlArray{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *nameLabelLeft = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
        NSLayoutConstraint *nameLabelTop = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
        [self.contentView addConstraints:@[nameLabelLeft, nameLabelTop]];
//        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.top.equalTo(self.contentView).offset(10);
//        }];
        
        self.textContentLabel = [[UILabel alloc] init];
        self.textContentLabel.numberOfLines = 0;
        self.textContentLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:self.textContentLabel];
        self.textContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textContentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *textLabelLeft = [NSLayoutConstraint constraintWithItem:self.textContentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
        NSLayoutConstraint *textLabelRight = [NSLayoutConstraint constraintWithItem:self.textContentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
        NSLayoutConstraint *textLabelTop = [NSLayoutConstraint constraintWithItem:self.textContentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
        [self.contentView addConstraints:@[textLabelLeft, textLabelRight, textLabelTop]];
        
//        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(10);
//            make.right.equalTo(self.contentView).offset(-10);
//            make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
//        }];
        self.imagesUrl = picUrlArray;
        self.imageViews = [NSMutableArray array];
        for (int i = 0; i < self.imagesUrl.count; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.contentView addSubview:imageView];
            [self.imageViews addObject:imageView];
        }

//        UILabel *countLabel = [[UILabel alloc] init];
//        countLabel.font = [UIFont systemFontOfSize:12.0];
//        countLabel.textColor = [UIColor whiteColor];
//        countLabel.textAlignment = NSTextAlignmentCenter;
//        countLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//        countLabel.layer.cornerRadius = 10;
//        countLabel.layer.masksToBounds = YES;
//        [self.contentView addSubview:countLabel];
//        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.contentView);
//            make.bottom.equalTo(self.contentView).offset(-10);
//            make.width.height.mas_equalTo(20);
//        }];
        [self setImageViewWithImageUrls:self.imagesUrl];
//        CGFloat margin = 10.0;
//        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
//        CGFloat imageSize = (screenWidth - margin * 4) / 3;
//        for (int i = 0; i < 9; i++) {
//            CGFloat x = margin + (imageSize + margin) * (i % 3);
//            CGFloat y = margin + (imageSize + margin) * (i / 3 + 1);
//            UIImageView *imageView = self.imageViews[i];
//            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.contentView).offset(x);
//                make.top.equalTo(self.textLabel.mas_bottom).offset(y);
//                make.width.height.mas_equalTo(imageSize);
//            }];
//        }
    }
    return self;
}
// 排版图片
- (void)setImageViewWithImageUrls:(NSArray *)imagesUrl {
    NSInteger count = imagesUrl.count;
    if (imagesUrl == nil||count == 0) {
        for (UIImageView *imageView in self.imageViews) {
            imageView.hidden = YES;
        }
        return;
    }
    for (int i = 0; i < self.imagesUrl.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        if (i < count) {
            imageView.hidden = NO;
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
        [[ImageLoader sharedInstance] loadImageWithURL:imagesUrl[0] completion:^(UIImage * _Nonnull imageLoaded) {
            if (imageLoaded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = imageLoaded;
                    CGFloat imageWidth = image.size.width;
                    CGFloat imageHeight = image.size.height;
                    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0;
                    CGFloat maxHeight = maxWidth * 0.75;
                    if (imageWidth > maxWidth || imageHeight > maxHeight) {
                        CGFloat scale = MIN(maxWidth / imageWidth, maxHeight / imageHeight);
                        imageWidth *= scale;
                        imageHeight *= scale;
                    }
                    UIImageView *imageView = self.imageViews.firstObject;
                    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
                    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
                    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
                    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageWidth];
                    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageHeight];
                    [self.contentView addSubview:imageView];
                    [self.contentView addConstraints:@[left, top]];
                    [imageView addConstraints:@[width, height]];
                });
            } else {
#warning 如果没有图片设置个默认图片
                NSLog(@"Failed to load image");
            }
        }];
//        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(10);
//            make.top.equalTo(self.textLabel.mas_bottom).offset(10);
//            make.width.mas_equalTo(imageWidth);
//            make.height.mas_equalTo(imageHeight);
//        }];
    } else if (count >= 2 && count <= 4) {
        CGFloat margin = 10.0;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat imageSize = (screenWidth - margin * 4) / 3;
        for (int i = 0; i < count; i++) {
            CGFloat x = margin + (imageSize + margin) * (i % 2);
            CGFloat y = margin + (imageSize + margin) * (i / 2 + 1);
            UIImageView *imageView = self.imageViews[i];
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:y];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            [self.contentView addSubview:imageView];
            [imageView addConstraints:@[width, height]];
            [self.contentView addConstraints:@[left, top]];
//            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.contentView).offset(x);
//                make.top.equalTo(self.textLabel.mas_bottom).offset(y);
//                make.width.height.mas_equalTo(imageSize);
//            }];
        }
    } else if (count >= 5 && count <= 9) {
        CGFloat margin = 10.0;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat imageSize = (screenWidth - margin * 4) / 3;
        for (int i = 0; i < count; i++) {
            CGFloat x = margin + (imageSize + margin) * (i % 3);
            CGFloat y = margin + (imageSize + margin) * (i / 3 + 1);
            UIImageView *imageView = self.imageViews[i];
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:y];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            [self.contentView addSubview:imageView];
            [imageView addConstraints:@[width, height]];
            [self.contentView addConstraints:@[left, top]];
//            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.contentView).offset(x);
//                make.top.equalTo(self.textLabel.mas_bottom).offset(y);
//                make.width.height.mas_equalTo(imageSize);
//            }];
        }
    } else {
        CGFloat margin = 10.0;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat imageSize = (screenWidth - margin * 4) / 3;
        for (int i = 0; i < 9; i++) {
            CGFloat x = margin + (imageSize + margin) * (i % 3);
            CGFloat y = margin + (imageSize + margin) * (i / 3 + 1);
            UIImageView *imageView = self.imageViews[i];
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:x];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textContentLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:y];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:imageSize];
            [self.contentView addSubview:imageView];
            [imageView addConstraints:@[width, height]];
            [self.contentView addConstraints:@[left, top]];
//            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.contentView).offset(x);
//                    make.top.equalTo(self.textLabel.mas_bottom).offset(y);
//                    make.width.height.mas_equalTo(imageSize);
//                }];
                if (i == 8) {
                    // 模糊最后一张图片
                    CIImage *inputImage = [[CIImage alloc] initWithImage:imageView.image];
                    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                    [blurFilter setValue:inputImage forKey:kCIInputImageKey];
                    [blurFilter setValue:@(5) forKey:kCIInputRadiusKey];
                    CIImage *outputImage = [blurFilter valueForKey:kCIOutputImageKey];
                    UIImage *blurredImage = [[UIImage alloc] initWithCIImage:outputImage];
                    imageView.image = blurredImage;
//                    imageView.image = [imageView.image applyBlurWithRadius:5 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
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
