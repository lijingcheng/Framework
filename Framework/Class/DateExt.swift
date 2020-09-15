//
//  DateExt.swift
//  Framework
//
//  Created by 李京城 on 2020/9/15.
//  Copyright © 2020 X. All rights reserved.
//

import Foundation

/// 时间戳类型，支持 unix 和 windows
public typealias Timestamp = Int64

extension Date {
    /// 强制使用东八区
    public static var timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
    
    /// 通用日期格式化器
    public static var formatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.timeZone = Date.timeZone
        fmt.shortWeekdaySymbols = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]

        return fmt
    }
    
    /// 通用日历控件
    public static var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = Date.timeZone
        
        return calendar
    }
}

extension Date {
    /// let date = Date(year: 2010, month: 1, day: 12)
    public init?(
        year: Int? = Date().year,
        month: Int? = Date().month,
        day: Int? = Date().day,
        hour: Int? = Date().hour,
        minute: Int? = Date().minute,
        second: Int? = Date().second) {
        
        var components = DateComponents()
        components.calendar = Date.calendar
        components.timeZone = Date.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second

        guard let date = Date.calendar.date(from: components) else { return nil }
        self = date
    }
    
    /// let date = Date(integerLiteral: 20101221)
    public init?(integerLiteral value: Int) {
        let formatter = Date.formatter
        formatter.dateFormat = "yyyyMMdd"
        guard let date = formatter.date(from: String(value)) else { return nil }
        self = date
    }

    /// 用 iOS 系统生成的时间戳来生成 Date
    public init(unixTimestamp: Timestamp) {
        self.init(timeIntervalSince1970: Double(unixTimestamp))
    }
    
    /// 用接口返回的时间戳来生成 Date
    public init(windowsTimestamp: Timestamp) {
        self.init(timeIntervalSince1970: Double(windowsTimestamp) / 1000)
    }
    
    /// 返回 unix 时间戳
    public var unixTimestamp: Timestamp {
        return Timestamp(timeIntervalSince1970)
    }
    
    /// 返回 windows 时间戳
    public var windowsTimestamp: Timestamp {
        return Timestamp(timeIntervalSince1970 * 1000)
    }
    
    /// 非北京时区时间转北京时区时间
    public func beijing() -> Date {
        return addingTimeInterval(TimeInterval(Date.timeZone.secondsFromGMT(for: self)))
    }
    
    /// 转字符串，可根据需要设置 format 样式
    public func string(withFormat format: String = "yyyy-MM-dd HH:mm") -> String {
        let dateFormatter = Date.formatter
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    /// 计算两个时间间隔多少天
    public func daysInBetweenDate(_ date: Date) -> Timestamp {
        var diff = timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff / 86400)
        return Timestamp(diff)
    }

    /// 计算两个时间间隔多少小时
    public func hoursInBetweenDate(_ date: Date) -> Timestamp {
        var diff = timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff / 3600)
        return Timestamp(diff)
    }

    /// 计算两个时间间隔多少天分钟
    public func minutesInBetweenDate(_ date: Date) -> Timestamp {
        var diff = timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff / 60)
        return Timestamp(diff)
    }

    /// 计算两个时间间隔多少秒
    public func secondsInBetweenDate(_ date: Date) -> Timestamp {
        var diff = timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff)
        return Timestamp(diff)
    }

    /// 判断是否大于当前时间
    public var isFuture: Bool {
        return self > Date()
    }

    /// 判断是否小于当前时间
    public var isPast: Bool {
        return self < Date()
    }

    /// 判断是否是今天
    public var isToday: Bool {
        return calendar.isDateInToday(self)
    }

    /// 判断是否是昨天
    public var isYesterday: Bool {
        return calendar.isDateInYesterday(self)
    }

    /// 判断是否是今明天
    public var isTomorrow: Bool {
        return calendar.isDateInTomorrow(self)
    }
    
    /// 判断两个时间是否相等
    public func isEqual(_ date: Date) -> Bool {
        return calendar.isDate(self, inSameDayAs: date)
    }

    /// 获取当前时间中的年
    public var year: Int {
        return dateComponents.year!
    }

    /// 获取当前时间中的月
    public var month: Int {
        return dateComponents.month!
    }

    /// 获取当前时间中的日
    public var day: Int {
        return dateComponents.day!
    }

    /// 获取当前时间中的小时
    public var hour: Int {
        return dateComponents.hour!
    }
    
    /// 获取当前时间中的分钟
    public var minute: Int {
        return dateComponents.minute!
    }

    /// 获取当前时间中的秒
    public var second: Int {
        return dateComponents.second!
    }

    /// 获取当前时间中的毫秒
    public var nanosecond: Int {
        return dateComponents.nanosecond!
    }

    /// 获取当前时间是星期几
    public var weekday: Int {
        return dateComponents.weekday!
    }
    
    /// 当前时间转日历组件
    private var dateComponents: DateComponents {
        return calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday], from: self)
    }
    
    /// 通过当前时间获取日历对象
    private var calendar: Calendar {
        return Date.calendar
    }
    
    /// 日期加减，可传负值
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Date.calendar.date(byAdding: component, value: value, to: self)!
    }
}

extension Date {
    /// 发布信息的时间描述
    public func timePassed() -> String {
        let components = Date.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if components.day! >= 3 {
            return string(withFormat: "MM月dd日")
        } else if components.day! >= 1 {
            return "\(components.day!)天前"
        } else if components.hour! >= 1 {
            return "\(components.hour!)小时前"
        } else if components.minute! >= 1 {
            return "\(components.minute!)分钟前"
        } else {
            return "刚刚"
        }
    }
}
