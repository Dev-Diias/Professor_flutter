
class ProfessorNotFoundException implements Exception {
  // valor = pode ser RA ou Nome
  final String idOuValor;
  final bool isId;

  const ProfessorNotFoundException(this.idOuValor, {this.isId = true});

  @override
  String toString() {
    return isId
        ? 'Professor com ID [$idOuValor] não localizado'
        : 'Professor com RA ou Nome [$idOuValor] não localizado';
  }
}
