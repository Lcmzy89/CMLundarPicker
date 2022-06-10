//
//  CMPickerView.m
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/10.
//

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define PICKER_CONTENT_TEXT_COLOR [UIColor colorWithRed:(((0x333333)>>16)&0xff)/255.0f green:(((0x333333)>>8)&0xff)/255.0f blue:((0x333333)&0xff)/255.0f alpha:1]
#define PICKER_CONFIRM_COLOR [UIColor colorWithRed:(((0x30D395)>>16)&0xff)/255.0f green:(((0x30D395)>>8)&0xff)/255.0f blue:((0x30D395)&0xff)/255.0f alpha:1]

#import "CMPickerView.h"

@interface _CMPickerBaseCell: UILabel
@end

@implementation _CMPickerBaseCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.textColor = [UIColor colorWithRed:(((0x333333)>>16)&0xff)/255.0f green:(((0x333333)>>8)&0xff)/255.0f blue:((0x333333)&0xff)/255.0f alpha:1];
        self.textAlignment = NSTextAlignmentCenter;
        self.lineBreakMode = NSLineBreakByClipping;
    }
    return self;
}
@end

@interface CMPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *maskBtn;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) CGFloat pickerViewHeight;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, Class> *classDic;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *selectIndexDic;
@end

@implementation CMPickerView

#pragma mark -Public
- (void)showInView:(UIView *)view {
    UIView *superView = view ? view : [UIApplication sharedApplication].keyWindow;
    [superView addSubview:self];
    [self show];
}

- (void)registerClass:(Class)viewClass forComponentIndexSet:(NSIndexSet *)indexSet {
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.classDic setObject:viewClass forKey:@(idx)];
    }];
}

- (void)reloadAllComponents {
    for(NSInteger i=0; i<_componentNum; i++) {
        NSInteger rowNumOfComponent = 0;
        if([self judgeDelegeteSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
            rowNumOfComponent = [self.delegate pickerView:self numberOfRowsInComponent:i];
        }
        NSInteger curSelectIdnex = [self.selectIndexDic objectForKey:@(i)].integerValue;
        NSInteger selectIndex = MIN(curSelectIdnex, rowNumOfComponent - 1);
        
        [self.selectIndexDic setObject:@(selectIndex) forKey:@(i)];
    }
    [self.pickerView reloadAllComponents];
}

- (void)reloadComponent:(NSInteger)component {
    for(NSInteger i=component; i<_componentNum; i++) {
        NSInteger rowNumOfComponent = 0;
        if([self judgeDelegeteSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
            rowNumOfComponent = [self.delegate pickerView:self numberOfRowsInComponent:i];
        }
        NSInteger curSelectIdnex = [self.selectIndexDic objectForKey:@(i)].integerValue;
        NSInteger selectIndex = MIN(curSelectIdnex, rowNumOfComponent - 1);
        
        [self.selectIndexDic setObject:@(selectIndex) forKey:@(i)];
    }
    [self.pickerView reloadComponent:component];
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    [self.pickerView selectRow:row inComponent:component animated:animated];
    [self pickerView:_pickerView didSelectRow:row inComponent:component];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component {
    NSNumber *selectNum = [self.selectIndexDic objectForKey:@(component)];
    if(selectNum.integerValue < 0 || selectNum == nil) {
        NSLog(@"sdklfs");
    }
    return (selectNum == nil) ? 0 : selectNum.integerValue;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerView numberOfRowsInComponent:component];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        _pickerViewHeight = 320 + 34;
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.coverView];
    [self addSubview:self.contentView];
    [self.coverView addSubview:self.maskBtn];
    [self.contentView addSubview:self.navBar];
    [self.contentView addSubview:self.pickerView];
    
    self.coverView.frame = self.bounds;
    self.maskBtn.frame = self.bounds;
    self.navBar.frame = CGRectMake(0, 12, SCREEN_WIDTH, 44);
    self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _pickerViewHeight + 12);
    self.pickerView.frame = CGRectMake(0, 12+44, SCREEN_WIDTH, 264);
}

