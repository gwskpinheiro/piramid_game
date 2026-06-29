import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' hide Error;
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno_entity.dart';
import '../../domain/models/aluno_mapper.dart';
import 'aluno_local_storage_interface.dart';

final class AlunoSharedPreferencesService implements IAlunoLocalStorage {
  static const String _storageKey = 'piramid_alunos';

  @override
  Future<ListAlunoResult> obterTodosAlunos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return const Success([]);
      final decoded = jsonDecode(raw) as List<dynamic>;
      final alunos = decoded
          .map((e) => AlunoMapper.fromMap(e as Map<String, dynamic>))
          .toList();
      return Success(alunos);
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao obter alunos: $e'));
    }
  }

  @override
  Future<AlunoResult> obterAlunoPorId(String id) async {
    try {
      final result = await obterTodosAlunos();
      return result.fold(
        onSuccess: (alunos) {
          try {
            final aluno = alunos.firstWhere((a) => a.id == id);
            return Success(aluno);
          } catch (_) {
            return r.Error(NotFoundFailure('Aluno com id "$id" não encontrado.'));
          }
        },
        onFailure: (f) => r.Error(f),
      );
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao obter aluno por id: $e'));
    }
  }

  @override
  Future<AlunoResult> salvarAluno(Aluno aluno) async {
    try {
      final listResult = await obterTodosAlunos();
      return await listResult.fold(
        onSuccess: (alunos) async {
          final updated = [...alunos, aluno];
          await _persistir(updated);
          return Success(aluno);
        },
        onFailure: (f) async => r.Error(f),
      );
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao salvar aluno: $e'));
    }
  }

  @override
  Future<AlunoResult> atualizarAluno(Aluno aluno) async {
    try {
      final listResult = await obterTodosAlunos();
      return await listResult.fold(
        onSuccess: (alunos) async {
          final index = alunos.indexWhere((a) => a.id == aluno.id);
          if (index == -1) {
            return r.Error(NotFoundFailure('Aluno não encontrado para atualizar.'));
          }
          final updated = List<Aluno>.from(alunos)..[index] = aluno;
          await _persistir(updated);
          return Success(aluno);
        },
        onFailure: (f) async => r.Error(f),
      );
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao atualizar aluno: $e'));
    }
  }

  @override
  Future<VoidResult> deletarAluno(String id) async {
    try {
      final listResult = await obterTodosAlunos();
      return await listResult.fold(
        onSuccess: (alunos) async {
          final updated = alunos.where((a) => a.id != id).toList();
          await _persistir(updated);
          return const Success(null);
        },
        onFailure: (f) async => r.Error(f),
      );
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao deletar aluno: $e'));
    }
  }

  Future<void> _persistir(List<Aluno> alunos) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(alunos.map(AlunoMapper.toMap).toList());
    await prefs.setString(_storageKey, json);
  }
}
