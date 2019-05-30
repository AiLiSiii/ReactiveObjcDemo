//
//  ViewController.m
//  ReactiveObjcDemo
//
//  Created by 王龙飞 on 2019/5/30.
//  Copyright © 2019年 MDDPersonal. All rights reserved.
//**** 修改 methodNumber 执行对应index的方法
//注意：[disposable dispose]；取消订阅

#import "ViewController.h"
#import <ReactiveObjC.h>
#import <Masonry.h>

@interface ViewController ()

@property (nonatomic, strong) UITextField *accountField;

@property (nonatomic, strong) UITextField *pwdField;

@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) RACDisposable *disposable;

@property (nonatomic, assign) NSInteger methodNumber;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //初始化UI
    [self initUI];
    //执行方法
    self.methodNumber = 0;
    [self runMethod];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}



-(void)runMethod {
    switch (self.methodNumber) {
        case 0:
            [self RACSignalMethod];
            break;
        case 1:
            [self RACSubjectMethod];
            break;
        case 2:
            [self RACTupleMethod];
            break;
        case 3:
            [self arrayRAC_SequenceMethod];
            break;
        case 4:
            [self dictionaryRAC_SequenceMethod];
            break;
        case 5:
            [self arrayRAC_SequenceMapMethod];
            break;
        case 6:
            [self arrayRAC_seaqueceMapMethod];
            break;
        case 7:
            [self textFieldTextObserveMethod];
            break;
        case 8:
            [self loginButtonObserveMethod];
            break;
        case 9:
            [self notificationObserveMethod];
            break;
        case 10:
            [self btnInSubViewMethod];
            break;
        case 11:
            [self valuesChangeObserveMethod];
            break;
        case 12:
            [self toReplaceNSTimerMethod];
            break;

        default:
            break;
    }
}


//创建信号 - 订阅信号 - 发送信号
- (void)RACSignalMethod {
    
/*创建信号*/
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        /*发送信号*/
        [subscriber sendNext:@"发送信号"];
        
        return nil;
    }];
    
/*订阅信号*/
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号内容：%@",x);
    }];
    
    
/*取消订阅*/
    [disposable dispose];
}


- (void)RACSubjectMethod {
/*创建信号*/
    RACSubject *subject = [RACSubject subject];
/*发送信号*/
    [subject sendNext:@"发送信号"];
/*订阅信号 用法类似于代理*/
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号内容：%@",x);
    }];
}


/**
 RACTuple 元祖 类似于OC数组
 */
- (void)RACTupleMethod {
/*创建元组*/
    RACTuple *tuple = [RACTuple tupleWithObjects:@"1",@"2",@"3", nil];
/*从别的数组获取元祖*/
    RACTuple *tuple1 = [RACTuple tupleWithObjectsFromArray:@[@"1",@"2",@"3"]];
/*使用RAC宏快速封装*/
    RACTuple *tuple2 = RACTuplePack(@"1",@"2",@"3");
    NSLog(@"取元祖内容：%@",tuple[0]);
    NSLog(@"第一个元素：%@",tuple1.first);
    NSLog(@"最后一个元素：%@",tuple2.last);
}

- (void)arrayRAC_SequenceMethod {
  /*遍历数组*/
    NSArray *array = @[@"1",@"2",@"3",@"4"];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"数组内容：%@",x);//x可以是任何对象
    }];
}

- (void)dictionaryRAC_SequenceMethod {
/*遍历字典*/
    NSDictionary *dict = @{@"key1":@"value1",@"key2":@"value2",@"key3":@"value3"};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;//x是一个元祖，这个宏可以将key，value拆开
        NSLog(@"字典内容：%@：%@",key,value);
    }];
}

- (void)arrayRAC_SequenceMapMethod {
/*单个内容替换 替换为0,生成新的数组，不改变原数组*/
   NSArray *array = @[@"1",@"2",@"3"];
    NSArray *newArray = [[array.rac_sequence map:^id _Nullable(id  _Nullable value) {
        NSLog(@"数组内容：%@",value);
        return @"0";//将所有内容替换为0
    }]array] ;
    NSLog(@"newArray: %@,%@;array:%@,%@",newArray,newArray.firstObject,array,array.firstObject);
}


- (void)arrayRAC_seaqueceMapMethod {
/*内容快速替换*/
    NSArray *array = @[@"1",@"2",@"3"];
    NSArray *newArray = [[array.rac_sequence mapReplace:@"0"] array];
    NSLog(@"newArray: %@,%@;array:%@,%@",newArray,newArray.firstObject,array,array.firstObject);
}


