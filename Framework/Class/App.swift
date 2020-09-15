//
//  App.swift
//  Framework
//
//  Created by 李京城 on 2020/9/15.
//  Copyright © 2020 X. All rights reserved.
//

import UIKit

public struct App {
    /// Apple Store 中的 appId
    public static var id = ""

    /// 项目的 scheme
    public static var scheme = ""
    
    /// app 版本号
    public static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    /// app bundleId
    public static let bundleId = Bundle.main.bundleIdentifier
    
    /// 是否为 debug 模式
    #if DEBUG
    public static let isDebugMode = true
    #else
    public static let isDebugMode = false
    #endif
    
    /// 打电话
    public static func call(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
