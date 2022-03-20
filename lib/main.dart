import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chess_demo/chess_attachment.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = StreamChatClient(
    'YOUR_API_KEY',
    logLevel: Level.INFO,
  );

  await client.connectUser(
    User(id: 'YOUR_USER_ID'),
    '''YOUR_TOKEN''',
  );

  final channel = client.channel('messaging', id: 'godevs');

  await channel.watch();

  runApp(
    MyApp(
      client: client,
      channel: channel,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
    required this.channel,
  }) : super(key: key);

  final StreamChatClient client;

  /// Instance of the Channel
  final Channel channel;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        builder: (context, widget) => StreamChat(
          client: client,
          child: widget,
        ),
        home: StreamChannel(
          channel: channel,
          child: const ChannelPage(),
        ),
      );
}

class ChannelPage extends StatefulWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  GlobalKey<MessageInputState> _mipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              messageBuilder: (context, details, list, defaultWidget) {
                return defaultWidget.copyWith(
                  customAttachmentBuilders: {
                    'chess': (context2, message, list) {
                      var attachment = message.attachments
                          .firstWhere((e) => e.type == 'chess');
                      var chessAttachment =
                          ChessAttachment.fromJson(attachment.extraData);
                      var chessBoardController =
                          ChessBoardController.fromGame(chessAttachment.game);

                      chessBoardController.addListener(
                        () {
                          StreamChannel.of(context).channel.updateMessage(
                                message.copyWith(
                                  attachments: [
                                    attachment.copyWith(
                                      uploadState: const UploadState.success(),
                                      extraData: chessAttachment
                                          .copyWith(
                                            game: chessBoardController.game,
                                          )
                                          .toJson(),
                                    ),
                                  ],
                                ),
                              );
                        },
                      );

                      return ChessBoard(
                        controller: chessBoardController,
                        boardOrientation:
                            StreamChat.of(context).currentUser!.id ==
                                    chessAttachment.whiteUserId
                                ? PlayerColor.white
                                : PlayerColor.black,
                      );
                    },
                  },
                );
              },
            ),
          ),
          MessageInput(
            key: _mipKey,
            attachmentLimit: 3,
            actions: [
              IconButton(
                onPressed: () {
                  var newGame = Chess();
                  var userId = StreamChat.of(context).currentUser!.id;
                  var attachment =
                      ChessAttachment(game: newGame, whiteUserId: userId);

                  _mipKey.currentState?.addAttachment(
                    Attachment(
                      type: 'chess',
                      uploadState: const UploadState.success(),
                      extraData: attachment.toJson(),
                    ),
                  );
                },
                icon: const Icon(Icons.videogame_asset_outlined),
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints.tightFor(
                  height: 24,
                  width: 24,
                ),
                splashRadius: 24,
              ),
            ],
            attachmentThumbnailBuilders: {
              'chess': (context, attachment) {
                return SizedBox(
                  height: 75,
                  width: 75,
                  child: ChessBoard(
                    controller: ChessBoardController(),
                  ),
                );
              },
            },
          ),
        ],
      ),
    );
  }
}
