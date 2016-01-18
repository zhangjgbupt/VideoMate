

#import "LikeBtn.h"

@interface LikeBtn (){
    UIImageView *_likeImageView;
    CAEmitterLayer *_effectLayer;
    CAEmitterCell *_effectCell;
    UIImage *_likeImage;
    UIImage *_unLikeImage;
}

@end

@implementation LikeBtn

-(instancetype)init{
    self=[super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, 22, 22)];
        _likeImage=[UIImage imageNamed:@"icon_like_pressed.png"];
        _unLikeImage=[UIImage imageNamed:@"icon_like_normal.png"];
//        _likeImage=[UIImage imageNamed:@"icon_like_normal.png"];
//        _unLikeImage=[UIImage imageNamed:@"icon_like_pressed.png"];
        _type=LikeBtnTypeFirework;
        [self initBaseLayout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        _likeImage=[UIImage imageNamed:@"icon_like_pressed.png"];
        _unLikeImage=[UIImage imageNamed:@"icon_like_normal.png"];
//        _likeImage=[UIImage imageNamed:@"icon_like_normal.png"];
//        _unLikeImage=[UIImage imageNamed:@"icon_like_pressed.png"];
        _type=LikeBtnTypeFirework;
        [self initBaseLayout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame likeImage:(UIImage *)likeImage unLikeImage:(UIImage *)unLikeIamge{
    self=[super initWithFrame:frame];
    if (self) {
        _likeImage=likeImage;
        _unLikeImage=unLikeIamge;
        _type=LikeBtnTypeFirework;
        [self initBaseLayout];
    }
    return self;
}

/**
 *  Init base layout
 */
-(void)initBaseLayout{
    _isLike=NO;
    
    switch (_type) {
        case LikeBtnTypeFirework:{
            _effectLayer=[CAEmitterLayer layer];
            [_effectLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
            [self.layer addSublayer:_effectLayer];
            [_effectLayer setEmitterShape:kCAEmitterLayerCircle];
            [_effectLayer setEmitterMode:kCAEmitterLayerOutline];
            [_effectLayer setEmitterPosition:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2)];
            [_effectLayer setEmitterSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
            
            _effectCell=[CAEmitterCell emitterCell];
            [_effectCell setName:@"zanShape"];
            [_effectCell setContents:(__bridge id)[UIImage imageNamed:@"EffectImage-red"].CGImage];
            [_effectCell setAlphaSpeed:-1.0f];
            [_effectCell setLifetime:1.0f];
            [_effectCell setBirthRate:0];
            [_effectCell setVelocity:50];
            [_effectCell setVelocityRange:50];
            
            [_effectLayer setEmitterCells:@[_effectCell]];
            
            _likeImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
            [_likeImageView setImage:_unLikeImage];
            [_likeImageView setUserInteractionEnabled:YES];
            [self addSubview:_likeImageView];
            
            UITapGestureRecognizer *tapImageViewGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeAnimationPlay)];
            [_likeImageView addGestureRecognizer:tapImageViewGesture];
        }
            break;
        case LikeBtnTypeFocus:{
            
        }
            break;
        default:
            break;
    }
}

/**
 *  An animation for zan action
 */
-(void)likeAnimationPlay{
    [self setIsLike:!self.isLike];
    if (self.clickHandler!=nil) {
        self.clickHandler(self);
    }
    
    switch (_type) {
        case LikeBtnTypeFirework:{
            [_likeImageView setBounds:CGRectMake(0, 0, 0, 0)];
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear animations:^{
                [_likeImageView setBounds:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
                if (self.isLike) {
                    CABasicAnimation *effectLayerAnimation=[CABasicAnimation animationWithKeyPath:@"emitterCells.zanShape.birthRate"];
                    [effectLayerAnimation setFromValue:[NSNumber numberWithFloat:100]];
                    [effectLayerAnimation setToValue:[NSNumber numberWithFloat:0]];
                    [effectLayerAnimation setDuration:0.0f];
                    [effectLayerAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                    [_effectLayer addAnimation:effectLayerAnimation forKey:@"ZanCount"];
                }
            } completion:^(BOOL finished) {
            }];
            //            [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            //                [_zanImageView setBounds:CGRectMake(0, 0, CGRectGetWidth(self.frame)*1.5, CGRectGetHeight(self.frame)*1.5)];
            //            } completion:^(BOOL finished) {
            //                [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //                    [_zanImageView setBounds:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
            //                } completion:^(BOOL finished) {
            //                    if (self.isZan) {
            //                        CABasicAnimation *effectLayerAnimation=[CABasicAnimation animationWithKeyPath:@"emitterCells.zanShape.birthRate"];
            //                        [effectLayerAnimation setFromValue:[NSNumber numberWithFloat:100]];
            //                        [effectLayerAnimation setToValue:[NSNumber numberWithFloat:0]];
            //                        [effectLayerAnimation setDuration:0.0f];
            //                        [effectLayerAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            //                        [_effectLayer addAnimation:effectLayerAnimation forKey:@"ZanCount"];
            //                    }
            //                }];
            //            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Property method
-(void)setIsLike:(BOOL)isLike{
    _isLike=isLike;
    if (isLike) {
        [_likeImageView setImage:_likeImage];
    }else{
        [_likeImageView setImage:_unLikeImage];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

