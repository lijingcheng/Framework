//
//  NetworkService.swift
//  Framework
//
//  Created by 李京城 on 2020/9/15.
//  Copyright © 2020 X. All rights reserved.
//

import Foundation
import Alamofire

extension Notification.Name {
    public struct APIException {
        /// 没有网络
        public static let noConnection = Notification.Name(rawValue: "com.wandafilm.notification.name.exception.noConnection")
    }
}

public struct API {
    public struct Error {
        /// 用于展示“空数据”、“接口失败”、“没网络”异常页面
        public enum Code: Int {
            case none = 1000, emptyData, offline, failure
            
            public init(rawValue: Int) {
                switch rawValue {
                case 1000:
                    self = .none // 正常情况
                case 1001:
                    self = .emptyData // 列表接口空数据
                case 1002:
                    self = .offline // 没有网络
                default:
                    self = .failure // 接口异常，如果用未定义的 code 来初始化 API.Error.Code 则认为有错误
                }
            }
        }

        /// 主要对应接口的 bizCode
        public var code: Int
        /// 主要对应接口的 bizMsg
        public var message: String
        /// 异常情况下有可能会用到的数据
        public var data: [String: Any]?
        
        public init(code: Int, message: String, data: [String: Any]?) {
            self.code = code
            self.message = message
            self.data = data
        }
    }
    
    /// 埋点服务器地址
    public static var analysisServiceURL = ""
    
    /// 用来标识用户登录状态的 token
    public static var token: String?

    /// 接口超时时间
    static var timeoutInterval = 30.0
}

public class NetworkService {
    /// 设置个单例属性是为了让服务器时间、网络状态等属性在 app 启动时只保存一份
    public static let shared = NetworkService()
    
    /// 用来存储服务器和本地时间差
    public var timeIntevalDifference = 0
    
    /// 服务器时间
    public var serverTime: Date? {
        return Date().adding(Calendar.Component.second, value: timeIntevalDifference)
    }
    
    /// 是否有网络
    public var isReachable: Bool {
        return reachabilityManager?.isReachable ?? true
    }
    
    /// 当前网络是否是 wiki
    public var isReachableWiFi: Bool {
        return reachabilityManager?.isReachableOnEthernetOrWiFi ?? false
    }
    
    /// 网络请求管理类的通用设置对象
    public var configuration: URLSessionConfiguration
    
    /// 管理 get/post 和上传请求的 manager
    public var manager: Session
    
    /// 管理下载请求的 manager
    public var downloadManager: Session
    
    /// 检测网络是否正常，当百度倒闭时需要修改此行代码
    private var reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")

    private init() {
        configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = API.timeoutInterval
        configuration.timeoutIntervalForResource = API.timeoutInterval
        configuration.httpMaximumConnectionsPerHost = 6
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true // 网络不通时 request 会等有网后再发出去
        }
        
        manager = Session(configuration: configuration)

        downloadManager = Session(configuration: configuration)
    }
    
    /// 发送 http 请求
    @discardableResult
    public static func request(_ url: String, method: HTTPMethod, parameters: [String: Any], finishedCallback: @escaping (_ response: AFDataResponse<Any>?, _ error: API.Error?) -> Void) -> DataRequest? {
        do {
            if !shared.isReachable {
                finishedCallback(nil, API.Error(code: API.Error.Code.offline.rawValue, message: "", data: ["url": url]))
                print("Error: \(url) 网络异常")

                return nil
            }
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = method.rawValue
            
            if canIgnore(request, manager: shared.manager) {
                return nil
            }
            
            request = try URLEncoding.default.encode(request, with: parameters)

            return shared.manager.request(request).validate().responseJSON { response in
                DispatchQueue.main.async {
                    finishedCallback(response, nil)
                }
            }
        } catch let error {
            finishedCallback(nil, API.Error(code: API.Error.Code.failure.rawValue, message: "", data: ["url": url]))
            print("Error: \(url) \(error)")
        }
        
        return nil
    }
}

extension NetworkService {
    /// 是否忽略请求，目的是不多次请求同一接口
    private static func canIgnore(_ request: URLRequest, manager: Session) -> Bool {
        var canIgnore = false
    
        manager.session.getAllTasks { tasks in
            for task in tasks where request.url?.absoluteString == task.originalRequest?.url?.absoluteString {
                canIgnore = true
                break
            }
        }
        
        return canIgnore
    }
    
    /// 取消所有请求
    public static func cancelAllRequest() {
        shared.manager.session.invalidateAndCancel()
    }
}
