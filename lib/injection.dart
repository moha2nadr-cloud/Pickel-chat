import 'data/repositories/chat_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/local_storage_service.dart';

class AppDependencies {
  AppDependencies._();

  static final instance = AppDependencies._();

  late final LocalStorageService localStorageService;
  late final ApiService apiService;
  late final StorageRepository storageRepository;
  late final ChatRepository chatRepository;
}

Future<void> setupDependencies() async {
  final deps = AppDependencies.instance;
  deps.localStorageService = LocalStorageService();
  await deps.localStorageService.init();
  deps.apiService = ApiService();
  deps.storageRepository = StorageRepository(deps.localStorageService);
  deps.chatRepository = ChatRepository(deps.apiService);
}
