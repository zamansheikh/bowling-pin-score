// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bowlingpinscore/core/network/network_module.dart' as _i1050;
import 'package:bowlingpinscore/core/utils/shared_preferences_module.dart'
    as _i681;
import 'package:bowlingpinscore/features/bowling/data/datasources/bowling_local_data_source.dart'
    as _i968;
import 'package:bowlingpinscore/features/bowling/data/datasources/bowling_local_data_source_impl.dart'
    as _i956;
import 'package:bowlingpinscore/features/bowling/data/repositories/bowling_repository_impl.dart'
    as _i6;
import 'package:bowlingpinscore/features/bowling/domain/repositories/bowling_repository.dart'
    as _i893;
import 'package:bowlingpinscore/features/bowling/domain/usecases/get_current_game.dart'
    as _i295;
import 'package:bowlingpinscore/features/bowling/domain/usecases/start_new_game.dart'
    as _i439;
import 'package:bowlingpinscore/features/bowling/domain/usecases/update_frame.dart'
    as _i714;
import 'package:bowlingpinscore/features/bowling/presentation/bloc/bowling_bloc.dart'
    as _i261;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final sharedPreferencesModule = _$SharedPreferencesModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i968.BowlingLocalDataSource>(
      () => _i956.BowlingLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i893.BowlingRepository>(
      () => _i6.BowlingRepositoryImpl(gh<_i968.BowlingLocalDataSource>()),
    );
    gh.factory<_i295.GetCurrentGame>(
      () => _i295.GetCurrentGame(gh<_i893.BowlingRepository>()),
    );
    gh.factory<_i439.StartNewGame>(
      () => _i439.StartNewGame(gh<_i893.BowlingRepository>()),
    );
    gh.factory<_i714.UpdateFrame>(
      () => _i714.UpdateFrame(gh<_i893.BowlingRepository>()),
    );
    gh.factory<_i261.BowlingBloc>(
      () => _i261.BowlingBloc(
        getCurrentGame: gh<_i295.GetCurrentGame>(),
        startNewGame: gh<_i439.StartNewGame>(),
        updateFrame: gh<_i714.UpdateFrame>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i1050.NetworkModule {}

class _$SharedPreferencesModule extends _i681.SharedPreferencesModule {}
