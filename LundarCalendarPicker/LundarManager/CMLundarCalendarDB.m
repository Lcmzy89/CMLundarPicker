//
//  CMLundarCalendarDB.m
//  LundarCalendarPicker
//
//  Created by 李成明 on 2022/6/9.
//

#import "CMLundarCalendarDB.h"

static const int YEAR_BASE = 1901;  // 起始年限
static const int YEAR_NUM = 150;    // 年数

// 数组中每一个元素存放1901~2050期间每一年的闰月月份，取值范围0~12（0表示该年没有闰月
static const uint8_t hw_leapMonth[150] = {
    0x00, 0x00, 0x05, 0x00, 0x00, 0x04, 0x00, 0x00, 0x02, 0x00, //1910
    0x06, 0x00, 0x00, 0x05, 0x00, 0x00, 0x02, 0x00, 0x07, 0x00, //1920
    0x00, 0x05, 0x00, 0x00, 0x04, 0x00, 0x00, 0x02, 0x00, 0x06, //1930
    0x00, 0x00, 0x05, 0x00, 0x00, 0x03, 0x00, 0x07, 0x00, 0x00, //1940
    0x06, 0x00, 0x00, 0x04, 0x00, 0x00, 0x02, 0x00, 0x07, 0x00, //1950
    0x00, 0x05, 0x00, 0x00, 0x03, 0x00, 0x08, 0x00, 0x00, 0x06, //1960
    0x00, 0x00, 0x04, 0x00, 0x00, 0x03, 0x00, 0x07, 0x00, 0x00, //1970
    0x05, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x06, 0x00, //1980
    0x00, 0x04, 0x00, 0x0A, 0x00, 0x00, 0x06, 0x00, 0x00, 0x05, //1990
    0x00, 0x00, 0x03, 0x00, 0x08, 0x00, 0x00, 0x05, 0x00, 0x00, //2000
    0x04, 0x00, 0x00, 0x02, 0x00, 0x07, 0x00, 0x00, 0x05, 0x00, //2010
    0x00, 0x04, 0x00, 0x09, 0x00, 0x00, 0x06, 0x00, 0x00, 0x04, //2020
    0x00, 0x00, 0x02, 0x00, 0x06, 0x00, 0x00, 0x05, 0x00, 0x00, //2030
    0x03, 0x00, 0x0B, 0x00, 0x00, 0x06, 0x00, 0x00, 0x05, 0x00, //2040
    0x00, 0x02, 0x00, 0x07, 0x00, 0x00, 0x05, 0x00, 0x00, 0x03, //2050
};

