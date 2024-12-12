import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reown_core/reown_core.dart';
import 'package:reown_sign/i_sign_common.dart';
import 'package:reown_sign/i_sign_dapp.dart';
import 'package:reown_sign/i_sign_wallet.dart';

import '../shared/shared_test_values.dart';
import 'sign_client_helpers.dart';

void signHappyPath({
  required Future<IReownSignDapp> Function(PairingMetadata) clientACreator,
  required Future<IReownSignWallet> Function(PairingMetadata) clientBCreator,
}) {
  group('happy path', () {
    late IReownSignDapp clientA;
    late IReownSignWallet clientB;
    List<IReownSignCommon> clients = [];

    setUp(() async {
      clientA = await clientACreator(PROPOSER);
      clientB = await clientBCreator(RESPONDER);
      clients.add(clientA);
      clients.add(clientB);
    });

    tearDown(() async {
      clients.clear();
      await clientA.core.relayClient.disconnect();
      await clientB.core.relayClient.disconnect();
    });

    test('Initializes', () async {
      expect(clientA.core.pairing.getPairings().length, 0);
      expect(clientB.core.pairing.getPairings().length, 0);
    });

    test('connects, reconnects, and emits proper events', () async {
      Completer completerA = Completer();
      Completer completerB = Completer();
      int counterA = 0;
      int counterB = 0;
      clientA.onSessionConnect.subscribe((args) {
        counterA++;
        completerA.complete();
      });
      clientB.onSessionProposal.subscribe((args) {
        counterB++;
        completerB.complete();
      });

      final connectionInfo = await SignClientHelpers.testConnectPairApprove(
        clientA,
        clientB,
      );

      if (!completerA.isCompleted) {
        await completerA.future;
      }
      if (!completerB.isCompleted) {
        await completerB.future;
      }

      completerA = Completer();
      completerB = Completer();

      expect(counterA, 1);
      expect(counterB, 1);

      expect(
        clientA.pairings.getAll().length,
        clientB.pairings.getAll().length,
      );
      expect(clientA.getActiveSessions().length, 1);
      expect(clientB.getActiveSessions().length, 1);
      expect(
        clientA
            .getSessionsForPairing(
              pairingTopic: connectionInfo.pairing.topic,
            )
            .length,
        1,
      );
      expect(
        clientB
            .getSessionsForPairing(
              pairingTopic: connectionInfo.pairing.topic,
            )
            .length,
        1,
      );
      final _ = await SignClientHelpers.testConnectPairApprove(
        clientA,
        clientB,
        pairingTopic: connectionInfo.pairing.topic,
      );

      if (!completerA.isCompleted) {
        await completerA.future;
      }
      if (!completerB.isCompleted) {
        await completerB.future;
      }

      expect(counterA, 2);
      expect(counterB, 2);

      clientA.onSessionConnect.unsubscribeAll();
      clientB.onSessionProposal.unsubscribeAll();
    });

    test('connects, and reconnects with scan latency', () async {
      final connectionInfo = await SignClientHelpers.testConnectPairApprove(
        clientA,
        clientB,
        qrCodeScanLatencyMs: 1000,
      );
      expect(
        clientA.pairings.getAll().length,
        clientB.pairings.getAll().length,
      );
      final _ = await SignClientHelpers.testConnectPairApprove(
        clientA,
        clientB,
        pairingTopic: connectionInfo.pairing.topic,
        qrCodeScanLatencyMs: 1000,
      );
    });
  });
}
