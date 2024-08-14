abstract class KdfConfig {
  KdfConfig({required this.userpass});
  final String userpass;

  String get hostType;

  Map<String, dynamic> toJson() {
    return {
      'hostType': hostType,
      'userpass': userpass,
    };
  }
}

class LocalConfig extends KdfConfig {
  LocalConfig({required super.userpass});

  @override
  String get hostType => 'local';

  LocalConfig copyWith({String? userpass}) {
    return LocalConfig(userpass: userpass ?? this.userpass);
  }
}

class RemoteConfig extends KdfConfig {
  RemoteConfig({
    required super.userpass,
    required this.ipAddress,
    required this.port,
  });
  final String ipAddress;
  final int port;

  @override
  String get hostType => 'remote';

  @override
  Map<String, dynamic> toJson() {
    return {
      'hostType': hostType,
      'userpass': userpass,
      'ipAddress': ipAddress,
      'port': port,
    };
  }
}

class AwsConfig extends KdfConfig {
  AwsConfig({
    required this.region,
    required this.accessKey,
    required this.secretKey,
    required this.instanceType,
    String? userpass,
    this.instanceId,
    this.keyName,
    this.securityGroup,
    this.amiId,
  }) : super(userpass: userpass!);
  final String region;
  final String? instanceId;
  final String? keyName;
  final String? securityGroup;
  final String? amiId;
  final String instanceType;
  final String accessKey;
  final String secretKey;

  @override
  String get hostType => 'aws';

  @override
  Map<String, dynamic> toJson() {
    return {
      'hostType': hostType,
      'userpass': userpass,
      'region': region,
      'instanceId': instanceId,
      'keyName': keyName,
      'securityGroup': securityGroup,
      'amiId': amiId,
      'instanceType': instanceType,
      'accessKey': accessKey,
      'secretKey': secretKey,
    };
  }
}

class DigitalOceanConfig extends KdfConfig {
  DigitalOceanConfig({
    required this.apiToken,
    required super.userpass,
    this.dropletId,
    this.dropletRegion = 'nyc1',
    this.dropletSize = 's-1vcpu-1gb',
    this.sshKeyId,
    this.image = 'ubuntu-20-04-x64',
  });
  final String apiToken;
  final String? dropletId;
  final String dropletRegion;
  final String dropletSize;
  final String? sshKeyId;
  final String image;

  @override
  String get hostType => 'digitalocean';

  @override
  Map<String, dynamic> toJson() {
    return {
      'hostType': hostType,
      'userpass': userpass,
      'apiToken': apiToken,
      'dropletId': dropletId,
      'dropletRegion': dropletRegion,
      'dropletSize': dropletSize,
      'sshKeyId': sshKeyId,
      'image': image,
    };
  }
}
