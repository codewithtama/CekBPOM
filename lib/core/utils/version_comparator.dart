/// Model to hold parsed semver components.
class VersionParts {
  const VersionParts({
    required this.major,
    required this.minor,
    required this.patch,
    required this.build,
  });

  final int major;
  final int minor;
  final int patch;
  final int build;

  @override
  String toString() => '$major.$minor.$patch+$build';
}

/// Utility for parsing and comparing application version strings.
class VersionComparator {
  const VersionComparator._();

  static final RegExp _semverRegex = RegExp(
    r'(?:v|version\s*)?(\d+)\.(\d+)(?:\.(\d+))?(?:[+-](?:build\.)?(\d+))?',
    caseSensitive: false,
  );

  /// Extracts [VersionParts] from a raw string (e.g. "v1.2.0", "CekBPOM v1.0.0 Release", "1.1.0+2").
  static VersionParts parse(String rawText, {int fallbackBuild = 0}) {
    final match = _semverRegex.firstMatch(rawText);
    if (match == null) {
      return VersionParts(major: 0, minor: 0, patch: 0, build: fallbackBuild);
    }

    final major = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minor = int.tryParse(match.group(2) ?? '0') ?? 0;
    final patch = int.tryParse(match.group(3) ?? '0') ?? 0;
    final build = int.tryParse(match.group(4) ?? '') ?? fallbackBuild;

    return VersionParts(
      major: major,
      minor: minor,
      patch: patch,
      build: build,
    );
  }

  /// Returns `true` if [remoteVersion] is strictly newer than [currentVersion].
  static bool isNewer({
    required String remoteVersion,
    required String currentVersion,
    int? remoteBuild,
    int? currentBuild,
  }) {
    final remote = parse(remoteVersion, fallbackBuild: remoteBuild ?? 0);
    final current = parse(currentVersion, fallbackBuild: currentBuild ?? 0);

    if (remote.major != current.major) {
      return remote.major > current.major;
    }
    if (remote.minor != current.minor) {
      return remote.minor > current.minor;
    }
    if (remote.patch != current.patch) {
      return remote.patch > current.patch;
    }

    final effectiveRemoteBuild = remoteBuild ?? remote.build;
    final effectiveCurrentBuild = currentBuild ?? current.build;
    return effectiveRemoteBuild > effectiveCurrentBuild;
  }
}
