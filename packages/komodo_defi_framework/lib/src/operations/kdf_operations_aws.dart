import 'dart:async';
import 'dart:convert';

import 'package:aws_client/ec2_2016_11_15.dart';
import 'package:aws_client/ssm_2014_11_06.dart';
import 'package:komodo_defi_framework/src/config/kdf_config.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';
import 'package:komodo_defi_framework/src/startup_config_manager.dart';

/// NB: This class is not complete and may still need significant work.
/// The current approach of when to set vs when to get the RPC userpass
/// may be flawed.
class KdfOperationsAWS implements IKdfOperations {
  factory KdfOperationsAWS.createFromConfig({
    required void Function(String) logCallback,
    required IKdfStartupConfig configManager,
    required AwsConfig config,
  }) {
    return KdfOperationsAWS.create(
      logCallback: logCallback,
      configManager: configManager,
      instanceType: config.instanceType,
      keyName: config.keyName!,
      securityGroup: config.securityGroup,
      amiId: config.amiId,
      region: config.region,
      accessKey: config.accessKey,
      secretKey: config.secretKey,
      userpass: config.userpass,
    );
  }

  factory KdfOperationsAWS.create({
    required void Function(String) logCallback,
    required IKdfStartupConfig configManager,
    required String instanceType,
    required String keyName,
    required String? amiId,
    required String region,
    required String accessKey,
    required String secretKey,
    required String userpass,
    String? securityGroup,
  }) {
    final credentials = AwsClientCredentials(
      accessKey: accessKey,
      secretKey: secretKey,
    );

    final ec2Client = Ec2(
      region: region,
      credentials: credentials,
    );

    final ssmClient = Ssm(
      region: region,
      credentials: credentials,
    );

    return KdfOperationsAWS._(
      logCallback,
      configManager,
      ec2Client,
      ssmClient,
      instanceType,
      keyName,
      securityGroup,
      amiId,
      userpass,
    );
  }

  KdfOperationsAWS._(
    this._logCallback,
    this._kdfStartupConfigManager,
    this._ec2Client,
    this._ssmClient,
    this._instanceType,
    this._keyName,
    this._securityGroup,
    this._amiId,
    this._userpass,
  );
  final void Function(String) _logCallback;
  final IKdfStartupConfig _kdfStartupConfigManager;
  final Ec2 _ec2Client;
  final Ssm _ssmClient;
  final String _instanceType;
  final String? _keyName;
  final String? _securityGroup;
  final String? _amiId;
  String? _userpass;

  String? _instanceId;
  String? _publicIp;

  void _log(String message) => _logCallback(message);

  @override
  Future<bool> isRunning() async {
    return await kdfMainStatus() == MainStatus.rpcIsUp;
  }

  @override
  Future<KdfStartupResult> kdfMain(String passphrase) async {
    if (_instanceId == null) {
      await _launchInstance();
    }

    if (_publicIp != null) {
      await _runDockerContainer(passphrase);
      return KdfStartupResult.ok;
    }

    _log('Failed to start the KDF instance.');
    return KdfStartupResult.invalidParams;
  }

  @override
  Future<MainStatus> kdfMainStatus() async {
    final versionResult = await version();
    return versionResult != null ? MainStatus.rpcIsUp : MainStatus.noRpc;
  }

  @override
  Future<StopStatus> kdfStop() async {
    if (_instanceId == null) {
      return StopStatus.notRunning;
    }
    await remoteOperations!.kdfStop();

    await _terminateInstance();
    return StopStatus.ok;
  }

