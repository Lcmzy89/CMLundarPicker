//
//  CMPickerView.h
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/10.
//

#import <UIKit/UIKit.h>
@class CMPickerView;

NS_ASSUME_NONNULL_BEGIN

@protocol CMPickerViewDelegate <NSObject>

- (NSInteger)pickerView:(CMPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
@optional
/// 没有注册过。就会调用该代理 返回文案
- (NSString *)pickerView:(CMPickerView *)pickerView strForRow:(NSInteger)row forComponent:(NSInteger)component;
/// 注册过的列 会调用这个代理 更新reusingView返回
- (UIView *)pickerView:(CMPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
/// 选中某一列的回调
- (void)pickerView:(CMPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
/// 确认按钮的回调 参数为 选中的下标数组
- (void)pickerView:(CMPickerView *)pickerView confirmWithSelectData:(NSArray<NSNumber *> *)selectIndexArr;

@end

@interface CMPickerView : UIView
@property(nonatomic, weak) id<CMPickerViewDelegate> delegate;
@property (nonatomic, assign) NSInteger componentNum;
@property (nonatomic, copy) NSString *title;

- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;
/// 会触发didselect
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (NSInteger)selectedRowInComponent:(NSInteger)component;
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

/// 为 列 注册class
- (void)registerClass:(Class)viewClass forComponentIndexSet:(NSIndexSet *)indexSet;
- (void)showInView:(UIView * _Nullable)view;  // view传nil 显示在Window上
@end

NS_ASSUME_NONNULL_END
