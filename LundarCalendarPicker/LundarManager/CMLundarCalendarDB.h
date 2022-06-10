//
//  CMLundarCalendarDB.h
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMLundarCalendarDB : NSObject
/// 获取某一年的闰月 返回0说明没有闰月 -1说明参数超出范围
/// @param year 年
+ (NSInteger)getLeapMonthInYear:(NSInteger)year;

/// 获取某一年的月数量 返回-1说明参数超出范围
/// @param year 年
+ (NSInteger)getMonthNumInYear:(NSInteger)year;

/// 获取某一个月有多少天 返回-1说明参数有错
/// @param year 年
/// @param month 月
+ (NSInteger)getMonthDaysInYear:(NSInteger)year month:(NSInteger)month;

/// 获取一年有多少天 返回 -1说明参数超出范围
/// @param year 年
+ (NSInteger)getYearDaysInYear:(NSInteger)year;
@end

NS_ASSUME_NONNULL_END
