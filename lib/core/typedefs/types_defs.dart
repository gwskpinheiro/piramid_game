import 'package:flutter/material.dart';
import '../failure/failure.dart';
import '../../domain/models/aluno_entity.dart';
import '../patterns/result.dart';

typedef VoidResult = Result<void, Failure>;
typedef AlunoResult = Result<Aluno, Failure>;
typedef ListAlunoResult = Result<List<Aluno>, Failure>;

typedef NoParams = ();
typedef AlunoIdParams = ({String id});
typedef AlunoParams = ({Aluno aluno});

typedef FormFieldControl = ({
  GlobalKey<FormFieldState> key,
  FocusNode focus,
  TextEditingController controller,
});
