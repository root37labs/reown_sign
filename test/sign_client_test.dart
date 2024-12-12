import 'package:flutter_test/flutter_test.dart';
import 'package:reown_core/reown_core.dart';

import 'shared/shared_test_utils.dart';
import 'shared/shared_test_values.dart';
import 'tests/sign_common.dart';
import 'utils/sign_client_test_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  mockPackageInfo();
  mockConnectivity();

  signEngineTests(
    context: 'SignClient',
    clientACreator: (PairingMetadata metadata) async =>
        await SignClientTestWrapper.createInstance(
      projectId: TEST_PROJECT_ID,
      relayUrl: TEST_RELAY_URL,
      metadata: metadata,
      memoryStore: true,
      logLevel: LogLevel.info,
      httpClient: getHttpWrapper(),
    ),
    clientBCreator: (PairingMetadata metadata) async =>
        await SignClientTestWrapper.createInstance(
      projectId: TEST_PROJECT_ID,
      relayUrl: TEST_RELAY_URL,
      metadata: metadata,
      memoryStore: true,
      logLevel: LogLevel.info,
      httpClient: getHttpWrapper(),
    ),
  );
}
