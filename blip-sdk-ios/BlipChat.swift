//
//  File.swift
//  blipSdk
//
//  Created by Hugo Leonardo Ribeiro de Figueiredo on 03/11/22.
//

import Foundation
import Flutter

enum CallBackMethods :String, CaseIterable {
    case onInitializing = "onInitializing"
    case onConnected = "onConnected"
    case onReady = "onReady"
    case onMessageReceived = "onMessageReceived"
    case onMessageSend = "onMessageSend"
    case onMessageViewed = "onMessageViewed"
    case onDisconnected = "onDisconnected"
    case onClosed = "onClosed"
    case onError = "onError"
}


public class BlipChat : NSObject {
    
    typealias JSONDictionary = [String : Any]
    
    public var onInitializing: ((String) -> Void)?
    public var onConnected: ((String) -> Void)?
    public var onReady: ((String) -> Void)?
    public var onMessageReceived: ((String) -> Void)?
    public var onMessageSend: ((String) -> Void)?
    public var onMessageViewed: ((String) -> Void)?
    public var onDisconnected: ((String) -> Void)?
    public var onClosed: (() -> Void)?
    public var onError: ((String) -> Void)?
    
    public func show(blipChatModel: BlipChatModel, viewController: UIViewController) {
        
        let validation = blipChatModel.validate()
        assert(validation.isValid, validation.message ?? "")
        
        
        BlipChatDelegate.flutterEngine.viewController = nil
        let flutterViewController =
        FlutterViewController(engine: BlipChatDelegate.flutterEngine, nibName: nil, bundle: nil)
        flutterViewController.modalPresentationStyle = .fullScreen
        
        let flutterChannel = FlutterMethodChannel(name: "blip.sdk.chat.native/helper",
                                                  binaryMessenger: flutterViewController.binaryMessenger)
        flutterChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            let args = (call.arguments as? [String : Any])
            switch CallBackMethods(rawValue: call.method) {
            case .onInitializing:
                let message = args?["message"] as? String ?? ""
                self.onInitializing?(message)
                
            case .onConnected:
                let message = args?["message"] as? String ?? ""
                self.onConnected?(message)
                
            case .onReady:
                let message = args?["message"] as? String ?? ""
                self.onReady?(message)
                
            case .onMessageReceived:
                let message = args?["message"] as? String ?? ""
                self.onMessageReceived?(message)
                
            case .onMessageSend:
                let message = args?["message"] as? String ?? ""
                self.onMessageSend?(message)
                
            case .onMessageViewed:
                let message = args?["message"] as? String ?? ""
                self.onMessageViewed?(message)
                
            case .onDisconnected:
                let message = args?["message"] as? String ?? ""
                self.onDisconnected?(message)
                
            case .onClosed:
                flutterViewController.popRoute()
                self.onClosed?()
                
            case .onError:
                let message = args?["error"] as? String ?? ""
                self.onError?(message)
                
            case .none:
                break;
            }
        })
        
        let initMethod: () -> Void = {
            flutterChannel.invokeMethod("onInit", arguments: self.asString(jsonDictionary: blipChatModel.asDictionary))
        }
        
        viewController.present(flutterViewController, animated: true, completion: initMethod)
    }
    
    func asString(jsonDictionary: JSONDictionary) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return ""
        }
    }
}
struct RuntimeError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}

private extension BlipChatModel {
    func validate() -> (isValid:Bool , message: String?){
        if self.key == "" {
            return (false, "key is expected")
        }
        
        if BlipChatType(rawValue: self.type) == .external{
            if self.token == "" {
                return (false, "token is expected when type is external")
            }
            
            if self.issuer == "" {
                return (false, "token is expected when type is external")
            }
        }
        
        return (true, nil)
    }
}