#pragma mark -Action
- (void)show {
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.alpha = 1;
        
        CGRect countFrame = self.contentView.frame;
        countFrame.origin.y = SCREEN_HEIGHT - self.pickerViewHeight;
        self.contentView.frame = countFrame;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.alpha = 0;
        
        CGRect countFrame = self.contentView.frame;
        countFrame.origin.y = SCREEN_HEIGHT;
        self.contentView.frame = countFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)cancelBtnAction {
    [self dismiss];
}

- (void)confirmBtnAction {
    if([self judgeDelegeteSelector:@selector(pickerView:confirmWithSelectData:)]) {
        [self.delegate pickerView:self confirmWithSelectData:[self getCurrentSelectData]];
    }
    [self dismiss];
}

#pragma mark -Private
- (BOOL)judgeDelegeteSelector:(SEL)selector{
    return (self.delegate && [self.delegate respondsToSelector:selector]);
}

- (NSArray<NSNumber *> *)getCurrentSelectData {
    NSMutableArray *mutaArr = [NSMutableArray new];
    for(int i=0; i<self.componentNum; i++) {
        NSNumber *num = [self.selectIndexDic objectForKey:@(i)];
        num = (num == nil) ? @(0) : num;
        [mutaArr addObject: num];
    }
    return [mutaArr copy];
}

#pragma mark -UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.componentNum;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if([self judgeDelegeteSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
        return [self.delegate pickerView:self numberOfRowsInComponent:component];
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 56;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    Class customClass = [self.classDic objectForKey:@(component)];
    
    if(!customClass) {
        view = view ? view : [_CMPickerBaseCell new];
        if([self judgeDelegeteSelector:@selector(pickerView:strForRow:forComponent:)]) {
            ((_CMPickerBaseCell *)view).text = [self.delegate pickerView:self strForRow:row forComponent:component];
        }
    } else {
        view = view ? view : [[customClass alloc] init];
        if([self judgeDelegeteSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)]){
            view = [self.delegate pickerView:self viewForRow:row forComponent:component reusingView:view];
        }
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.selectIndexDic setObject:@(row) forKey:@(component)];
    if([self judgeDelegeteSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [self.delegate pickerView:self didSelectRow:row inComponent:component];
    }
}

#pragma mark -Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setComponentNum:(NSInteger)componentNum {
    _componentNum = componentNum;
    for(int i=0; i<componentNum; i++) {
        if(![self.selectIndexDic objectForKey:@(i)]) {
            [self.selectIndexDic setObject:@(0) forKey:@(i)];
        }
    }
}

#pragma mark -Lazy
- (UIPickerView *)pickerView {
    if(!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return _coverView;
}

- (UIButton *)maskBtn {
    if(!_maskBtn) {
        _maskBtn = [UIButton new];
        _maskBtn.backgroundColor = UIColor.clearColor;
        [_maskBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskBtn;
}

- (UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 12;
        _contentView.backgroundColor = UIColor.whiteColor;
    }
    return _contentView;
}

- (NSMutableDictionary<NSNumber *,Class> *)classDic {
    if(!_classDic) {
        _classDic = [NSMutableDictionary new];
    }
    return _classDic;
}

- (NSMutableDictionary<NSNumber *,NSNumber *> *)selectIndexDic {
    if(!_selectIndexDic) {
        _selectIndexDic = [NSMutableDictionary new];
    }
    return _selectIndexDic;
}

- (UIView *)navBar {
    if(!_navBar) {
        _navBar = [UIView new];
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 44)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [cancelBtn setTitleColor:PICKER_CONTENT_TEXT_COLOR forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, SCREEN_WIDTH-128, 44)];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIButton *confirm = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 64, 0, 64, 44)];
        [confirm setTitleColor:PICKER_CONFIRM_COLOR forState:UIControlStateNormal];
        [confirm addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [confirm setTitle:@"确定" forState:UIControlStateNormal];
        confirm.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        
        [_navBar addSubview:cancelBtn];
        [_navBar addSubview:_titleLabel];
        [_navBar addSubview:confirm];
    }
    return _navBar;
}
@end
