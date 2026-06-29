import 'package:flutter/material.dart';
import '../failure/failure.dart';
import '../../domain/models/aluno_entity.dart';
import '../patterns/result.dart';

// Resultados tipados
typedef VoidResult = Result<void, Failure>;
typedef AlunoResult = Result<Aluno, Failure>;
typedef ListAlunoResult = Result<List<Aluno>, Failure>;

// Parâmetros para use cases
typedef NoParams = ();
typedef AlunoIdParams = ({String id});
typedef AlunoParams = ({Aluno aluno});

// Parâmetros de UI
typedef FormFieldControl = ({
  GlobalKey<FormFieldState> key,
  FocusNode focus,
  TextEditingController controller,
});
