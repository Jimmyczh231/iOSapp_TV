//
//  HomePageTableViewCell.h
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePageTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong ,readwrite) UILabel *textContentLabel;
@property (nonatomic, strong) NSDictionary *status;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, strong) NSMutableArray *imagesUrl;
@property (nonatomic, strong) UIImageView *profileImage;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andwith:(NSString*)text andwith:(NSString*)name andwith:(NSMutableArray*)picUrlArray;

@end

NS_ASSUME_NONNULL_END
