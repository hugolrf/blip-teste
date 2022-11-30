import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blip_ds/blip_ds.dart';
import 'package:blip_sdk/blip_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, canLaunchUrl;

import 'package:get/get.dart';

import '../app.config.dart';
import '../constants/message_content_type.dart';
import '../enums/chat_state_types.enum.dart';
import '../enums/message_direction.enum.dart';
import '../enums/status.enum.dart';
import '../extensions/hex_color.extension.dart';
import '../models/base_authentication.model.dart';
import '../models/blip_message.model.dart';
import '../models/owner_account.model.dart';
import '../models/app_style.model.dart';
import '../models/sdk_properties.model.dart';
import '../models/user.model.dart';
import '../pages/welcome.page.dart';
import '../processors/account.processor.dart';
import '../processors/message.processor.dart';
import '../services/get.service.dart';
import '../services/media.service.dart';
import '../services/message.service.dart';
import '../services/native_platform.service.dart';
import '../services/utils.service.dart';
import '../themes/app_theme.model.dart';
import '../models/owner_display_data.model.dart';
import '../models/welcome_data.model.dart';

class ChatController extends GetxController {
  ChatController();

  late final OwnerAccount ownerAccount;
  late final OwnerDisplayData ownerDisplayData;
  late final User userAccount;

  late final SdkProperties properties;
  late final BaseAuthentication authentication;
  late final DSMessageBubbleAvatarConfig avatarConfig;

  final _clientController = GetService.findClient();
  final config = AppConfig.of(Get.context!)!;

  final messages = <BlipMessage>[];
  final hiddenMessages = <BlipMessage>[];
  final formattedMessages = RxList<DSMessageItemModel>();
  final formattedHiddenMessages = RxList<DSMessageItemModel>();

  final isLoading = RxBool(true);
  final isComposing = RxBool(false);
  final isCorrectOwnerKey = RxBool(false);
  final isClientOffline = RxBool(true);
  final shouldWelcome = RxBool(false);
  final keyboardOpen = RxBool(false);
  final isUploadingFiles = RxBool(false);
  final messageType = Rx<String>(MessageContentType.textPlain);
  final addMessageFieldController = TextEditingController();

  ChatStateTypes currentChatState = ChatStateTypes.paused;
  Timer? debounce;
  StreamSubscription<bool>? _keyboardSubscription;
  bool _isGettingMoreMessages = false;
  bool _hasMoreMessages = true;

  ///Necessary to standalone run
  // @override
  // Future<void> onInit() async {
  //   await initController(
  //     SdkProperties.fromJson({
  //       'key': 'Ym9yaXM5OjQwZmFhOWIwLTA3ZWYtNDkwZS04MDJmLWNhMDdlNjJkN2RmZA==',
  //       // 'key': 'Ym9yaXM6YWYwOTY1OTEtM2NiNy00MDZkLTk1MWMtMWMwNDgxNzVlZTNj',
  //       // 'type': AuthenticationScheme.plain.name,
  //       'type': AuthenticationScheme.external.name,
  //       'token': 'bW9ja19hdXRob3JpemF0aW9uY29kZV9mYWtldXNlcjE0',
  //       'issuer': 'bancopan.com.br',
  //       // 'hostName': 'hmg-mtls-ws.0mn.io',
  //       // 'useMtls': true,
  //       // 'account': {
  //       //   // 'pushToken': '',
  //       //   'fullName': 'Cliente 14 - Banco Pan',
  //       //   'photoUri':
  //       //       'https://s3-sa-east-1.amazonaws.com/i.imgtake.takenet.com.br/ie4T/ie4T.png',
  //       // },
  //       'style': {
  //         'primary': Colors.purple.toHex(),
  //         // 'background': Colors.grey.toHex(),
  //         'sentBubble': Colors.black45.toHex(),
  //         'receivedBubble': Colors.deepPurple.toHex(),
  //         'overrideOwnerColors': true,
  //         'showUserAvatar': false,
  //       },
  //     }),
  //   );
  //   super.onInit();
  // }

