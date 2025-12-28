import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:track2drive/di/injection.config.dart';

final sl = GetIt.instance;

@InjectableInit(initializerName: r'$initGetIt', preferRelativeImports: true)
Future<void> configureDependencies() async {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  await sl.$initGetIt();
}
