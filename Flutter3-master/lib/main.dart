// Importando as ferramentas do Flutter para criar a interface do aplicativo
import 'package:flutter/material.dart';

// Importando os enums para sexo (masculino, feminino) e formação (mestrado, doutorado, etc.)
import 'package:trabalho_flutter/enums/sexo_enum.dart';
import 'package:trabalho_flutter/enums/formacao_enum.dart';

// Importando o modelo ProfessorVO, que define a estrutura de dados de um professor
import 'package:trabalho_flutter/models/professor_vo.dart';

// Importando o repositório para gerenciar o armazenamento e manipulação dos professores
import 'package:trabalho_flutter/repositories/professor_repository.dart';

// Função principal que inicializa o aplicativo
void main() async {
  // Garante que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o repositório antes de rodar o aplicativo
  await ProfessorRepository().init();
  // Inicia o aplicativo com a tela principal MainApp
  runApp(const MainApp());
}

// Classe que define o aplicativo principal
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove a faixa de debug exibida no canto superior direito
      debugShowCheckedModeBanner: false,
      // Define o tema do aplicativo com a cor primária vermelha
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: false),
      // Define a HomePage como a tela inicial
      home: const HomePage(),
    );
  }
}

// Tela inicial do aplicativo, exibida ao abrir o app
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior com título e botões de ação
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true, // Centraliza o título
        actions: [
          // Botão para acessar a lista de professores
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Ver Lista de Professores',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessorListPage(),
                ),
              );
            },
          ),
          // Botão para abrir a tela de cadastro de um novo professor
          IconButton(
            icon: const Icon(Icons.add_outlined),
            tooltip: 'Cadastrar Novo Professor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessorFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      // Corpo da tela com imagem de fundo e texto de boas-vindas
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/lousa.jpg',
            ), // Imagem de fundo (lousa)
            fit: BoxFit.cover, // Ajusta a imagem para cobrir toda a tela
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bem-vindo, Professor!\nClique no botão "+" para cadastrar um novo professor\nou no botão de lista para ver os professores cadastrados',
              style: TextStyle(
                color: Colors.white, // Texto branco para contraste com o fundo
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Tela para cadastrar ou editar um professor
class ProfessorFormPage extends StatefulWidget {
  final String? professorId; // ID do professor, usado para edição

  const ProfessorFormPage({super.key, this.professorId});

  @override
  State<ProfessorFormPage> createState() => _ProfessorFormPageState();
}

// Estado da tela de formulário, onde gerenciamos os dados dinâmicos
class _ProfessorFormPageState extends State<ProfessorFormPage> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Instância do repositório para salvar e buscar professores
  final _repository = ProfessorRepository();

  // Controladores para os campos de texto
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cpfController =
      TextEditingController(); // Não usado, mantido por compatibilidade

  // Variáveis para armazenar as seleções de sexo, formação e status de cadastro
  SexoEnum? _sexo;
  FormacaoEnum? _nivelSuperior;
  bool _cadastrado = false;
  ProfessorVO? _professor;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Se houver um ID, carrega os dados do professor para edição
    if (widget.professorId != null) {
      _carregarProfessor();
    }
  }

  // Função para carregar os dados de um professor existente
  void _carregarProfessor() {
    try {
      _professor = _repository.findById(widget.professorId!);
      _nomeController.text = _professor!.nomeCompleto;
      _emailController.text = _professor!.email;
      _selectedDate = _professor!.dataNascimento;
      _dataNascimentoController.text =
          '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
      _sexo = _professor!.sexo;
      _nivelSuperior = _professor!.curso;
      _cadastrado = _professor!.cadastrado;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar professor: ${e.toString()}')),
      );
    }
  }

  // Função para abrir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataNascimentoController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior com título dinâmico (novo ou edição)
      appBar: AppBar(
        title: Text(_professor == null ? 'Novo Professor' : 'Editar Professor'),
        elevation: 4,
        backgroundColor: Colors.red[700],
        centerTitle: true,
      ),
      // Corpo da tela com fundo gradiente e formulário
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[200]!, Colors.white],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título do formulário
                      const Text(
                        'Cadastro de Professor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo para o nome completo
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome Completo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o nome completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Campo para o e-mail
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o e-mail';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Informe um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Campo para a data de nascimento com showDatePicker
                      TextFormField(
                        controller: _dataNascimentoController,
                        decoration: InputDecoration(
                          labelText: 'Data de Nascimento (DD/MM/YYYY)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true, // Impede edição direta
                        onTap:
                            () =>
                                _selectDate(context), // Abre o seletor de data
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione a data de nascimento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Campo para selecionar o sexo com RadioListTile
                      const Text(
                        'Sexo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RadioListTile<SexoEnum>(
                        title: const Text('Masculino'),
                        value: SexoEnum.masculino,
                        groupValue: _sexo,
                        onChanged: (SexoEnum? value) {
                          setState(() {
                            _sexo = value;
                          });
                        },
                      ),
                      RadioListTile<SexoEnum>(
                        title: const Text('Feminino'),
                        value: SexoEnum.feminino,
                        groupValue: _sexo,
                        onChanged: (SexoEnum? value) {
                          setState(() {
                            _sexo = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Menu suspenso para selecionar a formação
                      DropdownButtonFormField<FormacaoEnum>(
                        value: _nivelSuperior,
                        decoration: InputDecoration(
                          labelText: 'Formação',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.school),
                        ),
                        items:
                            FormacaoEnum.values.map((FormacaoEnum formacao) {
                              return DropdownMenuItem<FormacaoEnum>(
                                value: formacao,
                                child: Text(formacao.descricao),
                              );
                            }).toList(),
                        onChanged: (FormacaoEnum? newValue) {
                          setState(() {
                            _nivelSuperior = newValue;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Selecione a formação' : null,
                      ),
                      const SizedBox(height: 16),
                      // Interruptor para marcar se o professor está cadastrado
                      SwitchListTile(
                        title: const Text('Cadastrado'),
                        value: _cadastrado,
                        onChanged: (bool value) {
                          setState(() {
                            _cadastrado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Botão para salvar o professor
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              _sexo != null) {
                            // Converte a data de nascimento para o formato DateTime
                            final professor = ProfessorVO(
                              id: _professor?.id, // Mantém o ID se for edição
                              nomeCompleto: _nomeController.text,
                              email: _emailController.text,
                              dataNascimento: _selectedDate!,
                              sexo: _sexo!,
                              curso: _nivelSuperior!,
                              cadastrado: _cadastrado,
                            );

                            try {
                              // Salva o professor no repositório
                              _repository.save(professor);

                              // Exibe uma mensagem de sucesso
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Professor salvo com sucesso!'),
                                ),
                              );

                              // Navega para a tela de lista após salvar
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ProfessorListPage(),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erro ao salvar: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          } else if (_sexo == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor, selecione o sexo'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.red[700],
                        ),
                        child: const Text(
                          'Salvar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Libera os controladores para evitar vazamento de memória
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _dataNascimentoController.dispose();
    _cpfController.dispose();
    super.dispose();
  }
}

class ProfessorListPage extends StatefulWidget {
  const ProfessorListPage({super.key});

  @override
  State<ProfessorListPage> createState() => _ProfessorListPageState();
}

class _ProfessorListPageState extends State<ProfessorListPage> {
  final _repository = ProfessorRepository();
  String _searchQuery = '';
  final _searchController = TextEditingController();

  bool isDark = false; // Estado para controle do tema

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: Colors.red,
    );

    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Professores'),
          centerTitle: true,
          elevation: 4,
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isDark
                      ? [Colors.grey[900]!, Colors.black]
                      : [Colors.grey[200]!, Colors.white],
            ),
          ),
          child: Column(
            children: [
              // Barra de busca com botão de troca de tema
              SearchBar(
                controller: _searchController,
                hintText: 'Buscar por nome...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                leading: const Icon(Icons.search),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                trailing: [
                  IconButton(
                    tooltip: 'Alterar tema',
                    isSelected: isDark,
                    icon: const Icon(Icons.wb_sunny_outlined),
                    selectedIcon: const Icon(Icons.brightness_2_outlined),
                    onPressed: () {
                      setState(() {
                        isDark = !isDark;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<void>(
                  future: _repository.init(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar dados: ${snapshot.error}',
                        ),
                      );
                    }
                    return Builder(
                      builder: (context) {
                        try {
                          final professores =
                              _searchQuery.isEmpty
                                  ? _repository.findAll()
                                  : _repository.findByName(_searchQuery);
                          if (professores.isEmpty) {
                            return const Center(
                              child: Text('Nenhum professor encontrado'),
                            );
                          }
                          return ListView.builder(
                            itemCount: professores.length,
                            itemBuilder: (context, index) {
                              final professor = professores[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    professor.nomeCompleto,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'E-mail: ${professor.email}\n'
                                    'Data de Nascimento: ${professor.dataNascimento.day.toString().padLeft(2, '0')}/'
                                    '${professor.dataNascimento.month.toString().padLeft(2, '0')}/'
                                    '${professor.dataNascimento.year}\n'
                                    'Idade: ${professor.idade}\n'
                                    'Sexo: ${professor.sexo.descricao}\n'
                                    'Formação: ${professor.curso.descricao}\n'
                                    'Cadastrado: ${professor.cadastrado ? 'Sim' : 'Não'}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProfessorFormPage(
                                                        professorId:
                                                            professor.id,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Confirmar Exclusão',
                                                  ),
                                                  content: Text(
                                                    'Deseja excluir ${professor.nomeCompleto}?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        try {
                                                          _repository
                                                              .deleteById(
                                                                professor.id,
                                                              );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                '${professor.nomeCompleto} excluído com sucesso!',
                                                              ),
                                                            ),
                                                          );
                                                          setState(() {});
                                                        } catch (e) {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Erro ao excluir: ${e.toString()}',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: const Text(
                                                        'Excluir',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } catch (e) {
                          return Center(
                            child: Text(
                              'Erro ao carregar a lista: ${e.toString()}',
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfessorFormPage(),
              ),
            );
          },
          backgroundColor: Colors.red[700],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
