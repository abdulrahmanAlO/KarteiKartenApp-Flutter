import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Pages/InstructionPage.dart';
import 'package:flutter_application_final_project/Pages/ModulePage.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:flutter_application_final_project/theme/app_theme.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SupabaseClient _client = Supabase.instance.client;

  // Registration fields - stored globally for access from signup
  static final Map<String, String> _additionalSignupData = {};
  String Rolle = "";
  String? selectedRole;
  String? selectedUniversity;
  String? selectedProgram;
  List<Map<String, dynamic>> universities = [];
  List<Map<String, dynamic>> programs = [];

  @override
  void initState() {
    super.initState();
    loadUniversities();
  }

  Future<void> loadUniversities() async {
    try {
      final data = await _client.from('universities').select();
      setState(() => universities = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      print('Fehler beim Laden der Universitäten: $e');
    }
  }

  Future<void> loadPrograms(String universityId) async {
    try {
      final data = await _client
          .from('programs')
          .select()
          .eq('university_id', universityId);
      setState(() {
        programs = List<Map<String, dynamic>>.from(data);
        selectedProgram = null;
      });
    } catch (e) {
      print('Fehler beim Laden der Studiengänge: $e');
    }
  }

Future<String?> _signUpUser(SignupData data) async {
  try {
      // Create the auth user first
    await _client.auth.signUp(
      email: data.name!,
      password: data.password!,
    );
      
      // Wait a bit for user to be available
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get additional data from the stored map
      final role = _additionalSignupData['role'];
      final name = _additionalSignupData['name'];
      final program = _additionalSignupData['program'];
      
      if (role != null && role.isNotEmpty && name != null && program != null) {
        final user = _client.auth.currentUser;
        if (user != null) {
          await _client.from(role).insert({
            'name': name.trim(),
            'UID': user.id,
            'email': user.email,
            'Programm_id': int.parse(program),
          });
        }
      }
      
      // Clear stored data
      _additionalSignupData.clear();
      
    return null;
  } on AuthException catch (e) {
      _additionalSignupData.clear();
    return e.message;
    } catch (e) {
      _additionalSignupData.clear();
      return 'Registrierung fehlgeschlagen: ${e.toString()}';
  }
}

  Future<String?> _authUser(LoginData data) async {
    try {
      await _client.auth.signInWithPassword(
        email: data.name,
        password: data.password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Login fehlgeschlagen';
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return null;
    } catch (_) {
      return 'E-Mail nicht gefunden';
    }
  }

  Widget _buildAppTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 1).withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AACARDS',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Learning Made Simple',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            FlutterLogin(
              title: '',
              theme: LoginTheme(
                primaryColor: AppTheme.primaryColor,
                accentColor: AppTheme.secondaryColor,
                errorColor: AppTheme.errorColor,
                cardTheme: CardTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
              ),
              onLogin: _authUser,
              onSignup: _extendedSignup,
              onRecoverPassword: _recoverPassword,
            onSubmitAnimationCompleted: () async {
        // Load user data to determine role
        final currentUser = _client.auth.currentUser;
        if (currentUser != null) {
          final userData = await UserServices.loadPerson(currentUser);
          final isLecturer = userData?['IsLecturer'] == true;
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => InstructionPage(isLecturer: isLecturer),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const ModulePage(title: 'Willkommen'),
            ),
          );
        }
      },
          ),
          // Custom Logo/Title positioned at the top
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _buildAppTitle(),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Future<String?> _extendedSignup(SignupData data) async {
    // Extract name from additionalSignupData if available
    final name = data.additionalSignupData?['name'] ?? '';
    
    // Show dialog for dropdown fields (Role, University, Program)
    // Since FlutterLogin doesn't support dropdowns, we need a dialog
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AdditionalFieldsDialog(
        universities: universities,
        programs: programs,
        loadPrograms: loadPrograms,
        initialName: name, // Pass name if already filled
      ),
    );

    if (result == null) {
      return 'Registrierung abgebrochen';
    }

    // Store additional data (include name from either source)
    _additionalSignupData.clear();
    _additionalSignupData.addAll({
      'name': result['name'] ?? name,
      'role': result['role'] ?? '',
      'university': result['university'] ?? '',
      'program': result['program'] ?? '',
    });

    // Validate that all required fields are present
    if ((_additionalSignupData['name'] ?? '').isEmpty ||
        (_additionalSignupData['role'] ?? '').isEmpty ||
        (_additionalSignupData['program'] ?? '').isEmpty) {
      return 'Bitte füllen Sie alle Felder aus';
    }

    // Now proceed with the actual signup
    return await _signUpUser(data);
  }
}

// Dialog that matches FlutterLogin design style
class _AdditionalFieldsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> universities;
  final List<Map<String, dynamic>> programs;
  final Function(String) loadPrograms;
  final String initialName;

  const _AdditionalFieldsDialog({
    required this.universities,
    required this.programs,
    required this.loadPrograms,
    this.initialName = '',
  });

  @override
  State<_AdditionalFieldsDialog> createState() => _AdditionalFieldsDialogState();
}

class _AdditionalFieldsDialogState extends State<_AdditionalFieldsDialog> {
  final _nameController = TextEditingController();
  String? selectedRole;
  String? selectedUniversity;
  String? selectedProgram;
  List<Map<String, dynamic>> localPrograms = [];

  @override
  void initState() {
    super.initState();
    localPrograms = List.from(widget.programs);
    if (widget.initialName.isNotEmpty) {
      _nameController.text = widget.initialName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updatePrograms(List<Map<String, dynamic>> newPrograms) {
    setState(() {
      localPrograms = List.from(newPrograms);
      if (!localPrograms.any((p) => p['id'].toString() == selectedProgram)) {
        selectedProgram = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'additional Informations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'select Rolle',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.work),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Student', child: Text('Student')),
                        DropdownMenuItem(value: 'Lecturer', child: Text('Lecturer')),
                      ],
                      onChanged: (value) => setState(() => selectedRole = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedUniversity,
                      decoration: InputDecoration(
                        labelText: 'select University',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.school),
                      ),
                      items: widget.universities.map<DropdownMenuItem<String>>((u) {
                        return DropdownMenuItem<String>(
                          value: u['id'].toString(),
                          child: Text(u['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedUniversity = value;
                          selectedProgram = null;
                        });
                        if (value != null) {
                          await widget.loadPrograms(value);
                          // Get updated programs from parent
                          final updatedPrograms = await Supabase.instance.client
                              .from('programs')
                              .select()
                              .eq('university_id', value);
                          _updatePrograms(List<Map<String, dynamic>>.from(updatedPrograms));
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProgram,
                      decoration: InputDecoration(
                        labelText: 'select Program',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.menu_book),
                      ),
                      items: localPrograms.map<DropdownMenuItem<String>>((p) {
                        return DropdownMenuItem<String>(
                          value: p['id'].toString(),
                          child: Text(p['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedProgram = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    selectedRole != null &&
                    selectedUniversity != null &&
                    selectedProgram != null) {
                  Navigator.of(context).pop({
                    'name': _nameController.text,
                    'role': selectedRole!,
                    'university': selectedUniversity!,
                    'program': selectedProgram!,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('next'),
            ),
          ],
        ),
      ),
    );
  }
}

