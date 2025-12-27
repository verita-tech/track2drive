import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/auto_tracking/domain/usecases/save_auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/domain/usecases/watch_auto_tracking_rule.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_event.dart';
import 'package:track2drive/features/auto_tracking/presentation/bloc/auto_tracking_state.dart';
import 'dart:async';

class AutoTrackingBloc extends Bloc<AutoTrackingEvent, AutoTrackingState> {
  final WatchAutoTrackingRule _watchRule;
  final SaveAutoTrackingRule _saveRule;

  StreamSubscription? _watchSubscription;

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
    _watchSubscription?.cancel();

    _watchSubscription = _watchRule(event.userId).listen(
      (rule) {
        add(AutoTrackingSaveRuleEvent(userId: event.userId, rule: rule!));
        emit(state.copyWith(status: AutoTrackingStatus.success, rule: rule));
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
    } catch (error) {
      emit(
        state.copyWith(
          status: AutoTrackingStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
