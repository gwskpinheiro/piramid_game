import 'package:auto_injector/auto_injector.dart';

import '../../data/repositories/preference_repository_impl.dart';
import '../../data/repositories/preference_repository_interface.dart';
import '../../data/services/local_storage_interface.dart';
import '../../data/services/local_storage_service.dart'; // ← SharedPreferences
import '../../domain/facades/tema_facade_usecases_impl.dart';
import '../../domain/facades/tema_facade_usecases_interface.dart';
import '../../domain/usecases/tema_usecases_impl.dart';
import '../../domain/usecases/tema_usecases_interfaces.dart';
import '../../presentation/controllers/theme_viewmodel.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/services/auth_service_interface.dart';
import '../../data/services/firebase_auth_service_impl.dart'; // ← Firebase Auth
import '../../domain/facades/auth_facade_usecases_impl.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/usecases/auth_usecases_impl.dart';
import '../../domain/usecases/auth_usecases_interfaces.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/pessoa_viewmodel.dart';
import '../../data/repositories/pessoa_repository_impl.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../../data/services/pessoa_firestore_impl.dart'; // ← Firestore
import '../../data/services/pessoa_remote_storage_interface.dart';
import '../../domain/facades/pessoa_facade_usecases_impl.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/usecases/pessoa_usecases_impl.dart';
import '../../domain/usecases/pessoa_usecases_interfaces.dart';
import '../../data/repositories/avaliacao_repository_impl.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../data/repositories/usuario_repository_interface.dart';
import '../../data/services/avaliacao_firestore_impl.dart';
import '../../data/services/avaliacao_remote_storage_interface.dart';
import '../../data/services/usuario_firestore_impl.dart';
import '../../data/services/usuario_remote_storage_interface.dart';
import '../../domain/facades/avaliacao_facade_usecases_impl.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/usecases/avaliacao_usecases_impl.dart';
import '../../domain/usecases/avaliacao_usecases_interfaces.dart';
import '../../presentation/controllers/avaliacao_viewmodel.dart';
import '../../domain/facades/ranking_facade_usecases_impl.dart';
import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../../domain/usecases/ranking_usecases_impl.dart';
import '../../domain/usecases/ranking_usecases_interfaces.dart';
import '../../presentation/controllers/ranking_viewmodel.dart';
import '../../data/repositories/vinculo_repository_impl.dart';
import '../../data/repositories/vinculo_repository_interface.dart';
import '../../data/services/vinculo_firestore_impl.dart';
import '../../data/services/vinculo_remote_storage_interface.dart';
import '../../domain/facades/vinculo_facade_usecases_impl.dart';
import '../../domain/facades/vinculo_facade_usecases_interface.dart';
import '../../domain/usecases/vinculo_usecases_impl.dart';
import '../../domain/usecases/vinculo_usecases_interfaces.dart';
import '../../presentation/controllers/vinculo_viewmodel.dart';

final injector = AutoInjector();