  @override
  Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
    if (_publicIp == null) {
      throw Exception('KDF API is not running.');
    }
    return remoteOperations!.mm2Rpc(request);
  }

  @override
  Future<void> validateSetup() async {
    final version = await this.version();
    if (version == null) {
      throw Exception('Failed to validate AWS KDF setup');
    }
  }

  KdfOperationsRemote? get remoteOperations =>
      [_publicIp, _userpass].contains(null)
          ? null
          : KdfOperationsRemote.create(
              configManager: _kdfStartupConfigManager,
              logCallback: _logCallback,
              ipAddress: _publicIp!,
              userpass: _userpass!,
              port: 7783,
            );

  @override
  Future<String?> version() async => remoteOperations?.version();

  Future<void> _launchInstance() async {
    _log('Launching AWS EC2 instance...');
    final result = await _ec2Client.runInstances(
      instanceType: InstanceType.fromString(_instanceType),
      keyName: _keyName,
      securityGroups: _securityGroup == null ? null : [_securityGroup],
      imageId: _amiId,
      minCount: 1,
      maxCount: 1,
    );

    if ((result.instances ?? []).isNotEmpty) {
      _instanceId = result.instances!.first.instanceId;
      _log('Instance launched with ID: $_instanceId');

      await _waitForInstanceRunning();
    }
  }

  Future<void> _runDockerContainer(String passphrase) async {
    if (_instanceId == null) {
      throw Exception('Instance ID is null, cannot run Docker container.');
    }

    final pass = StartupConfigManager.generatePassword();

    try {
      _log('Generating KDF startup parameters...');
      final startParams = await _kdfStartupConfigManager
          .generateStartParamsFromDefault(passphrase, userpass: pass);
      final startParamsJson = json.encode(startParams);

      _log('Sending command to run Docker container...');
      final sendCommandResult = await _ssmClient.sendCommand(
        instanceIds: [_instanceId!],
        documentName: 'AWS-RunShellScript',
        parameters: {
          'commands': [
            'sudo docker run -d -p 7783:7783 komodoofficial/komodo-defi-framework',
            "echo '$startParamsJson' > /root/MM2.json",
            "sudo docker exec <container_id> /bin/bash -c 'mm2 /root/MM2.json'",
          ],
        },
      );

      _log('SSM command sent: ${sendCommandResult.command?.commandId}');
    } catch (e) {
      _log('Failed to run Docker container via SSM: $e');
      throw Exception('Failed to run Docker container via SSM.');
    }
  }

  Future<void> _terminateInstance() async {
    if (_instanceId != null) {
      _log('Terminating AWS EC2 instance $_instanceId...');
      await _ec2Client.terminateInstances(
        instanceIds: [_instanceId!],
      );
      _instanceId = null;
      _publicIp = null;
      _log('Instance terminated.');
    }
  }

  Future<void> _waitForInstanceRunning() async {
    _log('Waiting for the instance to be in running state...');

    while (true) {
      final describeInstancesResult = await _ec2Client.describeInstances(
        instanceIds: [_instanceId!],
      );

      if ((describeInstancesResult.reservations?.first.instances ?? [])
          .isNotEmpty) {
        final instance =
            describeInstancesResult.reservations!.first.instances!.first;

        if (instance.state?.name == InstanceStateName.running) {
          _publicIp = instance.publicIpAddress;
          _log('Instance is running with public IP: $_publicIp');
          break;
        }
      }

      await Future.delayed(const Duration(seconds: 10));
    }
  }

  // TODO! Set this up so we are fetching the RPC password from the instance.
  // Also, we need to set up the initial userpass for the instance if it's not
  // already set.
  Future<String?> _fetchRpcPassword() async {
    _log('Fetching RPC password from MM2.json...');
    final commandResult = await _ssmClient.sendCommand(
      instanceIds: [_instanceId!],
      documentName: 'AWS-RunShellScript',
      parameters: {
        'commands': [
          'cat /root/MM2.json',
        ],
      },
    );

    final commandOutput = await _ssmClient.getCommandInvocation(
      commandId: commandResult.command!.commandId!,
      instanceId: _instanceId!,
    );

    if (commandOutput.status == CommandInvocationStatus.success) {
      final mm2Config = json.decode(commandOutput.standardOutputContent!);
      return mm2Config['rpc_password'] as String?;
    } else {
      _log('Failed to retrieve MM2.json from instance.');
      throw Exception('Failed to retrieve MM2.json from instance.');
    }
  }
}
