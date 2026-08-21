import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/patterns/result.dart' show Success;
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/aluno_entity.dart';
import '../../domain/models/aluno_mapper.dart';
import 'aluno_local_storage_interface.dart';

/// Implementação de [IAlunoLocalStorage] usando SQLite via sqflite.
///
/// O banco de dados fica salvo localmente no dispositivo em um arquivo .db.
/// A tabela [_tableName] armazena um aluno por linha, com uma coluna
/// para cada campo — dados cadastrais e os 15 critérios de popularidade.
final class AlunoSqliteService implements IAlunoLocalStorage {
  static const String _dbName    = 'piramid_game.db';
  static const int    _dbVersion = 1;
  static const String _tableName = 'alunos';

  // Instância única do banco (singleton lazy)
  Database? _db;

  // ── Abertura / criação do banco ────────────────────────────────────────────

  /// Retorna o banco aberto, abrindo/criando se ainda não existir.
  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    // getDatabasesPath() retorna o diretório padrão do app para bancos SQLite.
    // join() monta o caminho completo: /data/.../databases/piramid_game.db
    final dbPath = join(await getDatabasesPath(), _dbName);

    return openDatabase(
      dbPath,
      version: _dbVersion,
      // onCreate é chamado apenas na primeira vez que o banco é criado.
      onCreate: (db, version) => db.execute(_createTableSql),
    );
  }

  /// SQL de criação da tabela.
  /// Cada aluno ocupa uma linha; os 15 critérios são colunas INTEGER.
  /// INTEGER NOT NULL DEFAULT 1 garante que nunca fique nulo no banco.
  static const String _createTableSql = '''
    CREATE TABLE $_tableName (
      id             TEXT    PRIMARY KEY,
      nome           TEXT    NOT NULL,
      apelido        TEXT    NOT NULL DEFAULT '',
      curso          TEXT    NOT NULL,
      turmaAno       INTEGER NOT NULL,
      dataNascimento TEXT    NOT NULL,
      createdAt      TEXT    NOT NULL,
      updatedAt      TEXT    NOT NULL,
      resenha              INTEGER NOT NULL DEFAULT 1,
      presencaVip          INTEGER NOT NULL DEFAULT 1,
      aura                 INTEGER NOT NULL DEFAULT 1,
      modoParceiro         INTEGER NOT NULL DEFAULT 1,
      carisma              INTEGER NOT NULL DEFAULT 1,
      humorMilhoes         INTEGER NOT NULL DEFAULT 1,
      energiaGrupo         INTEGER NOT NULL DEFAULT 1,
      criatividadeCaotica  INTEGER NOT NULL DEFAULT 1,
      modoAtleta           INTEGER NOT NULL DEFAULT 1,
      talentopalco         INTEGER NOT NULL DEFAULT 1,
      dripEscolar          INTEGER NOT NULL DEFAULT 1,
      coracaoDorama        INTEGER NOT NULL DEFAULT 1,
      queridinhoProf       INTEGER NOT NULL DEFAULT 1,
      cerebroTurbo         INTEGER NOT NULL DEFAULT 1,
      caosControlado       INTEGER NOT NULL DEFAULT 1
    )
  ''';

  // ── CRUD ──────────────────────────────────────────────────────────────────

  @override
  Future<AlunoResult> salvarAluno(Aluno aluno) async {
    try {
      final db = await _database;
      // insert com conflictAlgorithm.replace substitui o registro
      // caso já exista um com o mesmo id (PRIMARY KEY).
      await db.insert(
        _tableName,
        AlunoMapper.toMap(aluno),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(aluno);
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao salvar aluno no SQLite: $e'));
    }
  }

  @override
  Future<ListAlunoResult> obterTodosAlunos() async {
    try {
      final db = await _database;
      // query sem WHERE retorna todas as linhas da tabela.
      final rows = await db.query(_tableName);
      final alunos = rows.map(AlunoMapper.fromMap).toList();
      return Success(alunos);
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao obter alunos do SQLite: $e'));
    }
  }

  @override
  Future<AlunoResult> obterAlunoPorId(String id) async {
    try {
      final db = await _database;
      // WHERE id = ? — o ? é substituído pelo valor em [whereArgs],
      // evitando SQL injection.
      final rows = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) {
        return r.Error(NotFoundFailure('Aluno com id "$id" não encontrado.'));
      }
      return Success(AlunoMapper.fromMap(rows.first));
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao buscar aluno por id: $e'));
    }
  }

  @override
  Future<AlunoResult> atualizarAluno(Aluno aluno) async {
    try {
      final db = await _database;
      // update modifica apenas as linhas onde id = ?
      final rowsAffected = await db.update(
        _tableName,
        AlunoMapper.toMap(aluno),
        where: 'id = ?',
        whereArgs: [aluno.id],
      );
      if (rowsAffected == 0) {
        return r.Error(NotFoundFailure('Aluno não encontrado para atualizar.'));
      }
      return Success(aluno);
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao atualizar aluno no SQLite: $e'));
    }
  }

  @override
  Future<VoidResult> deletarAluno(String id) async {
    try {
      final db = await _database;
      // delete remove a linha onde id = ?
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return r.Error(ApiLocalFailure('Erro ao deletar aluno no SQLite: $e'));
    }
  }

  /// Fecha o banco de dados. Chamado quando o app é encerrado.
  Future<void> fechar() async => _db?.close();
}