void setupDependencyInjection() {
  // Core — Tema (preferência local via SharedPreferences)
  injector.addSingleton<ILocalStorageService>(LocalStorageService.new);
  injector.addSingleton<IPreferenceRepository>(PreferenceRepositoryImpl.new);
  injector.addSingleton<IObterTemaUseCase>(ObterTemaUseCaseImpl.new);
  injector.addSingleton<IAlterarTemaUseCase>(AlterarTemaUseCaseImpl.new);
  injector.addSingleton<ITemaFacadeUseCases>(TemaFacadeUseCasesImpl.new);
  injector.addSingleton<ThemeViewModel>(ThemeViewModel.new);

  // ── Autenticação ──
  injector.addSingleton<IAuthService>(FirebaseAuthService.new);
  injector.addSingleton<IAuthRepository>(AuthRepositoryImpl.new);
  injector.addSingleton<IObservarUsuarioUseCase>(ObservarUsuarioUseCaseImpl.new);
  injector.addSingleton<IEntrarComEmailUseCase>(EntrarComEmailUseCaseImpl.new);
  injector.addSingleton<ICadastrarUsuarioUseCase>(CadastrarUsuarioUseCaseImpl.new);
  injector.addSingleton<IEntrarComGoogleUseCase>(EntrarComGoogleUseCaseImpl.new);
  injector.addSingleton<ISairUseCase>(SairUseCaseImpl.new);
  injector.addSingleton<IAuthFacadeUseCases>(AuthFacadeUseCasesImpl.new);
  injector.addSingleton<AuthViewModel>(AuthViewModel.new);

  // ── Pessoas (Firestore) ──
  injector.addSingleton<IPessoaRemoteStorage>(PessoaFirestoreService.new);
  injector.addSingleton<IPessoaRepository>(PessoaRepositoryImpl.new);
  injector.addSingleton<ICadastrarPessoaUseCase>(CadastrarPessoaUseCaseImpl.new);
  injector.addSingleton<IObterTodasPessoasUseCase>(ObterTodasPessoasUseCaseImpl.new);
  injector.addSingleton<IObterPessoaPorIdUseCase>(ObterPessoaPorIdUseCaseImpl.new);
  injector.addSingleton<IAtualizarPessoaUseCase>(AtualizarPessoaUseCaseImpl.new);
  injector.addSingleton<IDeletarPessoaUseCase>(DeletarPessoaUseCaseImpl.new);
  injector.addSingleton<IPessoaFacadeUseCases>(PessoaFacadeUseCasesImpl.new);
  injector.addSingleton<PessoaViewModel>(PessoaViewModel.new);

  // ── Usuários (perfil + vínculo) e Avaliações (Firestore) ──
  injector.addSingleton<IUsuarioRemoteStorage>(UsuarioFirestoreService.new);
  injector.addSingleton<IUsuarioRepository>(UsuarioRepositoryImpl.new);
  injector.addSingleton<IRegistrarPerfilUsuarioUseCase>(RegistrarPerfilUsuarioUseCaseImpl.new);
  injector.addSingleton<IAvaliacaoRemoteStorage>(AvaliacaoFirestoreService.new);
  injector.addSingleton<IAvaliacaoRepository>(AvaliacaoRepositoryImpl.new);
  injector.addSingleton<IVerificarAutoavaliacaoUseCase>(VerificarAutoavaliacaoUseCaseImpl.new);
  injector.addSingleton<IConsultarAvaliacaoUseCase>(ConsultarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IRegistrarAvaliacaoUseCase>(RegistrarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IAlterarAvaliacaoUseCase>(AlterarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IAvaliacaoFacadeUseCases>(AvaliacaoFacadeUseCasesImpl.new);
  injector.addSingleton<AvaliacaoViewModel>(AvaliacaoViewModel.new);

  // ── Rankings (Firestore) ──
  injector.addSingleton<ICalcularRankingPessoalUseCase>(CalcularRankingPessoalUseCaseImpl.new);
  injector.addSingleton<ICalcularRankingGlobalUseCase>(CalcularRankingGlobalUseCaseImpl.new);
  injector.addSingleton<IRankingFacadeUseCases>(RankingFacadeUseCasesImpl.new);
  injector.addSingleton<RankingViewModel>(RankingViewModel.new);

  // ── Vínculo conta ↔ pessoa (identificação do próprio perfil) ──
  injector.addSingleton<IVinculoRemoteStorage>(VinculoFirestoreService.new);
  injector.addSingleton<IVinculoRepository>(VinculoRepositoryImpl.new);
  injector.addSingleton<IObterVinculoUseCase>(ObterVinculoUseCaseImpl.new);
  injector.addSingleton<IObterPessoasDisponiveisUseCase>(ObterPessoasDisponiveisUseCaseImpl.new);
  injector.addSingleton<IVincularPessoaExistenteUseCase>(VincularPessoaExistenteUseCaseImpl.new);
  injector.addSingleton<ICadastrarPerfilEVincularUseCase>(CadastrarPerfilEVincularUseCaseImpl.new);
  injector.addSingleton<IVinculoFacadeUseCases>(VinculoFacadeUseCasesImpl.new);
  injector.addSingleton<VinculoViewModel>(VinculoViewModel.new);

  injector.commit();
}
