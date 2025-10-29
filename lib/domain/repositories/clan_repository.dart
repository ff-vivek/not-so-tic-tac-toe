import 'package:not_so_tic_tac_toe_game/domain/entities/clan.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/clan_message.dart';

abstract class ClanRepository {
  Stream<Clan?> watchMyClan(String playerId);
  Future<String> createClan({required String name, required String ownerId});
  Future<void> joinClan({required String clanId, required String playerId});
  Future<void> leaveClan({required String clanId, required String playerId});
  Future<void> sendMessage({
    required String clanId,
    required String senderId,
    required String text,
  });
  Stream<List<ClanMessage>> watchMessages(String clanId);
}