// 数组中每一个元素存放1901~2050期间每一年的12个月或13个月（有闰月）的月天数
// 数组元素的低12位或13位（有闰月）分别对应着这12个月或13个月（有闰月），最低位对应着最小月（1月）
// 如果月份对应的位为1则表示该月有30天，否则表示该月有29天。
// （注：农历中每个月的天数只有29天或者30天）
static const uint16_t hw_monthDay[150] = {
    0x0752, 0x0EA5, 0x164A, 0x064B, 0x0A9B, 0x1556, 0x056A, 0x0B59, 0x1752, 0x0752, //1910
    0x1B25, 0x0B25, 0x0A4B, 0x12AB, 0x0AAD, 0x056A, 0x0B69, 0x0DA9, 0x1D92, 0x0D92, //1920
    0x0D25, 0x1A4D, 0x0A56, 0x02B6, 0x15B5, 0x06D4, 0x0EA9, 0x1E92, 0x0E92, 0x0D26, //1930
    0x052B, 0x0A57, 0x12B6, 0x0B5A, 0x06D4, 0x0EC9, 0x0749, 0x1693, 0x0A93, 0x052B, //1940
    0x0A5B, 0x0AAD, 0x056A, 0x1B55, 0x0BA4, 0x0B49, 0x1A93, 0x0A95, 0x152D, 0x0536, //1950
    0x0AAD, 0x15AA, 0x05B2, 0x0DA5, 0x1D4A, 0x0D4A, 0x0A95, 0x0A97, 0x0556, 0x0AB5, //1960
    0x0AD5, 0x06D2, 0x0EA5, 0x0EA5, 0x064A, 0x0C97, 0x0A9B, 0x155A, 0x056A, 0x0B69, //1970
    0x1752, 0x0B52, 0x0B25, 0x164B, 0x0A4B, 0x14AB, 0x02AD, 0x056D, 0x0B69, 0x0DA9, //1980
    0x0D92, 0x1D25, 0x0D25, 0x1A4D, 0x0A56, 0x02B6, 0x05B5, 0x06D5, 0x0EC9, 0x1E92, //1990
    0x0E92, 0x0D26, 0x0A56, 0x0A57, 0x14D6, 0x035A, 0x06D5, 0x16C9, 0x0749, 0x0693, //2000
    0x152B, 0x052B, 0x0A5B, 0x155A, 0x056A, 0x1B55, 0x0BA4, 0x0B49, 0x1A93, 0x0A95, //2010
    0x052D, 0x0AAD, 0x0AAD, 0x15AA, 0x05D2, 0x0DA5, 0x1D4A, 0x0D4A, 0x0C95, 0x152E, //2020
    0x0556, 0x0AB5, 0x15B2, 0x06D2, 0x0EA9, 0x0725, 0x064B, 0x0C97, 0x0CAB, 0x055A, //2030
    0x0AD6, 0x0B69, 0x1752, 0x0B52, 0x0B25, 0x1A4B, 0x0A4B, 0x04AB, 0x055B, 0x05AD, //2040
    0x0B6A, 0x1B52, 0x0D92, 0x1D25, 0x0D25, 0x0A55, 0x14AD, 0x04B6, 0x05B5, 0x0DAA, //2050
};

// 储存每一年的天数 计算一次更新一个
static uint16_t hw_yearDay[150] = {0};

BOOL judgeYearLegal(NSInteger year) {
    return (year >= YEAR_BASE || (year < YEAR_BASE + YEAR_NUM));
}

@implementation CMLundarCalendarDB

+ (NSInteger)getLeapMonthInYear:(NSInteger)year {
    if(!judgeYearLegal(year)) { return -1; }
    return hw_leapMonth[year - YEAR_BASE];
}

+ (NSInteger)getMonthNumInYear:(NSInteger)year {
    if(!judgeYearLegal(year)) { return -1; }
    return hw_leapMonth[year - YEAR_BASE] ? 13 : 12;
}

+ (NSInteger)getMonthDaysInYear:(NSInteger)year month:(NSInteger)month {
    if(!judgeYearLegal(year)) { return -1; }
    NSInteger monthNum = 12 + (hw_leapMonth[year - YEAR_BASE] ? 1 : 0);
    if(month < 1 || month > monthNum) { return -1; }
    return (hw_monthDay[year - YEAR_BASE] & (1 << (month - 1))) ? 30 : 29;
}

+ (NSInteger)getYearDaysInYear:(NSInteger)year {
    if(!judgeYearLegal(year)) { return -1; }
    uint16_t yearDayNum = hw_yearDay[year - YEAR_BASE];
    if(yearDayNum) { return yearDayNum; }
    
    uint16_t num = hw_monthDay[year - YEAR_BASE];
    // 计算num的二进制位中“1”的个数
    num = ((num >> 1) & 0x5555) + (num & 0x5555);
    num = ((num >> 2) & 0x3333) + (num & 0x3333);
    num = ((num >> 4) & 0x0F0F) + (num & 0x0F0F);
    num = ((num >> 8) & 0x00FF) + (num & 0x00FF);
    
    int monthNum = 12 + (hw_leapMonth[year - YEAR_BASE] ? 1 : 0);
    yearDayNum = monthNum * 29 + num;
    hw_yearDay[year - YEAR_BASE] = yearDayNum;
    return yearDayNum;
}
@end
