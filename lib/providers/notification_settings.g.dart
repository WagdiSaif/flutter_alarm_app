// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AlarmController)
const alarmControllerProvider = AlarmControllerProvider._();

final class AlarmControllerProvider
    extends $NotifierProvider<AlarmController, List<AlarmModel>> {
  const AlarmControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmControllerHash();

  @$internal
  @override
  AlarmController create() => AlarmController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AlarmModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AlarmModel>>(value),
    );
  }
}

String _$alarmControllerHash() => r'8026c28ac3d8ff326c1879501a9f13b47b6790b5';

abstract class _$AlarmController extends $Notifier<List<AlarmModel>> {
  List<AlarmModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<AlarmModel>, List<AlarmModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AlarmModel>, List<AlarmModel>>,
              List<AlarmModel>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
