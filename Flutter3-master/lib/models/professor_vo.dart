// lib/models/professor_vo.dart
import 'package:trabalho_flutter/enums/sexo_enum.dart';
import 'package:trabalho_flutter/enums/formacao_enum.dart';
import 'package:uuid/uuid.dart';

class ProfessorVO {
  final String id;
  final String nomeCompleto;
  final String email;
  final DateTime dataNascimento;
  final SexoEnum sexo;
  final FormacaoEnum curso;
  final bool cadastrado;

  static final _uuid = Uuid();

  ProfessorVO({
    required this.nomeCompleto,
    required this.email,
    required this.dataNascimento,
    required this.sexo,
    required this.curso,
    required this.cadastrado,
    String? id,
  }) : id = id ?? _uuid.v4();

  int get idade {
    final now = DateTime.now();
    int idade = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'dataNascimento': dataNascimento.toIso8601String(),
      'sexo': sexo.index,
      'curso': curso.index,
      'cadastrado': cadastrado,
    };
  }

  factory ProfessorVO.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('id') || map['id'] == null) {
      throw FormatException('ID é obrigatório');
    }
    if (!map.containsKey('nomeCompleto') || map['nomeCompleto'] == null) {
      throw FormatException('Nome completo é obrigatório');
    }
    if (!map.containsKey('email') || map['email'] == null) {
      throw FormatException('E-mail é obrigatório');
    }
    if (!map.containsKey('dataNascimento') || map['dataNascimento'] == null) {
      throw FormatException('Data de nascimento é obrigatória');
    }
    if (!map.containsKey('sexo') || map['sexo'] == null) {
      throw FormatException('Sexo é obrigatório');
    }
    if (!map.containsKey('curso') || map['curso'] == null) {
      throw FormatException('Curso é obrigatório');
    }
    if (!map.containsKey('cadastrado') || map['cadastrado'] == null) {
      throw FormatException('Cadastrado é obrigatório');
    }

    return ProfessorVO(
      id: map['id'] as String,
      nomeCompleto: map['nomeCompleto'] as String,
      email: map['email'] as String,
      dataNascimento: DateTime.parse(map['dataNascimento'] as String),
      sexo: SexoEnum.values[map['sexo'] as int],
      curso: FormacaoEnum.values[map['curso'] as int],
      cadastrado: map['cadastrado'] as bool,
    );
  }
}