//
//  BundleExt.swift
//  Framework
//
//  Created by 李京城 on 2020/9/15.
//  Copyright © 2020 X. All rights reserved.
//

import Foundation

extension Bundle {
    private struct AssociatedKeys {
        static var moduleAKey = "Bundle.moduleAKey"
        static var moduleBKey = "Bundle.moduleBKey"
    }
    
    public static var moduleA: Bundle {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.moduleAKey) as? Bundle ?? Bundle.main
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.moduleAKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public static var moduleB: Bundle {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.moduleBKey) as? Bundle ?? Bundle.main
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.moduleBKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
