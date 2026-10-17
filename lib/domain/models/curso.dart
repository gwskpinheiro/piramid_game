enum Curso {
  info, mec, mamb, prod, tads, tga;

  String get displayName {
    switch (this) {
      case Curso.info: return 'INFO';
      case Curso.mec:  return 'MEC';
      case Curso.mamb: return 'MAMB';
      case Curso.prod: return 'PROD';
      case Curso.tads: return 'TADS';
      case Curso.tga:  return 'TGA';
    }
  }
}
