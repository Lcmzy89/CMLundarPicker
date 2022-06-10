//
//  CMLundarCalendarManager.h
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface CMLundarCalendarDayModel : NSObject
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger day;
@property (nonatomic, copy) NSString *dayStr;   // 农历中文
@property (nonatomic, copy) NSString *yearStr;  // 农历年
@property (nonatomic, copy) NSString *monthStr; // 农历中文 比如润二月
@property (nonatomic, assign) NSTimeInterval time;
@end

@interface CMLundarCalendarMonthModel : NSObject
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger dayNum;
@property (nonatomic, copy) NSString *monthStr; // 农历中文 比如润二月
@property (nonatomic, assign) BOOL isLeap;  // 是否是闰月

@property (nonatomic, strong) NSArray<CMLundarCalendarDayModel *> *dayArr;
@end

@interface CMLundarCalendarYearModel : NSObject
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger lundarYear;
@property (nonatomic, assign) NSUInteger monthNum;
@property (nonatomic, copy) NSString *yearStr;  // 农历年
@property (nonatomic, strong) NSArray<CMLundarCalendarMonthModel *> *monthArr;
@end

@interface CMLundarCalendarManager : NSObject
/// 获取某一个时间段
+ (NSArray<CMLundarCalendarYearModel *> *)yearsFromBeginTime:(NSTimeInterval )beginTime endTime:(NSTimeInterval)endTime;
/// 获取农历的所有数据 公元1901年2月19日到公元2051年2月10日期间的公历日期
+ (NSArray<CMLundarCalendarYearModel *> *)getAllLundarCalendar;
/// 获取某个时间戳的农历
+ (CMLundarCalendarDayModel *)getLundarDayInTime:(NSTimeInterval)time;
/// 获取某一天 不合法的话会返回nil
+ (CMLundarCalendarDayModel *)dayFor:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/// 从时间段数据中获取某一天的下标 数组中一定会有三个元素 safe 如果daymodel没有在时间段中 下标会返回 0
+ (NSArray<NSNumber *> *)safeIndexOfDay:(CMLundarCalendarDayModel *)dayModel inYears:(NSArray<CMLundarCalendarYearModel *> *)years;
// 同上 如果如果daymodel没有在时间段中 对应的下标会返回 -1
+ (NSArray<NSNumber *> *)indexOfDay:(CMLundarCalendarDayModel *)dayModel inYears:(NSArray<CMLundarCalendarYearModel *> *)years;
@end

NS_ASSUME_NONNULL_END
