import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessAttachment {
  final Chess game;
  final String whiteUserId;

  ChessAttachment({required this.game, required this.whiteUserId});

  factory ChessAttachment.fromJson(Map<String, dynamic> json) {
    return ChessAttachment(
      game: Chess.fromFEN(json['game'] as String),
      whiteUserId: json['white_user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'game': game.fen,
      'white_user_id': whiteUserId,
    };
  }

  ChessAttachment copyWith({
    Chess? game,
    String? whiteUserId,
  }) {
    return ChessAttachment(
      game: game ?? this.game,
      whiteUserId: whiteUserId ?? this.whiteUserId,
    );
  }
}
