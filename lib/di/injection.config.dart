// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../features/trips/data/datasources/trip_firestore_datasource.dart'
    as _i213;
import '../features/trips/data/repositories/trip_repository_impl.dart' as _i107;
import '../features/trips/domain/repositories/trip_repository.dart' as _i345;
import '../features/trips/domain/usecases/create_trip_usecase.dart' as _i119;
import '../features/trips/domain/usecases/delete_trip_usecase.dart' as _i594;
import '../features/trips/domain/usecases/update_trip_usecase.dart' as _i313;
import '../features/trips/domain/usecases/watch_trips_usecase.dart' as _i108;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt $initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i213.TripFirestoreDatasource>(
      () => _i213.TripFirestoreDatasourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i345.TripRepository>(
      () => _i107.TripRepositoryImpl(gh<_i213.TripFirestoreDatasource>()),
    );
    gh.factory<_i119.CreateTripUsecase>(
      () => _i119.CreateTripUsecase(gh<_i345.TripRepository>()),
    );
    gh.factory<_i594.DeleteTripUsecase>(
      () => _i594.DeleteTripUsecase(gh<_i345.TripRepository>()),
    );
    gh.factory<_i313.UpdateTripUsecase>(
      () => _i313.UpdateTripUsecase(gh<_i345.TripRepository>()),
    );
    gh.factory<_i108.WatchTripsUsecase>(
      () => _i108.WatchTripsUsecase(gh<_i345.TripRepository>()),
    );
    return this;
  }
}
