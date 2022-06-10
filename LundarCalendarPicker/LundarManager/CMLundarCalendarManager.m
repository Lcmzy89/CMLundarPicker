//
//  CMLundarCalendarManager.m
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/9.
//

#import "CMLundarCalendarManager.h"
#import "CMLundarCalendarDB.h"

static const int YEAR_BASE = 1901;  // 起始年限
static const int YEAR_NUM = 150;    // 年数

static const NSArray<NSString *> *sixtyYearCycleNameArr;
static const NSArray<NSString *> *chineseDayNameArr;

/// 获取阴历年的名称
NSString *sixtyCycleYearStr(NSUInteger lundarYear) {
    if(lundarYear < 1 || lundarYear>60) { return @""; }
    if(!sixtyYearCycleNameArr) {
        sixtyYearCycleNameArr = @[@"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                              @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                              @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                              @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                              @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                              @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥"];
    }
    return sixtyYearCycleNameArr[lundarYear - 1];
}

NSString *chineseMonthStr(NSUInteger year, NSUInteger monthNum) {
    NSInteger leapMonth = [CMLundarCalendarDB getLeapMonthInYear:year];
    if(leapMonth == -1) { return @""; }
    NSArray<NSString *> *nameArr = @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"冬月", @"腊月"];
    NSArray<NSString *> *monthNumArr = @[@"一月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"十一月", @"十二月"];
    if(leapMonth == 0) {
        if(monthNum < 1 || monthNum > 12) { return @""; }
        return nameArr[monthNum - 1];
    } else {
        if(monthNum < 1 || monthNum > 13) { return @""; }
        if(leapMonth == (monthNum - 1)) {   // 比如闰五月 monthNum=6 leapMonth=5
            return [NSString stringWithFormat:@"闰%@", monthNumArr[leapMonth - 1]];
        } else {
            NSInteger index = (monthNum <= leapMonth) ? monthNum - 1 : (monthNum - 2);
            return nameArr[index];
        }
    }
}

NSString *chineseDayStr(NSUInteger dayNum) {
    if(dayNum > 30) { return @""; }
    if(!chineseDayNameArr) {
        chineseDayNameArr = @[ @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                               @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                               @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"];
    }
    return chineseDayNameArr[dayNum - 1];
}

@implementation CMLundarCalendarYearModel
- (NSArray<CMLundarCalendarMonthModel *> *)monthArr {
    if(!_monthArr) {
        NSMutableArray *mutaArr = [NSMutableArray new];
        for(int i=1; i<=_monthNum; i++) {
            CMLundarCalendarMonthModel *model = [CMLundarCalendarMonthModel new];
            model.year = _year;
            model.month = i;
            model.dayNum = [CMLundarCalendarDB getMonthDaysInYear:_year month:i];
            model.isLeap = ([CMLundarCalendarDB getLeapMonthInYear:_year] == i);
            model.monthStr = chineseMonthStr(_year, i);
            [mutaArr addObject:model];
        }
        _monthArr = mutaArr;
    }
    return _monthArr;
}
@end

@implementation CMLundarCalendarMonthModel
- (NSArray<CMLundarCalendarDayModel *> *)dayArr {
    if(!_dayArr) {
        NSMutableArray *mutaArr = [NSMutableArray new];
        for(int i=1; i<=_dayNum; i++) {
            CMLundarCalendarDayModel *model = [CMLundarCalendarDayModel new];
            model.year = _year;
            model.month = _month;
            model.day = i;
            model.dayStr = chineseDayStr(i);
            NSInteger lundarYear = (_year - 1970 + 47 + 600)%60;
            model.yearStr = sixtyCycleYearStr(lundarYear);
            model.monthStr = chineseMonthStr(_year, _month);
            [mutaArr addObject:model];
        }
        _dayArr = mutaArr;
    }
    return _dayArr;
}
@end

@implementation CMLundarCalendarDayModel
- (instancetype)initWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    self = [super init];
    if(self) {
        _year = year;
        _month = month;
        _day = day;
    }
    return self;
}

- (NSInteger)dayNumOfYear {
    int days = 0;
    for (int i = 1; i < _month; i++)
        days += [CMLundarCalendarDB getMonthDaysInYear:_year month:i];
    days += _day;
    return days;
}

/// 是否在指定日期之前
- (BOOL)IsPrior:(CMLundarCalendarDayModel *)ref {
    return _year < ref.year || (_year == ref.year && (_month < ref.month || (_month == ref.month && _day < ref.day)));
}

