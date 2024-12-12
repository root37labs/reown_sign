import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reown_core/reown_core.dart';
import 'package:reown_sign/i_sign_common.dart';
import 'package:reown_sign/i_sign_dapp.dart';
import 'package:reown_sign/i_sign_wallet.dart';
import 'package:reown_sign/models/basic_models.dart';

import '../shared/shared_test_values.dart';
import '../utils/engine_constants.dart';
import 'sign_client_helpers.dart';

void signRejectSession({
  required Future<IReownSignDapp> Function(PairingMetadata) clientACreator,
  required Future<IReownSignWallet> Function(PairingMetadata) clientBCreator,
}) {
  group('rejectSession', () {
    late IReownSignDapp clientA;
    late IReownSignWallet clientB;
    List<IReownSignCommon> clients = [];

    setUp(() async {
      clientA = await clientACreator(PROPOSER);
      clientB = await clientBCreator(RESPONDER);
      clients.add(clientA);
      clients.add(clientB);

      await clientB.proposals.set(
        TEST_PROPOSAL_VALID_ID.toString(),
        TEST_PROPOSAL_VALID,
      );
      await clientB.proposals.set(
        TEST_PROPOSAL_EXPIRED_ID.toString(),
        TEST_PROPOSAL_EXPIRED,
      );
      await clientB.core.expirer.set(
        TEST_PROPOSAL_EXPIRED_ID.toString(),
        TEST_PROPOSAL_EXPIRED.expiry,
      );
      await clientB.proposals.set(
        TEST_PROPOSAL_INVALID_REQUIRED_NAMESPACES_ID.toString(),
        TEST_PROPOSAL_INVALID_REQUIRED_NAMESPACES,
      );
      await clientB.proposals.set(
        TEST_PROPOSAL_INVALID_OPTIONAL_NAMESPACES_ID.toString(),
        TEST_PROPOSAL_INVALID_OPTIONAL_NAMESPACES,
      );
    });

    tearDown(() async {
      clients.clear();
      await clientA.core.relayClient.disconnect();
      await clientB.core.relayClient.disconnect();
    });

    test('throws catchable error properly', () async {
      await SignClientHelpers.testConnectPairReject(
        clientA,
        clientB,
      );
    });

    test('deletes the proposal', () async {
      await clientB.rejectSession(
        id: TEST_PROPOSAL_VALID_ID,
        reason: const ReownSignError(code: -1, message: 'reason'),
      );

      expect(
        clientB.proposals.has(
          TEST_PROPOSAL_VALID_ID.toString(),
        ),
        false,
      );
    });

    test('invalid proposal id', () async {
      expect(
        () async => await clientB.rejectSession(
          id: TEST_APPROVE_ID_INVALID,
          reason: const ReownSignError(code: -1, message: 'reason'),
        ),
        throwsA(
          isA<ReownSignError>().having(
            (e) => e.message,
            'message',
            'No matching key. proposal id doesn\'t exist: $TEST_APPROVE_ID_INVALID',
          ),
        ),
      );

      int counter = 0;
      Completer completer = Completer();
      clientB.core.expirer.onExpire.subscribe((args) {
        counter++;
        completer.complete();
      });
      int counter2 = 0;
      Completer completer2 = Completer();
      clientB.onProposalExpire.subscribe((args) {
        counter2++;
        completer2.complete();
      });
      expect(
        () async => await clientB.rejectSession(
          id: TEST_PROPOSAL_EXPIRED_ID,
          reason: const ReownSignError(code: -1, message: 'reason'),
        ),
        throwsA(
          isA<ReownSignError>().having(
            (e) => e.message,
            'message',
            'Expired. proposal id: $TEST_PROPOSAL_EXPIRED_ID',
          ),
        ),
      );

      // await Future.delayed(Duration(milliseconds: 150));
      await completer.future;
      await completer2.future;

      expect(
        clientB.proposals.has(
          TEST_PROPOSAL_EXPIRED_ID.toString(),
        ),
        false,
      );
      expect(counter, 1);
      expect(counter2, 1);
      clientB.core.expirer.onExpire.unsubscribeAll();
      clientB.onProposalExpire.unsubscribeAll();
    });
  });
}
