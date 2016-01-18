
#import "ShareView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>

/*   <!-- 应用规范字体大小 -->*/
#define  text_size_big_1    21
#define  text_size_big_2    20
#define  text_size_big_3    19
#define  text_size_middle_1 18
#define  text_size_middle_2 17
#define  text_size_middle_3 15
#define  text_size_little_1 14
#define  text_size_little_2 13
#define  text_size_little_3 12
#define  text_size_little_4 10
#define  text_size_other    16

#define  AppFont(c_font) [UIFont systemFontOfSize:c_font]
#define ApplicationframeValue [[UIScreen mainScreen]bounds].size


//**提示框宏定义
CG_INLINE void AlertLog (NSString *titleStr,NSString *message,NSString *button1,NSString *button2)
{
    if(!titleStr)
        titleStr = @"";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: titleStr
                                                        message: message
                                                       delegate: nil
                                              cancelButtonTitle: button1
                                              otherButtonTitles: button2,
                              nil];
    [alertView show];
    
}
@interface ShareView ()
@property (nonatomic,strong)NSArray *imageArr;
@property (nonatomic,strong)NSArray *titleArr;


@end



@implementation ShareView

-(NSArray *)imageArr
{

    if (!_imageArr) {
        _imageArr = [NSArray arrayWithObjects:@"icon_wechat",@"icon_friend",nil];
    }
    return _imageArr;
}

-(NSArray *)titleArr
{
    
    if (!_titleArr) {
        _titleArr = [NSArray arrayWithObjects:NSLocalizedString(@"share_wechat", nil),NSLocalizedString(@"share_friend", nil),nil];
    }
    return _titleArr;
}


-(id)initWithFrame:(CGRect)frame
{
    float Margin = ceilf(ApplicationframeValue.width/self.imageArr.count/3);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.overlayView.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
        [self.overlayView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *viewS = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ApplicationframeValue.width, 160)];
        viewS.backgroundColor =[UIColor whiteColor];
        [self addSubview:viewS];
        
        UILabel *TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((ApplicationframeValue.width-100)/2, 15, 100, 20)];
        TitleLabel.textAlignment = NSTextAlignmentCenter;
        TitleLabel.text = NSLocalizedString(@"share_title", nil);
        TitleLabel.backgroundColor = [UIColor whiteColor];
        TitleLabel.font = AppFont(text_size_other);
        [viewS addSubview:TitleLabel];
        
        UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45, ApplicationframeValue.width, 1)];
        lineImage.alpha = 0.5f;
        lineImage.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4f];
        [viewS addSubview:lineImage];
     
        for (int i = 0; i < [self.imageArr count]; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i +1;
            btn.frame = CGRectMake(Margin*3/2+2*Margin*i,60, Margin, Margin);
            [btn setBackgroundImage:[UIImage imageNamed:self.imageArr[i]] forState:UIControlStateNormal];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(Margin*3/2+2*Margin*i, CGRectGetMaxY(btn.frame)+10, Margin, 15)];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.text = self.titleArr[i];
            label.font = AppFont(text_size_little_2);
            label.adjustsFontSizeToFitWidth = YES;
            [btn addTarget:self action:@selector(onBtn:) forControlEvents:UIControlEventTouchUpInside];
            [viewS addSubview:label];
            [viewS addSubview:btn];
        }
        
    }
    return self;
}

-(void)onBtn:(UIButton *)sender{
    
    switch (sender.tag) {
            //朋友圈
        case 1:{
            //1、创建分享参数
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            NSArray* imageArray = @[[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.pictureName]]]];
            if (imageArray)
            {
                [shareParams SSDKSetupShareParamsByText:self.title
                                                 images:imageArray
                                                    url:[NSURL URLWithString:self.shareUrl]
                                                  title:nil
                                                   type:SSDKContentTypeAuto];
            }
            
            //2、分享
            [ShareSDK share:SSDKPlatformSubTypeWechatSession
                 parameters:shareParams
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
             {
                 switch (state) {
                     case SSDKResponseStateSuccess:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                             message:nil
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"确定"
                                                                   otherButtonTitles:nil];
                         //[alertView show];
                         break;
                     }
                     case SSDKResponseStateFail:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                             message:[NSString stringWithFormat:@"%@", error]
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"确定"
                                                                   otherButtonTitles:nil];
                         //[alertView show];
                         break;
                     }
                     case SSDKResponseStateCancel:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                             message:nil
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"确定"
                                                                   otherButtonTitles:nil];
                         //[alertView show];
                         break;
                     }
                     default:
                         break;
                 }
             }];
            
        }
            break;
        case 2:{
            //1、创建分享参数
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            NSArray* imageArray = @[[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.pictureName]]]];
            if (imageArray)
            {
                [shareParams SSDKSetupShareParamsByText:self.title
                                                 images:imageArray
                                                    url:[NSURL URLWithString:self.shareUrl]
                                                  title:nil
                                                   type:SSDKContentTypeAuto];

            }
            
            //2、分享
            [ShareSDK share:SSDKPlatformSubTypeWechatTimeline
                 parameters:shareParams
             onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
             {
                 switch (state) {
                     case SSDKResponseStateSuccess:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                             message:nil
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"确定"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                         break;
                     }
                     case SSDKResponseStateFail:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                             message:[NSString stringWithFormat:@"%@", error]
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"确定"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                         break;
                     }
                     case SSDKResponseStateCancel:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                             message:nil
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"确定"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                         break;
                     }
                     default:
                         break;
                 }
             }];
            
        }
            break;

        }
    
}

-(void)onCancleBtn{

    [self dismiss];

}


- (void)show
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self.overlayView];
    [keywindow addSubview:self];
    
    [self fadeIn];
}

- (void)dismiss
{
    [self fadeOut];
}

//弹入层
- (void)fadeIn
{

    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
       
        self.alpha = 1;
 
    }];
    
}

//弹出层
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{

        self.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self.overlayView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

@end