/// 两天之间的差距
- (NSInteger)dayNumGapWith:(CMLundarCalendarDayModel *)ref {
    CMLundarCalendarDayModel *begin;
    CMLundarCalendarDayModel *end;
    if([self IsPrior:ref]) {
        begin = self;
        end = ref;
    } else {
        begin = ref;
        end = self;
    }
    NSInteger days = 0;
    for(NSUInteger i=begin.year; i<end.year; i++) {
        days += [CMLundarCalendarDB getYearDaysInYear:i];
    }
    days -= [begin dayNumOfYear];
    days += [end dayNumOfYear];
    return days;
}

- (NSTimeInterval)time {
    if(!_time) {
        CMLundarCalendarDayModel *ref = [[CMLundarCalendarDayModel alloc] initWithYear:2000 month:1 day:1];
        NSTimeInterval refTime = 949680000;
        NSTimeInterval gapTime = [self dayNumGapWith:ref]*(60*60*24);
        if([self IsPrior:ref]) {
            _time = refTime - gapTime;
        } else {
            _time = refTime + gapTime;
        }
    }
    return _time;
}

/// 返回向未来移动的天数
- (CMLundarCalendarDayModel *)adjustForwardDay:(NSUInteger)dayNum {
    if(dayNum > [self dayNumGapWith:[[CMLundarCalendarDayModel alloc] initWithYear:2050 month:12 day:30]]) {    // 超出范围
        return nil;
    }
    /// 计算从自己年一月一号到那一天
    dayNum += [self dayNumOfYear];
    
    NSInteger currentYear = _year;
    NSInteger yearDays = [CMLundarCalendarDB getYearDaysInYear: currentYear];
    while (dayNum > yearDays) {
        dayNum -= yearDays;
        currentYear ++;
        yearDays = [CMLundarCalendarDB getYearDaysInYear:currentYear];
    }
    
    NSUInteger currentMonth = 1;
    NSUInteger monthDay = [CMLundarCalendarDB getMonthDaysInYear:currentYear month:currentMonth];
    while (dayNum > monthDay) {
        dayNum -= monthDay;
        currentMonth ++;
        monthDay = [CMLundarCalendarDB getMonthDaysInYear:currentYear month:currentMonth];
    }
    
    CMLundarCalendarDayModel *result = [CMLundarCalendarDayModel new];
    result.year = currentYear;
    result.month = currentMonth;
    result.day = dayNum;
    return result;
}

/// 返回向过去移动的天数
- (CMLundarCalendarDayModel *)adjustBackward:(NSUInteger)dayNum {
    if(dayNum > [self dayNumGapWith:[[CMLundarCalendarDayModel alloc] initWithYear:1901 month:1 day:1]]) {    // 超出范围
        return nil;
    }
    
    NSInteger yearDays = [CMLundarCalendarDB getYearDaysInYear:_year];
    dayNum = dayNum - [self dayNumOfYear] + yearDays; // 到自己这一年最后一天的距离
    
    NSInteger currentYear = _year;
    while (dayNum > yearDays) {
        dayNum -= yearDays;
        currentYear --;
        yearDays = [CMLundarCalendarDB getYearDaysInYear:currentYear];
    }
    
    NSInteger currentMonth = 1;
    dayNum = yearDays - dayNum - 1;
    NSUInteger monthDay = [CMLundarCalendarDB getMonthDaysInYear:currentYear month:currentMonth];
    while (dayNum > monthDay) {
        dayNum -= monthDay;
        currentMonth ++;
        monthDay = [CMLundarCalendarDB getMonthDaysInYear:currentYear month:currentMonth];
    }
    
    CMLundarCalendarDayModel *result = [CMLundarCalendarDayModel new];
    result.year = currentYear;
    result.month = currentMonth;
    result.day = dayNum + 1;
    return result;
}
@end

