import 'package:flutter_test/flutter_test.dart';
import 'package:reown_sign/reown_sign.dart';
import 'package:reown_sign/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthValidators', () {
    test('isValidRequestExpiry', () {
      final List<int> expiries = [
        StringConstants.AUTH_REQUEST_EXPIRY_MIN - 1,
        StringConstants.AUTH_REQUEST_EXPIRY_MIN,
        StringConstants.AUTH_REQUEST_EXPIRY_MIN + 1,
        StringConstants.AUTH_REQUEST_EXPIRY_MAX - 1,
        StringConstants.AUTH_REQUEST_EXPIRY_MAX,
        StringConstants.AUTH_REQUEST_EXPIRY_MAX + 1,
      ];
      final List<bool> expiryResults = [
        false,
        true,
        true,
        true,
        true,
        false,
      ];

      // Loop through the expiries and expect the results
      for (var i = 0; i < expiries.length; i++) {
        final expiry = expiries[i];
        final result = expiryResults[i];

        expect(AuthApiValidators.isValidRequestExpiry(expiry), result);
      }
    });

    // test('isValidRequest', () {
    //   expect(
    //     AuthApiValidators.isValidRequest(testAuthRequestParamsValid),
    //     true,
    //   );
    //   expect(
    //     () => AuthApiValidators.isValidRequest(testAuthRequestParamsInvalidAud),
    //     throwsA(
    //       isA<ReownSignError>().having(
    //         (e) => e.message,
    //         'message',
    //         'Missing or invalid. requestAuth() invalid aud: ${testAuthRequestParamsInvalidAud.aud}. Must be a valid url.',
    //       ),
    //     ),
    //   );
    //   expect(
    //     () => AuthApiValidators.isValidRequest(
    //       testAuthRequestParamsInvalidNonce,
    //     ),
    //     throwsA(
    //       isA<ReownSignError>().having(
    //         (e) => e.message,
    //         'message',
    //         'Missing or invalid. requestAuth() nonce must be nonempty.',
    //       ),
    //     ),
    //   );
    //   expect(
    //     () =>
    //         AuthApiValidators.isValidRequest(testAuthRequestParamsInvalidType),
    //     throwsA(
    //       isA<ReownSignError>().having(
    //         (e) => e.message,
    //         'message',
    //         'Missing or invalid. requestAuth() type must null or ${CacaoHeader.EIP4361}.',
    //       ),
    //     ),
    //   );
    //   expect(
    //     () => AuthApiValidators.isValidRequest(
    //         testAuthRequestParamsInvalidExpiry),
    //     throwsA(
    //       isA<ReownSignError>().having(
    //         (e) => e.message,
    //         'message',
    //         'Missing or invalid. requestAuth() expiry: ${testAuthRequestParamsInvalidExpiry.expiry}. Expiry must be a number (in seconds) between ${StringConstants.AUTH_REQUEST_EXPIRY_MIN} and ${StringConstants.AUTH_REQUEST_EXPIRY_MAX}',
    //       ),
    //     ),
    //   );
    // });

    // test('isValidRespond', () {
    //   expect(
    //     AuthApiValidators.isValidRespond(
    //       id: TEST_PENDING_REQUEST_ID,
    //       pendingRequests: testPendingRequests,
    //       signature: const CacaoSignature(t: '', s: ''),
    //     ),
    //     true,
    //   );
    //   expect(
    //     () => AuthApiValidators.isValidRespond(
    //       id: TEST_PENDING_REQUEST_ID_INVALID,
    //       pendingRequests: testPendingRequests,
    //     ),
    //     throwsA(
    //       isA<ReownSignError>().having(
    //         (e) => e.message,
    //         'message',
    //         'Missing or invalid. respondAuth() invalid id: $TEST_PENDING_REQUEST_ID_INVALID. No pending request found.',
    //       ),
    //     ),
    //   );
    //   expect(
    //     () => AuthApiValidators.isValidRespond(
    //       id: TEST_PENDING_REQUEST_ID,
    //       pendingRequests: testPendingRequests,
    //     ),
    //     throwsA(
    //       isA<ReownSignError>().having(
    //         (e) => e.message,
    //         'message',
    //         'Missing or invalid. respondAuth() invalid response. Must contain either signature or error.',
    //       ),
    //     ),
    //   );
    // });
  });
}
