// lib/repositories/professor_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabalho_flutter/enums/sexo_enum.dart';
import 'package:trabalho_flutter/enums/formacao_enum.dart';
import 'package:trabalho_flutter/exceptions/professor_not_found_exception.dart';
import 'package:trabalho_flutter/models/professor_vo.dart';

class ProfessorRepository {
  static final ProfessorRepository _instance = ProfessorRepository._internal();

  ProfessorRepository._internal();

  factory ProfessorRepository() {
    return _instance;
  }

  final Map<String, ProfessorVO> _professores = {};
  static const String _professoresKey = 'professores';

  // Inicializa o repositório carregando os professores do armazenamento local
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final professoresJson = prefs.getString(_professoresKey);
    if (professoresJson != null) {
      final List<dynamic> professoresList = jsonDecode(professoresJson);
      _professores.clear();
      for (var prof in professoresList) {
        final professor = ProfessorVO.fromMap(Map<String, dynamic>.from(prof));
        _professores[professor.id] = professor;
      }
    } else {
      // Carrega os professores padrão se não houver dados salvos
      _professores.addAll({
        '1': ProfessorVO(
          id: '1',
          nomeCompleto: 'Marcel Silva',
          email: 'marcel.silva@email.com',
          dataNascimento: DateTime(2000, 5, 15),
          sexo: SexoEnum.masculino,
          curso: FormacaoEnum.posdoutorado,
          cadastrado: true,
        ),
        '2': ProfessorVO(
          id: '2',
          nomeCompleto: 'Maria Oliveira',
          email: 'maria.oliveira@email.com',
          dataNascimento: DateTime(1999, 8, 22),
          sexo: SexoEnum.feminino,
          curso: FormacaoEnum.mestrado,
          cadastrado: false,
        ),
      });
      await _saveToPrefs();
    }
  }

  // Salva os professores no armazenamento local
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final professoresList = _professores.values.map((prof) => prof.toMap()).toList();
    await prefs.setString(_professoresKey, jsonEncode(professoresList));
  }

  // Salva ou atualiza um professor
  void save(ProfessorVO professor) {
    _professores[professor.id] = professor;
    _saveToPrefs();
  }

  // Busca um professor por ID
  ProfessorVO findById(String id) {
    if (!_professores.containsKey(id)) {
      throw ProfessorNotFoundException(id);
    }
    return _professores[id]!;
  }

  // Busca professores por nome
  List<ProfessorVO> findByName(String valor) {
    final String termo = valor.toLowerCase();
    final List<ProfessorVO> professores = _professores.values
        .where((professor) => professor.nomeCompleto.toLowerCase().contains(termo))
        .toList();

    if (professores.isEmpty) {
      throw ProfessorNotFoundException(valor, isId: false);
    }

    return professores;
  }

  // Retorna todos os professores
  List<ProfessorVO> findAll() {
    return _professores.values.toList();
  }

  // Remove um professor por ID
  void deleteById(String id) {
    if (!_professores.containsKey(id)) {
      throw ProfessorNotFoundException(id);
    }
    _professores.remove(id);
    _saveToPrefs();
  }
}