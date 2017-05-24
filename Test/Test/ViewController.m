//
//  ViewController.m
//  Test
//
//  Created by ethome on 16/3/8.
//  Copyright © 2016年 ethome. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <DXPopover.h>
#import "MyView.h"
#import "AESCrypt.h"
#import "GTMBase64.h"
#import "JDStatusBarNotification.h"
#import "NSString+Md5.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *hehe;
@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, strong) UIButton *titleLBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

BOOL macDecrease(char * mac);

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}
- (IBAction)cancel:(id)sender {
    
    [self.textField resignFirstResponder];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [JDStatusBarNotification showWithStatus:@"哈哈" dismissAfter:2.0 styleName:@"style"];
    
    [self setupNavTitleView];
    
    [self getFirstPhoto];
    
    self.textField.inputView = self.pickerView;
    
    self.textField.inputAccessoryView = self.toolBar;
    

        
    NSString *message = @"lmkaaaaaaaa6";
    NSString *password = @"ethome";
    
    NSString *encryptedData = [AESCrypt encrypt:message password:password];

    NSString *newMsg = [AESCrypt decrypt:encryptedData password:password];
    
    NSLog(@"%@,%@",encryptedData,newMsg);
    
    
    NSString* message1 =@"lmk12345";
//    NSData* mData = [message1 dataUsingEncoding:NSUTF8StringEncoding];
//    if([mData length]>0){
//        //data = [GTMBase64 encodeData:data];//编码
//        NSString *base64EncodedString = [GTMBase64 stringByEncodingData:mData];
//        NSString* origin_str=[[NSString alloc] initWithData:[GTMBase64 decodeString: base64EncodedString]encoding:NSUTF8StringEncoding];
//        NSLog(@"%@,%@",base64EncodedString,origin_str);
//
//        
//    }

    NSString *base64 = [GTMBase64 encodeBase64String:message1];
    
    NSString* origin_str = [GTMBase64 decodeBase64String:base64];
    
    NSLog(@"%@,%@",base64,origin_str);

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(typeButtonClick:) name:@"RecordBtnClick" object:nil];

    
     // Do any additional setup after loading the view, typically from a nib.
    
    
    [UIView animateWithDuration:2 animations:^{
        
        _imageView.transform = CGAffineTransformRotate(_imageView.transform, 20*M_PI/180);
        
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2 animations:^{
           
            _imageView.transform = CGAffineTransformRotate(_imageView.transform, -20*M_PI/180);
            
        }];
        
        
    }];
    char mychar[18];
    NSString * mystring = @"1c:87:79:a0:ff:00";
    strcpy(mychar,(char *)[mystring UTF8String]);
    
    
    
    if(TRUE == macDecrease(mychar)){
        printf("new mac for decrease is :%s\n",mychar);
    
        NSLog(@"%@",[[NSString stringWithFormat:@"%s",mychar] lowercaseString]);
    }
    else{
        
        mystring=[NSString stringWithFormat:@"%s",mychar];
    }
    

    NSString *phone = @"1560653521";
    
    NSLog(@"%d",[self checkPhoneNumInput:phone]);
    
    
    NSLog(@"%@",NSLocalizedString(@"你好", nil));
    
    
  }

-(BOOL)checkPhoneNumInput:(NSString *)phoneNumber{
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    BOOL result = [regextestmobile evaluateWithObject:phoneNumber];
    
    return result;
    
}

BOOL macDecrease(char * mac) //DECREASE MAC BY ONE
{
    int num=16;
    while(num>=0)
    {
        if('a' == mac[num])
        {
            mac[num]='9';
            break;
        }
        else if('0' == mac[num])
        {
            mac[num]='f';
            num--;
        }
        else if(':' == mac[num])
        {
            num--;
        }
        else
        {
            mac[num]--;
            break;
        }
    }
    if(-1 == num)
        return FALSE; //DECREASE FAIL
    else
        return TRUE;
}


- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

- (IBAction)scanAction:(UIButton *)sender {
    
//    //初始化相机控制器
//    ZBarReaderViewController *reader = [ZBarReaderViewController new];
//    
//    //设置代理
//    reader.readerDelegate = self;
//    //基本适配
//    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
//    
//    //二维码/条形码识别设置
//    ZBarImageScanner *scanner = reader.scanner;
//    
//    [scanner setSymbology: ZBAR_I25
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
//    //弹出系统照相机，全屏拍摄
//    [self presentModalViewController: reader
//                            animated: YES];
    
    
    
    
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    // 得到条形码结果
//    id<NSFastEnumeration> results =
//    [info objectForKey: ZBarReaderControllerResults];
//    ZBarSymbol *symbol = nil;
//    for(symbol in results)
//        break;
//    //获得到条形码
//    //NSString *dataNum=symbol.data;
//    //扫描界面退出
//    [picker dismissModalViewControllerAnimated: YES];
//}

- (void)getFirstPhoto{
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    // 在资源的集合中获取第一个集合，并获取其中的图片
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    PHAsset *asset = [assetsFetchResults firstObject];
    [imageManager requestImageForAsset:asset
                            targetSize:CGSizeMake(100, 100)
                           contentMode:PHImageContentModeAspectFill
                               options:nil
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                             
                             // 得到一张 UIImage，展示到界面上
                             
                             
                             [self.imageView setImage:result];
                             
                             
                         }];

}

- (void)typeButtonClick:(NSNotification *)note{
    [self.popover dismiss];
    
    NSString *recordType = note.userInfo[@"Title"];
    
    [_titleLBtn setTitle:recordType forState:UIControlStateNormal];

}




- (void)setupNavTitleView{
    
    
    _titleLBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleLBtn setTitle:@"录像关闭" forState:UIControlStateNormal];
    [_titleLBtn setImage:[UIImage imageNamed:@"LuckyMoney_ChangeArrow"] forState:UIControlStateNormal];
    [_titleLBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_titleLBtn addTarget:self action:@selector(titleShowPopover) forControlEvents:UIControlEventTouchUpInside];
    _titleLBtn.frame = CGRectMake(0, 0, 120, 40);
    [_titleLBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 100, 0, 0)];
    [_titleLBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    self.navigationItem.titleView = _titleLBtn;
    
}


- ( void)titleShowPopover{
    self.popover = [DXPopover new];
    self.popover.maskType = DXPopoverMaskTypeBlack;
    self.popover.contentInset = UIEdgeInsetsZero;
    self.popover.backgroundColor = [UIColor whiteColor];

    MyView *typeView = [[MyView alloc] initWithFrame:CGRectMake(0, 0, 100, 140)];
    typeView.backgroundColor = [UIColor clearColor];
    
    UIView *titleView = self.navigationItem.titleView;
    CGPoint startPoint =
    CGPointMake(CGRectGetMidX(titleView.frame), CGRectGetMaxY(titleView.frame) + 20);
    
    [self.popover showAtPoint:startPoint
               popoverPostion:DXPopoverPositionDown
              withContentView:typeView
                       inView:self.tabBarController.view];
    __weak typeof(self) weakSelf = self;
    self.popover.didDismissHandler = ^{
        [weakSelf bounceTargetView:titleView];
    };
    
}


- (void)bounceTargetView:(UIView *)targetView {
    targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.3
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         targetView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
