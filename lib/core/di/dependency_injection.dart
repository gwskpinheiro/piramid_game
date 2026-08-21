import 'package:auto_injector/auto_injector.dart';

import '../../core/theme/theme_controller.dart';
import '../../data/repositories/aluno_repository_impl.dart';
import '../../data/repositories/aluno_repository_interface.dart';
import '../../data/services/aluno_local_storage_interface.dart';
import '../../data/services/aluno_sqlite_impl.dart';         // ← SQLite
import '../../domain/facades/aluno_facade_usecases_impl.dart';
import '../../domain/facades/aluno_facade_usecases_interface.dart';
import '../../domain/usecases/aluno_usecases_impl.dart';
import '../../domain/usecases/aluno_usecases_interfaces.dart';
import '../../presentation/controllers/aluno_viewmodel.dart';

final injector = AutoInjector();

void setupDependencyInjection() {
  // Core
  injector.addSingleton<ThemeController>(ThemeController.new);

  // Data — Service (SQLite)
  injector.addSingleton<IAlunoLocalStorage>(AlunoSqliteService.new);

  // Data — Repository
  injector.addSingleton<IAlunoRepository>(AlunoRepositoryImpl.new);

  // Domain — Use Cases
  injector.addSingleton<ICadastrarAlunoUseCase>(CadastrarAlunoUseCaseImpl.new);
  injector.addSingleton<IObterTodosAlunosUseCase>(ObterTodosAlunosUseCaseImpl.new);
  injector.addSingleton<IObterAlunoPorIdUseCase>(ObterAlunoPorIdUseCaseImpl.new);
  injector.addSingleton<IAtualizarAlunoUseCase>(AtualizarAlunoUseCaseImpl.new);
  injector.addSingleton<IDeletarAlunoUseCase>(DeletarAlunoUseCaseImpl.new);
  injector.addSingleton<ICalcularRankingUseCase>(CalcularRankingUseCaseImpl.new);

  // Domain — Facade
  injector.addSingleton<IAlunoFacadeUseCases>(AlunoFacadeUseCasesImpl.new);

  // Presentation — ViewModel
  injector.addSingleton<AlunoViewModel>(AlunoViewModel.new);

  injector.commit();
}
