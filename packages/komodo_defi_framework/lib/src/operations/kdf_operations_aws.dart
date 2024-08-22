// import 'dart:async';

// import 'package:aws_client/ec2_2016_11_15.dart';
// import 'package:aws_client/ssm_2014_11_06.dart';
// import 'package:komodo_defi_framework/src/config/kdf_config.dart';
// import 'package:komodo_defi_framework/src/operations/kdf_operations_interface.dart';
// import 'package:komodo_defi_framework/src/operations/kdf_operations_remote.dart';

// class KdfOperationsAWS implements IKdfOperations {
//   factory KdfOperationsAWS.create({
//     required void Function(String) logCallback,
//     required AwsConfig config,
//   }) {
//     final credentials = AwsClientCredentials(
//       accessKey: config.accessKey,
//       secretKey: config.secretKey,
//     );

//     final ec2Client = Ec2(
//       region: config.region,
//       credentials: credentials,
//     );

//     final ssmClient = Ssm(
//       region: config.region,
//       credentials: credentials,
//     );

//     return KdfOperationsAWS._(
//       logCallback,
//       ec2Client,
//       ssmClient,
//       config,
//     );
//   }

//   KdfOperationsAWS._(
//     this._logCallback,
//     this._ec2Client,
//     this._ssmClient,
//     this._config,
//   );

//   final void Function(String) _logCallback;
//   final Ec2 _ec2Client;
//   final Ssm _ssmClient;
//   final AwsConfig _config;

//   String? _instanceId;
//   String? _publicIp;

//   void _log(String message) => _logCallback(message);

//   @override
//   String operationsName = 'Amazon Web Services (AWS)';

//   @override
//   Future<bool> isRunning() async {
//     return await kdfMainStatus() == MainStatus.rpcIsUp;
//   }

//   @override
//   Future<KdfStartupResult> kdfMain(String startParamsJson) async {
//     if (_instanceId == null) {
//       await _launchInstance();
//     }

//     if (_publicIp != null) {
//       await _runDockerContainer(startParamsJson);
//       return KdfStartupResult.ok;
//     }

//     _log('Failed to start the KDF instance.');
//     return KdfStartupResult.invalidParams;
//   }

//   @override
//   Future<MainStatus> kdfMainStatus() async {
//     final versionResult = await version();
//     return versionResult != null ? MainStatus.rpcIsUp : MainStatus.noRpc;
//   }

//   @override
//   Future<StopStatus> kdfStop() async {
//     if (_instanceId == null) {
//       return StopStatus.notRunning;
//     }
//     await remoteOperations?.kdfStop();

//     await _terminateInstance();
//     return StopStatus.ok;
//   }

//   @override
//   Future<Map<String, dynamic>> mm2Rpc(Map<String, dynamic> request) async {
//     if (_publicIp == null) {
//       throw Exception('KDF API is not running.');
//     }
//     return remoteOperations!.mm2Rpc(request);
//   }

//   @override
//   Future<void> validateSetup() async {
//     final version = await this.version();
//     if (version == null) {
//       throw Exception('Failed to validate AWS KDF setup');
//     }
//   }

//   KdfOperationsRemote? get remoteOperations => _publicIp == null
//       ? null
//       : KdfOperationsRemote.create(
//           logCallback: _logCallback,
//           ipAddress: _publicIp!,
//           port: 7783,
//           userpass: _config.rpcPassword,
//         );

//   @override
//   Future<String?> version() async => remoteOperations?.version();

//   Future<void> _launchInstance() async {
//     _log('Launching AWS EC2 instance...');
//     final result = await _ec2Client.runInstances(
//       instanceType: InstanceType.fromString(_config.instanceType),
//       keyName: _config.keyName,
//       securityGroups:
//           _config.securityGroup == null ? null : [_config.securityGroup!],
//       imageId: _config.amiId,
//       minCount: 1,
//       maxCount: 1,
//     );

//     if ((result.instances ?? []).isNotEmpty) {
//       _instanceId = result.instances!.first.instanceId;
//       _log('Instance launched with ID: $_instanceId');

//       await _waitForInstanceRunning();
//     }
//   }

//   Future<void> _runDockerContainer(String startParamsJson) async {
//     if (_instanceId == null) {
//       throw Exception('Instance ID is null, cannot run Docker container.');
//     }

//     try {
//       _log('Sending command to run Docker container...');
//       final sendCommandResult = await _ssmClient.sendCommand(
//         instanceIds: [_instanceId!],
//         documentName: 'AWS-RunShellScript',
//         parameters: {
//           'commands': [
//             'sudo docker run -d -p 7783:7783 komodoofficial/komodo-defi-framework',
//             "echo '$startParamsJson' > /root/MM2.json",
//             "sudo docker exec <container_id> /bin/bash -c 'mm2 /root/MM2.json'",
//           ],
//         },
//       );

//       _log('SSM command sent: ${sendCommandResult.command?.commandId}');
//     } catch (e) {
//       _log('Failed to run Docker container via SSM: $e');
//       throw Exception('Failed to run Docker container via SSM.');
//     }
//   }

//   Future<void> _terminateInstance() async {
//     if (_instanceId != null) {
//       _log('Terminating AWS EC2 instance $_instanceId...');
//       await _ec2Client.terminateInstances(
//         instanceIds: [_instanceId!],
//       );
//       _instanceId = null;
//       _publicIp = null;
//       _log('Instance terminated.');
//     }
//   }

//   Future<void> _waitForInstanceRunning() async {
//     _log('Waiting for the instance to be in running state...');

//     while (true) {
//       final describeInstancesResult = await _ec2Client.describeInstances(
//         instanceIds: [_instanceId!],
//       );

//       if ((describeInstancesResult.reservations?.first.instances ?? [])
//           .isNotEmpty) {
//         final instance =
//             describeInstancesResult.reservations!.first.instances!.first;

//         if (instance.state?.name == InstanceStateName.running) {
//           _publicIp = instance.publicIpAddress;
//           _log('Instance is running with public IP: $_publicIp');
//           break;
//         }
//       }

//       await Future.delayed(const Duration(seconds: 10));
//     }
//   }
// }