/**
 文本内容监听
 */
- (void)textFieldTextObserveMethod {
    // Returns a new signal with only those values that passed
    //返回一个新信号，其中只包含传递的那些值
    [[self.accountField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        
        return value.length > 5; // 表示输入文字长度 > 5 时才会调用下面的 block
        
    }] subscribeNext:^(NSString * _Nullable x) {
        
        NSLog(@"输入框内容：%@", x);
    }];
//   BOOL isMax = [self.accountField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
//        NSLog(@"输入框内容value：%@", value);
//        return value.length>5;//表示字符串5 才会调用订阅方法
//    }];
//    [self.accountField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
//        NSLog(@"输入框内容：%@", x);
//    }];
//    if (isMax) {
//        [self.accountField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
//            NSLog(@"输入框内容：%@", x);
//        }];
//    }else {
//        NSLog(@"输入框内容：----");
//    }
}


/**
 登录按钮状态实时监听 用户名 密码不为空 时可点击
 */
- (void)loginButtonObserveMethod {
    RAC(_loginButton,enabled) = [RACSignal combineLatest:@[_accountField.rac_textSignal,_pwdField.rac_textSignal] reduce:^id _Nonnull(NSString *account,NSString *pwd){
        return @(account.length && pwd.length);
    }];
}

/**
 监听NSNotification 事件
 */
- (void)notificationObserveMethod {
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:UIKeyboardDidShowNotification object:nil]subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@ 键盘弹起",x);//x 是通知对象
    }];
}


/**
 self.view中执行 loginButtonClick方法 省去监听以及delegate
 */
- (void)btnInSubViewMethod {
    
    [[self.view rac_signalForSelector:@selector(loginButtonClick)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@" view 中的按钮被点击了");
    }];
}

- (void)loginButtonClick {
    NSLog(@" 按钮被点击了");
}


/**
 代替KVO监听
 */
- (void)valuesChangeObserveMethod {
    [[self.accountField rac_valuesForKeyPath:@"text" observer:self]subscribeNext:^(id  _Nullable x) {
        NSLog(@"编辑内容：%@",x);
    }];
    //可以替换成RAC的宏
    [RACObserve(self.accountField, text)subscribeNext:^(id  _Nullable x) {
        NSLog(@"编辑内容：%@",x);
    } completed:^{
        
    }];
}


/**
 代替定时器NSTimer
 */
- (void)toReplaceNSTimerMethod {
    __weak typeof(self) weakSelf = self;
    self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"当前时间：%@", x);
        //取消订阅
        [weakSelf.disposable dispose];
    }];
}


#pragma mark **** init UI

-(UITextField *)accountField {
    if (!_accountField) {
        _accountField = [[UITextField alloc]init];
        _accountField.borderStyle = UITextBorderStyleLine;
        _accountField.font = [UIFont systemFontOfSize:14];
        _accountField.placeholder = @"请输入用户名";
    }
    return _accountField;
}

-(UITextField *)pwdField {
    if (!_pwdField) {
        _pwdField = [[UITextField alloc]init];
        _pwdField.borderStyle = UITextBorderStyleLine;
        _pwdField.font = [UIFont systemFontOfSize:14];
        _pwdField.placeholder = @"请输入密码";
    }
    return _pwdField;
}

-(UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setBackgroundColor:[UIColor blueColor]];
        _loginButton.layer.cornerRadius = 4;
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
//        [_loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.enabled = NO;
    }
    return _loginButton;
}

- (void)initUI {
    
    [self.view addSubview:self.accountField];
    [self.view addSubview:self.pwdField];
    [self.view addSubview:self.loginButton];
    
    CGFloat marginX = 40;
    CGFloat marginY = 80;
    CGFloat fieldH = 35;
    CGFloat buttonH = 45;
    CGFloat cenMarginY = 20;
    [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(marginX);
        make.right.equalTo(self.view.mas_right).offset(-marginX);
        make.top.equalTo(self.view.mas_top).offset(marginY);
        make.height.mas_equalTo(fieldH);
    }];
    
    [self.pwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(marginX);
        make.right.equalTo(self.view.mas_right).offset(-marginX);
        make.top.equalTo(self.accountField.mas_bottom).offset(cenMarginY);
        make.height.mas_equalTo(fieldH);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(marginX);
        make.right.equalTo(self.view.mas_right).offset(-marginX);
        make.top.equalTo(self.pwdField.mas_bottom).offset(cenMarginY);
        make.height.mas_equalTo(buttonH);
    }];
    
}



@end
