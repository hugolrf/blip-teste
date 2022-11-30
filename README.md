# Introduction

SDK to easily add Blip Chat's widget to your iOS app. For more information, see [Blip documentation][1].

---

# Getting Started

1.  First thing you need to do, is add Blip SDK to the project. To do this, you need to modify your `PodFile`, adding the lines bellow:

```Ruby
use_frameworks!

pod 'blip-sdk-ios', :git => 'https://github.com/takenet/blip-chat-sdk-ios'
```

<br>

2.  After that, run the bellow command, to install the new dependecy:

```shell
pod install
```

<br>

3.  Now, you have to inherit `BlipChatDelegate` in your `AppDelegate` file:

```swift
class AppDelegate: BlipChatDelegate {

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
```

<br>

4.  Last but not least, you have to create a new instance of `BlipChat`. In the `ViewController` responsible to open the chat page. Create a call action according to the sample bellow:

```swift
let chat = BlipChat()

chat.onMessageReceived = { (message: String) in
    print(message)
}

let model = BlipChatModel(
    key: "{YOUR_OWNER_KEY}",
    type: "plain",
    account: BlipChatAccountModel(
        fullName: "{LOGGED_USER_FULL_NAME}",
        photoUri: "{LOGGED_USER_AVATAR_URI}",
        pushToken: "{DEVICE_PUSH_NOTIFICATION_TOKEN}",
    ),
    style: BlipChatStyleModel(
        primary: "02AFFF",
        sentBubble: "FFFFFF",
        receivedBubble: "02AFFF",
        background: "EFEFEF",
        overrideOwnerColors: true,
        showUserAvatar: false
    )
)

chat.show(blipChatModel: model, viewController: self)
```

<br>

# Properties

### BlipChatModel

| Property   | Required                                 | Description                                                                                                           | Type                                             |
| ---------- | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `key`      | YES                                      | String key that identifies the owner                                                                                  | _String_                                         |
| `type`     | YES                                      | Indicates the authentication type, used to sign in the user                                                           | _[AuthenticationTypeEnum](#authentication-type)_ |
| `token`    | NO<span style="color: #CA3E3E">\*</span> | User token used to identity the application logged user. Used with [external](#authentication-type) type only         | _String_                                         |
| `issuer`   | NO<span style="color: #CA3E3E">\*</span> | Issuer used to authenticate session. Used with [external](#authentication-type) type only                             | _String_                                         |
| `hostName` | NO                                       | Custom hostName used to connect to Blip Server                                                                        | _String_                                         |
| `useMtls`  | NO                                       | Determines if the connection will use mTLS for avoid MITM attacks. Default: <span style="color: #077BB5">false</span> | _bool_                                           |
| `account`  | NO                                       | Logged user account data                                                                                              | _[BlipChatAccountModel](#blipchat-account)_      |
| `style`    | NO                                       | Custom chat style                                                                                                     | _[BlipChatStyleModel](#blipchat-style)_          |

> <span style="color: #CA3E3E">\*</span> Required for **_external_** [authentication type](#authentication-type).

### BlipChat Account

| Property                | Required | Description                                         | Type     |
| ----------------------- | -------- | --------------------------------------------------- | -------- |
| `pushToken`             | NO       | Logged user's device push notification `Token`      | _String_ |
| `fullName`              | NO       | Logged user full name to be stored on Blip Account  | _String_ |
| `email`                 | NO       | Logged user email to be stored on Blip Account      | _String_ |
| `photoUri`              | NO       | Logged user avatar uri to be stored on Blip Account | _String_ |
| `encryptMessageContent` | NO       | Determines if the message content will be encrypted | _bool_   |

### BlipChat Style

| Property              | Required | Description                                                                                                                                    | Type     |
| --------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `primary`             | NO       | Primary chat HEX color                                                                                                                         | _String_ |
| `sentBubble`          | NO       | Sent message bubble HEX color                                                                                                                  | _String_ |
| `receivedBubble`      | NO       | Received message bubble HEX color                                                                                                              | _String_ |
| `background`          | NO       | Chat background HEX color                                                                                                                      | _String_ |
| `overrideOwnerColors` | NO       | Determines if the colors sent in this object, will override the owner configuration colors. Default: <span style="color: #077BB5">false</span> | _bool_   |
| `showOwnerAvatar`     | NO       | Determines if the owner avatar will be shown. Default: <span style="color: #077BB5">true</span>                                                | _bool_   |
| `showUserAvatar`      | NO       | Determines if the user avatar will be shown. Default: <span style="color: #077BB5">true</span>                                                 | _bool_   |

### Authentication Type

| Property   | Description                                                                                                          |
| ---------- | -------------------------------------------------------------------------------------------------------------------- |
| `plain`    | _Plain_ text authentication method                                                                                   |
| `external` | _External_ authentication method. For this authentication type, is necessary to send `token` and `issuer` properties |

<br>

## Authentication

It's possible to authenticate with two different methods, `plain` and `external`.

### Plain

`Plain` authentication is the most commom authentication method and it's probably the one you should use. In this method, Blip manage the user, so you don't need to worry. See an example below of how to authenticate with `plain` type:

```swift
let model = BlipChatModel(
    key: "{YOUR_OWNER_KEY}",
    type: "plain",
    account: BlipChatAccountModel(
        pushToken: "{DEVICE_PUSH_NOTIFICATION_TOKEN}",
    ),
    style: BlipChatStyleModel(
        showUserAvatar: false
    )
)
```

### External

`External` authentication is commonly used when you have your own authentication provider. However, to use your own provider, it's necessary to contact us, in order to integrate Blip with it. See an example below of how to authenticate with `external` type:

```swift
let model = BlipChatModel(
    key: "{YOUR_OWNER_KEY}",
    type: "external",
    token: "{LOGGED_USER_AUTH_TOKEN}",
    issuer: "{YOUR_CUSTOM_AUTH_ISSUER}",
    account: BlipChatAccountModel(
        pushToken: "{DEVICE_PUSH_NOTIFICATION_TOKEN}",
    ),
    style: BlipChatStyleModel(
        showUserAvatar: false
    )
)
```

<br>

## UseMtls

The property `useMtls` is used to avoid MITM attacks. In most use cases, should be set to false. However, if you need this extra security check, it's necessary to pass a `hostName` that supports mTLS authentication. Contact us to get your mTLS `hostName`.

# Observers

| Event Name          | Params                |
| ------------------- | --------------------- |
| `onInitializing`    | **message**: _String_ |
| `onConnected`       | **message**: _String_ |
| `onReady`           | **message**: _String_ |
| `onMessageReceived` | **message**: _String_ |
| `onMessageSend`     | **message**: _String_ |
| `onMessageViewed`   | **message**: _String_ |
| `onDisconnected`    | **message**: _String_ |
| `onClosed`          | -                     |
| `onError`           | **error**: _String_   |

<br>

## License

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

[1]: https://docs.blip.ai/
