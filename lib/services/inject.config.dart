// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:kmt/services/base_service.dart' as _i676;
import 'package:kmt/services/thirdparty_services_module.dart' as _i758;
import 'package:stacked_services/stacked_services.dart' as _i1055;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final thirdPartyServicesModule = _$ThirdPartyServicesModule();
    gh.lazySingleton<_i676.BaseService>(() => _i676.BaseService());
    gh.lazySingleton<_i1055.NavigationService>(
        () => thirdPartyServicesModule.navigationService);
    gh.lazySingleton<_i1055.DialogService>(
        () => thirdPartyServicesModule.dialogService);
    return this;
  }
}

class _$ThirdPartyServicesModule extends _i758.ThirdPartyServicesModule {
  @override
  _i1055.NavigationService get navigationService => _i1055.NavigationService();

  @override
  _i1055.DialogService get dialogService => _i1055.DialogService();
}
