import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/models/avaliacao_entity.dart';

/// Estado da avaliação do usuário autenticado para a pessoa em foco.
class AvaliacaoStateViewModel {
  final pessoaId = signal<String?>(null);
  final permissao = signal<PermissaoAvaliacao?>(null);
  /// Avaliação já salva (null se o usuário ainda não avaliou a pessoa).
  final avaliacaoAtual = signal<Avaliacao?>(null);
  /// Notas em edição na tela de avaliação.
  final criterios = signal<CriteriosPopularidade>(const CriteriosPopularidade());
  /// Erro de gravação (registrar/alterar avaliação).
  final mensagem = signal<String?>(null);
  /// Erro ao carregar permissão/avaliação existente; impede exibir o formulário.
  final erroCarregamento = signal<String?>(null);
  final isLoading = signal<bool>(false);
  final isSaving = signal<bool>(false);

  late final jaAvaliou = computed<bool>(() => avaliacaoAtual.value != null);
  late final nivelLenda = computed<int>(() => criterios.value.nivelLenda);

  void limparMensagem() => mensagem.value = null;
  void setMensagem(String msg) => mensagem.value = msg;

  void iniciar(String id) {
    pessoaId.value = id;
    permissao.value = null;
    avaliacaoAtual.value = null;
    criterios.value = const CriteriosPopularidade();
    mensagem.value = null;
    erroCarregamento.value = null;
  }

  void setAvaliacao(Avaliacao? a) {
    avaliacaoAtual.value = a;
    criterios.value = a?.criterios ?? const CriteriosPopularidade();
  }
}
