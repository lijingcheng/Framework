//
//  UIWindowExt.swift
//  Framework
//
//  Created by 李京城 on 2020/9/15.
//  Copyright © 2020 X. All rights reserved.
//

import UIKit

extension UIWindow {
    /// 获取当前正在显示的 ViewController
    public class func visibleViewController() -> UIViewController? {
        let window = UIApplication.shared.windows.first
        
        return window?.visibleViewController(window?.rootViewController)
    }
    
    private func visibleViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return visibleViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return visibleViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return visibleViewController(presented)
        }
        return base
    }
}
