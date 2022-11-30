//
//  Model.swift
//  blip_sdk
//
//  Created by Hugo Leonardo Ribeiro de Figueiredo on 20/10/22.
//

public enum BlipChatType :String, CaseIterable {
    case plain = "plain"
    case external = "external"
}

public struct BlipChatStyleModel {
    public let overrideOwnerColors: Bool
    public let primary: String
    public let sentBubble: String
    public let receivedBubble: String
    public let background: String
    public let showOwnerAvatar: Bool
    public let showUserAvatar: Bool
    
    public init(overrideOwnerColors: Bool, primary: String, sentBubble: String, receivedBubble: String, background: String,showOwnerAvatar: Bool, showUserAvatar: Bool) {
        self.overrideOwnerColors = overrideOwnerColors
        self.primary = primary
        self.sentBubble = sentBubble
        self.receivedBubble = receivedBubble
        self.background = background
        self.showOwnerAvatar = showOwnerAvatar
        self.showUserAvatar = showUserAvatar
        
    }
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}

public struct BlipChatAccountModel {
    public let pushToken: String
    public init(pushToken: String) {
        self.pushToken = pushToken
    }
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}

public struct BlipChatModel {
    public let key: String
    public let type: String
    public let token: String
    public let issuer: String
    public let hostName: String
    public let useMtls: Bool
    public let account: [String : Any]
    
    public let style: [String : Any]?
    
    public init(key: String, type: BlipChatType, token: String, issuer: String, hostName: String, useMtls: Bool, account: BlipChatAccountModel, style: BlipChatStyleModel? = nil) {
        self.key = key
        self.type = type.rawValue
        self.token = token
        self.issuer = issuer
        self.hostName = hostName
        self.useMtls = useMtls
        self.account = account.asDictionary
        self.style = style?.asDictionary ?? nil
    }
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}