@implementation CMLundarCalendarManager
+ (NSArray<CMLundarCalendarYearModel *> *)yearsFromBeginTime:(NSTimeInterval)beginTime endTime:(NSTimeInterval)endTime {
    if(endTime < beginTime) { return @[]; }
    NSTimeInterval refTime = 949680000;
    beginTime = beginTime - (int)fabs(refTime - beginTime)%(60*60*24);
    endTime = endTime - (int)fabs(refTime - endTime)%(60*60*24);
    
    CMLundarCalendarDayModel *beginDay = [self getLundarDayInTime:beginTime];
    CMLundarCalendarDayModel *endDay = [self getLundarDayInTime:endTime];
    if(!beginDay || !endDay) { return @[]; }
    NSArray<CMLundarCalendarYearModel *> *allLundar = [self getAllLundarCalendar];
    NSArray<CMLundarCalendarYearModel *> *lundarArr = [allLundar subarrayWithRange:NSMakeRange(beginDay.year - YEAR_BASE, endDay.year - beginDay.year + 1)];
    CMLundarCalendarYearModel *beginYear = lundarArr.firstObject;
    beginYear.monthArr = [beginYear.monthArr subarrayWithRange:NSMakeRange(beginDay.month - 1, beginYear.monthArr.count - beginDay.month + 1)];
    
    CMLundarCalendarYearModel *endyear = lundarArr.lastObject;
    endyear.monthArr = [endyear.monthArr subarrayWithRange:NSMakeRange(0, endyear.monthArr.count - (endyear.monthNum - endDay.month))];
    
    CMLundarCalendarMonthModel *beginMonth = beginYear.monthArr.firstObject;
    CMLundarCalendarMonthModel *endMonth = endyear.monthArr.lastObject;
    beginMonth.dayArr = [beginMonth.dayArr subarrayWithRange:NSMakeRange(beginDay.day - 1, beginMonth.dayArr.count - beginDay.day + 1)];
    endMonth.dayArr = [endMonth.dayArr subarrayWithRange:NSMakeRange(0, endMonth.dayArr.count - (endMonth.dayNum - endDay.day))];
    return lundarArr;
}

+ (NSArray<CMLundarCalendarYearModel *> *)getAllLundarCalendar {
    NSMutableArray *mutaArr = [NSMutableArray new];
    for(int i=YEAR_BASE; i<(YEAR_BASE + YEAR_NUM); i++) {
        CMLundarCalendarYearModel *model = [CMLundarCalendarYearModel new];
        model.year = i;
        model.lundarYear = (i - 1970 + 47 + 600)%60;
        model.yearStr = sixtyCycleYearStr(model.lundarYear);
        
        NSInteger leapMonth = [CMLundarCalendarDB getLeapMonthInYear:i];
        model.monthNum = (leapMonth == 0) ? 12 : 13;
        [mutaArr addObject:model];
    }
    return [mutaArr copy];
}

+ (CMLundarCalendarDayModel *)getLundarDayInTime:(NSTimeInterval)time {
    NSTimeInterval refTime = 949680000;
    CMLundarCalendarDayModel *ref = [[CMLundarCalendarDayModel alloc] initWithYear:2000 month:1 day:1];
    NSTimeInterval countTime = time - (int)fabs(refTime - time)%(60*60*24);
    int gapDay = (int)(fabs(refTime - countTime)/(60*60*24));
    if(time <= refTime) {
        return [ref adjustBackward:gapDay];
    } else {
        return [ref adjustForwardDay:gapDay];
    }
}

+ (CMLundarCalendarDayModel *)dayFor:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    if(year < YEAR_BASE || year > (YEAR_BASE + YEAR_NUM)) { return nil; }
    if(month < 1 || month > [CMLundarCalendarDB getMonthNumInYear:year]) { return nil; }
    if(day < 1 || day > [CMLundarCalendarDB getMonthDaysInYear:year month:month]) { return nil; }
    return [[CMLundarCalendarDayModel alloc] initWithYear:year month:month day:day];
}

+ (NSArray<NSNumber *> *)safeIndexOfDay:(CMLundarCalendarDayModel *)dayModel inYears:(NSArray<CMLundarCalendarYearModel *> *)years {
    NSMutableArray<NSNumber *> *indexArr = [[CMLundarCalendarManager indexOfDay:dayModel inYears:years] mutableCopy];
    for(int i=0; i<indexArr.count; i++) {
        if(indexArr[i].integerValue < 0) {
            indexArr[i] = @(0);
        }
    }
    return [indexArr copy];
}

+ (NSArray<NSNumber *> *)indexOfDay:(CMLundarCalendarDayModel *)dayModel inYears:(NSArray<CMLundarCalendarYearModel *> *)years {
    NSInteger yearIndex = -1;
    NSInteger monthIndex = -1;
    NSInteger dayIndex = -1;
    for(int i=0; i<years.count; i++) {
        CMLundarCalendarYearModel *yearModel = years[i];
        if(yearModel.year == dayModel.year) {
            yearIndex = i;
            for(int j=0; j<yearModel.monthArr.count; j++) {
                CMLundarCalendarMonthModel *monthModel = yearModel.monthArr[j];
                if(dayModel.month == monthModel.month) {
                    monthIndex = j;
                    for(int k=0; k<monthModel.dayArr.count; k++){
                        if(dayModel.day == monthModel.dayArr[k].day) {
                            dayIndex = k;
                            break;
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
    return @[@(yearIndex), @(monthIndex), @(dayIndex)];
}
@end
