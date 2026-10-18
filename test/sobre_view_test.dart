import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:piramid_game/presentation/views/sobre_view.dart';

/// Coleta todo o texto visível da tela (rolando até o fim).
Future<String> _textoDaTela(WidgetTester tester) async {
  final textos = <String>{};
  void coletar() {
    for (final e in find.byType(Text).evaluate()) {
      final t = e.widget as Text;
      textos.add(t.data ?? t.textSpan?.toPlainText() ?? '');
    }
  }

  coletar();
  for (var i = 0; i < 30; i++) {
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    coletar();
  }
  return textos.join('\n');
}

void main() {
  testWidgets('Sobre o App cobre o capítulo 20 e não cita SQLite', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SobreView()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final texto = await _textoDaTela(tester);

    expect(texto, isNot(contains('SQLite')));
    expect(texto, isNot(contains('armazenados localmente')));
    for (final esperado in [
      'Objetivo do App',
      'IFPR – Campus Paranaguá',
      '15. Caos Controlado',
      'de 1 a 5 estrelas',
      'Nível Lenda',
      '15 pontos',
      '75 pontos',
      'Ranking Pessoal',
      'Ranking Global',
      'média das avaliações recebidas',
      'Firebase Authentication',
      'Cloud Firestore',
      'SharedPreferences',
      'avaliar a si próprio',
      'vinculado a uma única conta',
      'Tema Claro e Escuro',
    ]) {
      expect(texto, contains(esperado), reason: 'faltou: $esperado');
    }
  });
}