  @override
  Future<void> onClose() async {
    _keyboardSubscription?.cancel();
    _clientController.client.close();
    GetService.deleteClient();
    super.onClose();
  }

  Future<void> initController(SdkProperties properties) async {
    if (_clientController.client.listening) {
      return;
    }

    this.properties = properties;

    final keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    // print('Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    _keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      keyboardOpen.value = visible;
    });

    _clientController.ownerIdentity = properties.ownerIdentity;

    if (properties.hostName?.isNotEmpty ?? false) {
      _clientController.connection.hostName = properties.hostName!;
    }

    try {
      await properties.auth.connect();

      NativePlatformService.onConnect();

      await _setupThread(properties);

      _clientController.client.onConnectionDone.stream.listen((closed) {
        isClientOffline.value = closed;
        if (isClientOffline.value) {
          isLoading.value = false;
          NativePlatformService.onServerClosed();
        }
      });

      isLoading.value = false;

      NativePlatformService.onReady();
    } on InsecureSocketException catch (e) {
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(SnackBar(content: Text(e.message)));

      NativePlatformService.onError(e.toJson());
    } catch (e) {
      print(e);
    }
  }

  void sendChatState(ChatStateTypes type) {
    currentChatState = type;

    final state =
        type.name.substring(0, 1).toUpperCase() + type.name.substring(1);

    MessageService.sendChatState(state);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      if (messageType.value == MessageContentType.sensitive) {
        messageType.value = MessageContentType.textPlain;
        MessageService.sendSensitiveMessage({
          'type': MessageContentType.textPlain,
          'value': content,
        });
      } else {
        MessageService.sendTextMessage(content);
      }
    } catch (err, stackTrace) {
      // ErrorHandler.trackException(
      //   err,
      //   stackTrace: stackTrace,
      //   properties: {
      //     SentryProperties.methodName.name: 'CurrentTicket.sendMessage',
      //   },
      // );

      // if (await ErrorsReviewFeatures.isErrorsReviewFeatureEnabled()) {
      //   FlushbarService.showWarning(
      //     'toast-data.send-text-message.text',
      //   );
      // } else {
      //   FlushbarService.showError('error.send-text-message.text');
      // }
    }

    // if (currentTicket.isNew ?? false) {
    //   SegmentService.createTicketTrack(
    //     SegmentEvent.deskAppTicketFirstMessage.toKebabCase(),
    //     currentTicket,
    //   );
    // }

    //TODO: Review

    // final message = MessageService.newTextMessage(content);

    // //Inserts message at the beginning of list. ListView.builder is inverted (from bottom to top)
    // messages.insert(
    //   0,
    //   message,
    // );

    // hiddenMessages.insert(0, message);

    // _formatMessages();

    addMessageFieldController.clear();
  }

  Future<void> pickFile() async {
    try {
      isUploadingFiles.value = true;

      /// TODO: Use allowedExtensions
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        final files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        await MediaService.sendFiles(files);
      } else {
        // User canceled the picker
      }
    } catch (e) {
      /// TODO: Show error toast
      print(e);
    } finally {
      isUploadingFiles.value = false;
    }
  }

  void onSelectedOption(String text, Map<String, dynamic> payload) {
    final String type = payload['type'];
    dynamic payloadContent;
    try {
      payloadContent = jsonDecode(payload['content']);
    } catch (e) {
      payloadContent = payload['content'];
    }

    if (type == MessageContentType.deepLinking) {
      launchUrl(Uri.parse(payloadContent));
    } else {
      MessageService.sendMessage(
        payload['type'],
        payloadContent,
        metadata: {
          '#blip.payload.content': text,
        },
      );
    }
  }

  void onOpenLink(Map<String, dynamic> payload) async {
    final uri = Uri.parse(payload['uri']);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      /// TODO: Show error. Uri cannot be launched
      print('Cannot launch URI');
    }
  }

  void onInfinitScroll() {
    if (!_isGettingMoreMessages && _hasMoreMessages) {
      _isGettingMoreMessages = true;
      _getThreadMessages();
    }
  }

  Future<void> _setupThread(SdkProperties properties) async {
    // Verify user connection
    _clientController.client.onListeningChanged.stream.listen((listening) {
      isClientOffline.value = !listening;
      if (isClientOffline.value) {
        NativePlatformService.onDisconnected();
      }
    });
    _clientController.onAuthSessionFinished.stream.listen((_) {
      isClientOffline.value = true;
      NativePlatformService.onDisconnected();
    });

    ownerAccount = OwnerAccount.fromJson(
        (await AccountProcessor.getOwner(_clientController.ownerIdentity!))
            .resource);

    // if (owner.culture) {
    //   this.culture = resource.culture
    // }

    final key = ownerAccount.extras.appKey;
    final ownerKey = UtilsService.decodeBlipKey(properties.key)['ownerKey'];

    isCorrectOwnerKey.value = key == ownerKey;
    print('IsSameKey: ${isCorrectOwnerKey.value}');

    // TODO: Check the need of domain check
    // final domains = owner.extras['blipchat-domains'];

    // this.hasPermissionOnDomain = UserPermissions.hasPermissionsOnDomain(
    //   accountDomains
    // )

    // print('domains: $domains');
    final String? tenant = ownerAccount.extras.tenantId;

    if ((properties.hostName?.isEmpty ?? true) &&
        (tenant?.isNotEmpty ?? false)) {
      await _clientController.disconnect();

      _clientController.connection.tenant = tenant;
      _clientController.connection.hostName =
          '$tenant.${config.hostNameTenantDefault}';

      await properties.auth.connect();

      print('connect with tenant host');
    }

    Status accountStatus = Status.offline;

    try {
      _setAppStyle();

      // Get owner offline/online status
      accountStatus = await AccountProcessor.status(
        ownerAccount.identity.name!,
      );

      ownerDisplayData = OwnerDisplayData(
        name: ownerAccount.extras.displayName ?? ownerAccount.name,
        photo: ownerAccount.photoUri,
        status: accountStatus,
      );
    } catch (e) {
      print('Error on bot config setup (color, display name, status): $e');
    }

    _addClientListeners();

    await _getThreadMessages();

    WelcomeData? welcomeData;

    if (!_clientController.hasMessages) {
      welcomeData = await _getWelcomeInfo();
    }

    if (welcomeData != null) {
      await Get.to(
        () => WelcomePage(
          data: welcomeData!,
          ownerDisplayData: ownerDisplayData,
        ),
      );
    }

    await _setUserData(properties);

    _setAvatars(properties.style);

    isClientOffline.value = !_clientController.client.listening;
  }

  Future<WelcomeData?> _getWelcomeInfo() async {
    try {
      // Get bot start button
      final startButton = (await AccountProcessor.startButton(
        ownerAccount.identity.name!,
      ))
          .resource as String?;

      // Get bot start button label
      final startButtonLabel = (await AccountProcessor.startButtonLabel(
        ownerAccount.identity.name!,
      ))
          .resource as String?;

      // Get bot welcome message
      final welcomeMessage = (await AccountProcessor.welcomeMessage(
        ownerAccount.identity.name!,
      ))
          .resource as String?;

      if ((startButton?.isNotEmpty ?? false) &&
          (startButtonLabel?.isNotEmpty ?? false) &&
          (welcomeMessage?.isNotEmpty ?? false)) {
        return WelcomeData(
            buttonMessage: startButton!,
            buttonLabel: startButtonLabel!,
            greetingMessage: welcomeMessage!);
      }
    } catch (e) {
      print('Error getting ownerWelcomeInfo: $e');
    }

    return null;
  }

  Future<void> _setUserData(SdkProperties properties) async {
    final command = await AccountProcessor.getUser();

    final account = User.fromJson(command.resource);

    if (properties.account != null) {
      var hasChanges = false;

      final userAccount = properties.account!;

      if (userAccount.pushToken?.isNotEmpty ?? false) {
        account.setPushToken(userAccount.pushToken!);
        hasChanges = true;
      }

      if ((userAccount.fullName?.isNotEmpty ?? false) &&
          userAccount.fullName != account.fullName) {
        account.fullName = userAccount.fullName!;
        hasChanges = true;
      }

      if ((userAccount.email?.isNotEmpty ?? false) &&
          userAccount.email != account.email) {
        account.email = userAccount.fullName!;
        hasChanges = true;
      }

      if (userAccount.photoUri != null &&
          userAccount.photoUri!.toString() != account.photoUri?.toString()) {
        account.photoUri = userAccount.photoUri;
        hasChanges = true;
      }

      if (userAccount.encryptMessageContent != null &&
          userAccount.encryptMessageContent != account.encryptMessageContent) {
        account.encryptMessageContent = userAccount.encryptMessageContent;
        hasChanges = true;
      }

      if (hasChanges) {
        await AccountProcessor.setUser(account);
      }
    }

    userAccount = account;
  }

  void _setAvatars(AppStyle? style) {
    String? ownerName;
    Uri? ownerAvatar;
    String? userName;
    Uri? userAvatar;

    if (style?.showOwnerAvatar ?? true) {
      ownerName = ownerDisplayData.name;
      ownerAvatar = ownerDisplayData.photo;
    }

    if (style?.showUserAvatar ?? true) {
      userName = userAccount.fullName;
      userAvatar = userAccount.photoUri;
    }

    avatarConfig = DSMessageBubbleAvatarConfig(
      receivedName: ownerName,
      receivedAvatar: ownerAvatar,
      sentName: userName,
      sentAvatar: userAvatar,
    );
  }

  void _addClientListeners() {
    /// TODO: Setup message and notification listener
    _clientController.messageListener.filteredMessagelistener.stream
        .listen((BlipMessage message) async {
      if (message.type == MessageContentType.chatState) {
        isComposing.value =
            message.content['state'] == ChatStateTypes.composing.name;
        return;
      } else {
        isComposing.value = false;
      }

      NativePlatformService.onMessageReceived();

      if (message.id.isEmpty || !messages.any((x) => x.id == message.id)) {
        // Chatstate paused is only permitted if previous message is chatstate composing
        if (messages.isNotEmpty &&
            message.type == MessageContentType.chatState &&
            message.content['state'] == ChatStateTypes.paused.name &&
            messages[messages.length - 1].content is! String &&
            messages[messages.length - 1].content['state'] !=
                ChatStateTypes.composing.name) {
          return;
        }

        _formatSensitiveMessage(message);

        messages.add(message);
        hiddenMessages.add(message);

        //Move chat state composing to end if user sends a message
        if (messages.length > 1) {
          final msg = messages[messages.length - 2];
          if (msg.content is! String &&
              msg.content['state'] == ChatStateTypes.composing.name &&
              messages[messages.length - 1].direction !=
                  MessageDirection.received) {
            final message = msg;
            messages.remove(message);
            messages.add(message);
          }
        }

        /// TODO: Send Notification
        // notificationsApi.sendNotification(message);
        _formatMessage(message);

        _clientController.hasMessages = messages.isNotEmpty;
      }
    });

    if (config.showMessageStatus) {
      _clientController.notificationListener.stream
          .listen((Notification notification) async {
        final message = messages
            .map<BlipMessage?>((x) => x)
            .firstWhere((m) => m!.id == notification.id, orElse: () => null);

        if (message == null) {
          return;
        }

        if (message.status == NotificationEvent.unknown ||
            message.status.isLowerThan(notification.event)) {
          message.status = notification.event!;
        }

        _formatMessage(message);

        if (notification.event == NotificationEvent.failed) {
          print('Failed notification received: ${notification.toJson()}');
        } else if (notification.event == NotificationEvent.consumed) {
          NativePlatformService.onMessageViewed();
        }
      });
    }
  }

  Future<void> _getThreadMessages() async {
    try {
      // if (this.disableHistory) {
      //   $state.complete()

      //   return
      // }

      final messageId = messages.isNotEmpty ? messages[0].id : null;
      final storageDate = messages.isNotEmpty ? messages[0].date : null;

      final result = await MessageProcessor.getMessages(
          _clientController.ownerIdentity!, messageId, storageDate);
      final items = <BlipMessage>[];

      _hasMoreMessages = result.resource['items'].length >= 50;

      final isLastMessageSensitive = result.resource['items'].isNotEmpty &&
          _isMessageSensitive(
              BlipMessage.fromJson(result.resource['items'].first));

      for (final item in result.resource['items']) {
        final message = BlipMessage.fromJson(item);
        if (!config.showMessageStatus ||
            message.direction == MessageDirection.received) {
          message.status = NotificationEvent.unknown;
        }

        _formatSensitiveMessage(message, changeSensitiveMessageType: false);

        items.add(message);
      }

      if (isLastMessageSensitive) {
        messageType.value = MessageContentType.sensitive;
      }

      if (items.isEmpty) {
        // $state.complete()
        return;
      }

      for (final item in items) {
        if ((item.metadata?['#blip.payload.content'] ??
                item.metadata?['#blip.payload.text']) !=
            null) {
          item.type = item.metadata?['#blip.payload.type'] ??
              MessageContentType.textPlain;
          item.content = item.metadata?['#blip.payload.content'] ??
              item.metadata?['#blip.payload.text'];

          if (item.type != MessageContentType.textPlain) {
            try {
              item.content = jsonEncode(item.content);
            } catch (e) {
              print(e);
            }
          }
        }
      }

      // Hide redirect messages from thread
      final filteresList = items.where((msg) => ![
            MessageContentType.redirect,
            MessageContentType.ticket
          ].any((x) => x == msg.type));

      // $state.loaded()

      messages.assignAll([...filteresList, ...messages]);
      messages.sort((a, b) => a.date!.compareTo(b.date!));
      hiddenMessages.assignAll([...messages]);

      _formatMessages();

      /// TODO: Format hidden messages

      _clientController.hasMessages = messages.isNotEmpty;
    } catch (e) {
      print(e);
      // $state.complete()
    } finally {
      // this.mutationApplicationLoading(false)
      _isGettingMoreMessages = false;
    }
  }

  void _formatSensitiveMessage(
    BlipMessage message, {
    bool changeSensitiveMessageType = true,
  }) {
    if (_isMessageSensitive(message)) {
      if (changeSensitiveMessageType) {
        messageType.value = MessageContentType.sensitive;
      }

      if (message.content['label'] != null) {
        message.type = message.content['label']['type'];
        message.content = message.content['label']['value'];
      }
    }

    if (message.type == MessageContentType.sensitive) {
      if (message.direction == MessageDirection.sent) {
        // Do not show if it was sent by the user
        message.type = MessageContentType.textPlain;
        message.content = '**********';
      } else if (message.content != null &&
          message.content['type'] != null &&
          message.content['value'] != null) {
        // Unwrap a received sensitive content
        message.type = message.content['type'];
        message.content = message.content['value'];
      }
    }
  }

  bool _isMessageSensitive(BlipMessage message) =>
      message.type == MessageContentType.input &&
      message.content['validation'] != null &&
      message.content['validation']['rule'] == 'type' &&
      message.content['validation']['type'] == MessageContentType.sensitive;

  void _formatMessage(BlipMessage message) {
    if (_isComposingChatstateAndNotLastMessage(messages, message) ||
        _isPausedChatstate(message) ||
        _isHiddenMessage(message)) {
      return;
    }

    if (formattedMessages.any((x) => x.id == message.id)) {
      final index = formattedMessages.indexWhere((x) => x.id == message.id);
      final formattedMessage = formattedMessages[index];

      formattedMessage.date = message.date!.toIso8601String();
      formattedMessage.displayDate = UtilsService.getChatDisplayDate(
        date: message.date?.toIso8601String(),
      );
      formattedMessage.status =
          DSDeliveryReportStatus.unknown.getValue(message.status.name);

      formattedMessages.removeAt(index);
      formattedMessages.insert(index, formattedMessage);
    } else {
      final formattedMessage = _fromBlipMessage(message);

      formattedMessages.add(formattedMessage);
      formattedHiddenMessages.add(formattedMessage);
    }
  }

  void _formatMessages() {
    if (config.removeDuplicatedMessages) {
      _removeDuplicatedMessages();
    }

    formattedMessages.assignAll(
      messages
          .where((x) => !(_isComposingChatstateAndNotLastMessage(messages, x) ||
              _isPausedChatstate(x) ||
              _isHiddenMessage(x)))
          .map<DSMessageItemModel>(_fromBlipMessage),
    );

    _formatHiddenMessages();
  }

  void _formatHiddenMessages() {
    formattedHiddenMessages.assignAll(
      hiddenMessages
          .where(_isHiddenMessage)
          .map<DSMessageItemModel>(_fromBlipMessage),
    );
  }

  bool _isComposingChatstateAndNotLastMessage(
      List<BlipMessage> list, BlipMessage message) {
    final index = list.indexOf(message);
    return (message.type?.contains('chatstate') ?? false) &&
        message.content['state'] == ChatStateTypes.composing.name &&
        index != list.length - 1;
  }

  bool _isPausedChatstate(BlipMessage message) =>
      (message.type?.contains('chatstate') ?? false) &&
      message.content['state'] == ChatStateTypes.paused.name;

  bool _isHiddenMessage(BlipMessage message) =>
      message.metadata?['#blip.hiddenMessage']?.toLowerCase() == 'true';

  void _removeDuplicatedMessages() {
    final uniqueMessages = <BlipMessage>[];

    for (final message in messages) {
      if ((message.type?.contains('chatstate') ?? false) ||
          !uniqueMessages.any((x) => x.id == message.id)) {
        uniqueMessages.add(message);
      }
    }

    messages.assignAll(uniqueMessages);
  }

  DSMessageItemModel _fromBlipMessage(final BlipMessage message) =>
      DSMessageItemModel.fromJson(
        {
          'id': message.id,
          'date': message.date!.toIso8601String(),
          'displayDate': UtilsService.getChatDisplayDate(
            date: message.date?.toIso8601String(),
          ),
          'align':
              message.direction == MessageDirection.received ? 'left' : 'right',
          'type': message.type,
          'content': message.content,
          // 'hideOptions': i === a.length - 1 ? false : true,
          'customerName': message.direction == MessageDirection.received
              ? ownerDisplayData.name
              : message.from?.name ?? '',
          'customerAvatar': message.direction == MessageDirection.received
              ? ownerDisplayData.photo
              : null,
          'status': (config.showMessageStatus
                  ? message.status
                  : NotificationEvent.unknown)
              .name,
        },
      );

  void _setAppStyle() {
    final style = properties.style ?? AppStyle();

    if (!style.overrideOwnerColors) {
      // Customize blip chat with owner configs
      final primaryColor = ownerAccount.extras.componentsColor;
      if (primaryColor?.isNotEmpty ?? false) {
        style.primaryColor = HexColor.fromHex(primaryColor!);
      }

      final backgroundColor = ownerAccount.extras.chatColor;
      if (backgroundColor?.isNotEmpty ?? false) {
        style.backgroundColor = HexColor.fromHex(backgroundColor!);
      }
    }

    AppTheme.setStyle(style);
  }
}
