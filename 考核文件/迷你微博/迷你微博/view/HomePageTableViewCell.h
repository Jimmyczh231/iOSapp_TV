//
//  HomePageTableViewCell.h
//  迷你微博
//
//  Created by jimmy on 5/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomePageTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;   // 用户名
@property (nonatomic, strong ,readwrite) UILabel *textContentLabel; //微博的文字Label
@property (nonatomic, strong ,readwrite) NSString *orignalText; // 文字信息
@property (nonatomic, strong) NSDictionary *status; //这条微博的所有信息
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews; //用于存所有的imageview
@property (nonatomic, strong) NSMutableArray *imagesUrl; //图片的URL
@property (nonatomic, strong) NSURL *profileImageUrl; // 头像URL
@property (nonatomic, readwrite) int imageNumber; // 真实的图片数量

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andwith:(NSString*)text andwith:(NSString*)name andwith:(NSMutableArray*)picUrlArray;

- (void)layoutSubViewWith:(NSString*)text andWith:(NSString *)name andWith:(NSMutableArray*)picUrlArray andWith:(NSURL*)profileImageUrl;

@end

NS_ASSUME_NONNULL_END
