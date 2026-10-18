# PiramidGame IFPR-Pgua

Ranking de Popularidade dos Alunos do IFPR – Campus Paranaguá, desenvolvido em
Flutter para a disciplina de Dispositivos Móveis.

Usuários autenticados cadastram pessoas, avaliam cada uma em 15 critérios de
popularidade (1 a 5 estrelas, Nível Lenda de 15 a 75 pontos) e acompanham o
**Ranking Pessoal** (somente as próprias avaliações) e o **Ranking Global**
(média das avaliações de todos os usuários). Ninguém pode avaliar a si próprio.

## Tecnologias

- Flutter (Android e Web)
- Firebase Authentication (e-mail/senha e Google) e Cloud Firestore
- SharedPreferences (preferência de tema claro/escuro)
- go_router, Flutter Signals
- MVVM, Command, Result, Arquitetura Limpa e SOLID
  (services → repositories → use cases → facade → viewmodel → UI)

## Como executar

Os arquivos de configuração do Firebase não são versionados. Antes de executar,
gere-os para o seu projeto Firebase:

```bash
flutterfire configure   # gera lib/firebase_options.dart e android/app/google-services.json
flutter pub get
flutter run -d chrome   # ou: flutter run (Android)
```

As regras de segurança do Firestore estão em `firestore.rules`.

## Testes

```bash
flutter test
flutter analyze
```
