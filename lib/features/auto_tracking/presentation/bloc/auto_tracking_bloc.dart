import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:track2drive/features/auto_tracking/domain/usecases/save_auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/usecases/watch_auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/entities/auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_event.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_state.dart';

class AutoTrackingBloc extends Bloc<AutoTrackingEvent, AutoTrackingState> {
  final WatchAutoTrackingRule _watchRule;
  final SaveAutoTrackingRule _saveRule;

  StreamSubscription<AutoTrackingRule?>? _ruleSubscription;
  StreamSubscription<Position>? _locationSubscription;
  Timer? _timeCheckTimer;

  final List<Position> _positionHistory = [];
  bool _isCurrentlyTracking = false;

  AutoTrackingBloc({
    required WatchAutoTrackingRule watchRule,
    required SaveAutoTrackingRule saveRule,
  }) : _watchRule = watchRule,
       _saveRule = saveRule,
       super(const AutoTrackingState.initial()) {
    on<AutoTrackingSubscribeEvent>(_onSubscribe);
    on<AutoTrackingSaveRuleEvent>(_onSaveRule);
  }

  Future<void> _onSubscribe(
    AutoTrackingSubscribeEvent event,
    Emitter<AutoTrackingState> emit,
  ) async {
    emit(state.copyWith(status: AutoTrackingStatus.loading));

    _ruleSubscription?.cancel();
    _stopAllTracking();

    _ruleSubscription = _watchRule(event.userId).listen(
      (rule) {
        emit(state.copyWith(status: AutoTrackingStatus.success, rule: rule));

        if (rule?.enabled == true) {
          _startAutoTracking(rule!);
        } else {
          _stopAllTracking();
        }
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: AutoTrackingStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> _onSaveRule(
    AutoTrackingSaveRuleEvent event,
    Emitter<AutoTrackingState> emit,
  ) async {
    try {
      await _saveRule(event.userId, event.rule);
      emit(
        state.copyWith(status: AutoTrackingStatus.success, rule: event.rule),
      );

      if (event.rule.enabled) {
        _startAutoTracking(event.rule);
      } else {
        _stopAllTracking();
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: AutoTrackingStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _startAutoTracking(AutoTrackingRule rule) {
    _log('AutoTracking START: ${rule.bluetoothDeviceName ?? "Zeitregeln"}');

    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
            timeLimit: Duration(seconds: 1),
          ),
        ).listen((position) {
          _checkAutoTripConditions(rule, position);
        });

    _timeCheckTimer?.cancel();
    _timeCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      if (rule.isActiveNow(now, bluetoothConnected: false)) {
        _log(
          'Zeitfenster aktiv: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        );
      }
    });
  }

  void _checkAutoTripConditions(AutoTrackingRule rule, Position position) {
    final now = DateTime.now();

    final isTimeWindowOk = rule.isActiveNow(now, bluetoothConnected: false);
    final speedKmh = position.speed * 3.6;
    final isCarSpeed = speedKmh > 12.0;
    final isConsistentMovement = _hasConsistentMovement(position);

    _log(
      'Speed: ${speedKmh.toStringAsFixed(1)}km/h | '
      'Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')} | '
      'Car: $isCarSpeed | Consistent: $isConsistentMovement',
    );

    if (isTimeWindowOk && isCarSpeed && isConsistentMovement) {
      if (!_isCurrentlyTracking) {
        _startAutoTrip(rule, speedKmh, position);
      }
    } else if (_isCurrentlyTracking && !isCarSpeed) {
      _stopAutoTrip(position);
    }
  }

  bool _hasConsistentMovement(Position current) {
    _positionHistory.add(current);
    if (_positionHistory.length > 10) {
      _positionHistory.removeAt(0);
    }

    if (_positionHistory.length < 4) return false;

    double totalDistance = 0;
    for (int i = 0; i < _positionHistory.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        _positionHistory[i].latitude,
        _positionHistory[i].longitude,
        _positionHistory[i + 1].latitude,
        _positionHistory[i + 1].longitude,
      );
    }

    final result = totalDistance > 80.0;
    _log('Distanz: ${totalDistance.toStringAsFixed(0)}m → Moving: $result');
    return result;
  }

  void _startAutoTrip(
    AutoTrackingRule rule,
    double speedKmh,
    Position position,
  ) {
    _isCurrentlyTracking = true;
    _log(
      'AUTO-TRIP START! ${rule.bluetoothDeviceName ?? "Auto"} '
      '${speedKmh.toStringAsFixed(1)}km/h @ '
      '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}',
    );
  }

  void _stopAutoTrip(Position position) {
    if (!_isCurrentlyTracking) return;

    _isCurrentlyTracking = false;
    _log(
      'AUTO-TRIP STOP @ '
      '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}',
    );
  }

  void _stopAllTracking() {
    _isCurrentlyTracking = false;
    _positionHistory.clear();
    _locationSubscription?.cancel();
    _timeCheckTimer?.cancel();
    _log('AutoTracking STOPPED');
  }

  void _log(String message) {}

  @override
  Future<void> close() {
    _ruleSubscription?.cancel();
    _stopAllTracking();
    return super.close();
  }
}
