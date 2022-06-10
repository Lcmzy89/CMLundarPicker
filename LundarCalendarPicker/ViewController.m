//
//  ViewController.m
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/9.
//

#import "ViewController.h"
#import "CMLundarCalendarManager.h"
#import "CMPickerView.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define CONTENT_TEXT_COLOR [UIColor colorWithRed:(((0x333333)>>16)&0xff)/255.0f green:(((0x333333)>>8)&0xff)/255.0f blue:((0x333333)&0xff)/255.0f alpha:1]
#define CONFIRM_COLOR [UIColor colorWithRed:(((0x30D395)>>16)&0xff)/255.0f green:(((0x30D395)>>8)&0xff)/255.0f blue:((0x30D395)&0xff)/255.0f alpha:1]

@interface ViewController ()<CMPickerViewDelegate>
@property (nonatomic, strong) NSArray<CMLundarCalendarYearModel *> *lundarDateData;
@property (nonatomic, strong) CMPickerView *datePicker;
@property (nonatomic, strong) CMLundarCalendarDayModel *selectData;    // 选中的时间

@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.showButton];
    self.showButton.frame = CGRectMake(SCREEN_WIDTH/2-50, 100, 100, 50);
    [self.view addSubview:self.contentLabel];
    self.contentLabel.frame = CGRectMake(SCREEN_WIDTH/2-100, 200, 200, 100);
    [self updateSelectData];
}

- (void)showDatePicker {
    NSArray<NSNumber *> * indexArr = [CMLundarCalendarManager safeIndexOfDay:self.selectData inYears:self.lundarDateData];
    [self.datePicker selectRow:indexArr[0].integerValue inComponent:0 animated:NO];
    [_datePicker selectRow:indexArr[1].integerValue inComponent:1 animated:NO];
    [_datePicker selectRow:indexArr[2].integerValue inComponent:2 animated:NO];
    [_datePicker showInView:nil];
}

- (void)updateSelectData {
    NSTimeInterval time = self.selectData.time;
    NSString *calendarStr = [self.dateFormatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970:time]];
    NSString *lundarStr = [NSString stringWithFormat:@"%ld-%02ld-%02ld", self.selectData.year, self.selectData.month, self.selectData.day];
    NSString *lundarDescStr = [NSString stringWithFormat:@"%@ %@ %@", self.selectData.yearStr, self.selectData.monthStr, self.selectData.dayStr];
    self.contentLabel.text = [NSString stringWithFormat:@"公历：%@\n农历：%@\n%@\n", calendarStr, lundarStr, lundarDescStr];
}

#pragma mark -Delegate
- (NSInteger)pickerView:(CMPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numOfRow = 0;
    if(component == 0) {
        numOfRow = self.lundarDateData.count;
    } else if(component == 1){
        NSInteger yearIndex = [pickerView selectedRowInComponent:0];
        numOfRow = self.lundarDateData[yearIndex].monthArr.count;
    } else if(component == 2) {
        NSInteger yearIndex = [pickerView selectedRowInComponent:0];
        NSInteger monthIndex = [pickerView selectedRowInComponent:1];
        numOfRow = self.lundarDateData[yearIndex].monthArr[monthIndex].dayArr.count;
    }
    return numOfRow;
}

- (NSString *)pickerView:(CMPickerView *)pickerView strForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0) {    // 年
        return [NSString stringWithFormat:@"%ld年", self.lundarDateData[row].year];
    } else if(component == 1) { // 月
        NSInteger yearIndex = [pickerView selectedRowInComponent:0];
        if(row >= self.lundarDateData[yearIndex].monthArr.count) { return @""; }
        return self.lundarDateData[yearIndex].monthArr[row].monthStr;
    } else if(component == 2) {
        NSInteger yearIndex = [pickerView selectedRowInComponent:0];
        NSInteger monthIndex = [pickerView selectedRowInComponent:1];
        return self.lundarDateData[yearIndex].monthArr[monthIndex].dayArr[row].dayStr;
    }
    return @"";
}

- (void)pickerView:(CMPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component == 0) {
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    } else if(component == 1){
        [pickerView reloadComponent:2];
    }
    [self updateSelectData];
}

- (void)pickerView:(CMPickerView *)pickerView confirmWithSelectData:(NSArray<NSNumber *> *)selectIndexArr {
    if(selectIndexArr.count < 3) { return; }
    self.selectData = self.lundarDateData[selectIndexArr[0].integerValue].monthArr[selectIndexArr[1].integerValue].dayArr[selectIndexArr[2].integerValue];
    [self updateSelectData];
}

- (CMPickerView *)datePicker {
    if(!_datePicker) {
        _datePicker = [CMPickerView new];
        _datePicker.componentNum = 3;
        _datePicker.title = @"选择日期";
        _datePicker.delegate = self;
    }
    return _datePicker;
}

- (NSArray<CMLundarCalendarYearModel *> *)lundarDateData {
    if(!_lundarDateData) {
        // 展示从1901到今天为止的时间
        CMLundarCalendarDayModel *beginDayModel = [CMLundarCalendarManager dayFor:1901 month:1 day:1];
        _lundarDateData = [CMLundarCalendarManager yearsFromBeginTime:beginDayModel.time endTime:[NSDate new].timeIntervalSince1970];
    }
    return _lundarDateData;
}

- (CMLundarCalendarDayModel *)selectData {
    if(!_selectData) {
        _selectData = self.lundarDateData.lastObject.monthArr.lastObject.dayArr.lastObject;
    }
    return _selectData;
}

- (UIButton *)showButton {
    if(!_showButton) {
        _showButton = [UIButton new];
        _showButton.backgroundColor = CONFIRM_COLOR;
        [_showButton setTitle:@"选择时间" forState:UIControlStateNormal];
        [_showButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_showButton addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showButton;
}

- (UILabel *)contentLabel {
    if(!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _contentLabel.layer.masksToBounds = YES;
        _contentLabel.layer.cornerRadius = 12;
        _contentLabel.layer.borderColor = UIColor.grayColor.CGColor;
        _contentLabel.layer.borderWidth = 1;
        _contentLabel.textColor = CONTENT_TEXT_COLOR;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}
@end
