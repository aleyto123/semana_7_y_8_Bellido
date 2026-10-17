import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const morado = Color(0xFF7139BA);
late final Datos datos;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  datos = Datos(await SharedPreferences.getInstance());
  runApp(const MyApp());
}

// EXTRA: ChangeNotifier comunica cambios a las pantallas.
// JSON permite guardar listas y mapas como texto.
class Datos extends ChangeNotifier {
  final SharedPreferences prefs;
  bool sesion = false;
  late List<Map<String, dynamic>> alumnos;
  late Map<String, dynamic> perfil;

  Datos(this.prefs) {
    final listaGuardada = prefs.getString('alumnos');
    alumnos = listaGuardada == null
        ? [
            {'id': '1', 'nombre': 'Ana', 'apellido': 'Torres', 'nota': 18.0},
            {'id': '2', 'nombre': 'Luis', 'apellido': 'García', 'nota': 12.0},
            {'id': '3', 'nombre': 'María', 'apellido': 'López', 'nota': 9.0},
            {'id': '4', 'nombre': 'Carlos', 'apellido': 'Ruiz', 'nota': 15.0},
          ]
        : (jsonDecode(listaGuardada) as List)
              .map((a) => Map<String, dynamic>.from(a as Map))
              .toList();

    final perfilGuardado = prefs.getString('perfil');
    perfil = perfilGuardado == null
        ? {
            'nombre': 'María González',
            'email': 'maria.gonzalez@correo.com',
            'telefono': '912345678',
            'rol': 'Docente',
            'avatar': '',
          }
        : Map<String, dynamic>.from(jsonDecode(perfilGuardado) as Map);
  }

  Future<void> guardarAlumno(Map<String, dynamic> alumno) async {
    final nuevaLista = alumnos
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
    final indice = nuevaLista.indexWhere((a) => a['id'] == alumno['id']);
    if (indice == -1) {
      nuevaLista.add(alumno);
    } else {
      nuevaLista[indice] = alumno;
    }
    if (!await prefs.setString('alumnos', jsonEncode(nuevaLista))) {
      throw Exception('No se pudo guardar');
    }
    alumnos = nuevaLista;
    notifyListeners();
  }

  Future<void> eliminar(String id) async {
    final nuevaLista = alumnos.where((a) => a['id'] != id).toList();
    if (!await prefs.setString('alumnos', jsonEncode(nuevaLista))) {
      throw Exception('No se pudo eliminar');
    }
    alumnos = nuevaLista;
    notifyListeners();
  }

  Future<void> guardarPerfil(Map<String, dynamic> nuevoPerfil) async {
    if (!await prefs.setString('perfil', jsonEncode(nuevoPerfil))) {
      throw Exception('No se pudo guardar el perfil');
    }
    perfil = nuevoPerfil;
    notifyListeners();
  }
}

void aviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
}

String? obligatorio(String? valor) =>
    valor == null || valor.trim().isEmpty ? 'Campo obligatorio' : null;

bool correoValido(String valor) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valor.trim());

String notaTexto(num nota) => nota == nota.roundToDouble()
    ? nota.toInt().toString().padLeft(2, '0')
    : nota.toString();

Widget contenido(Widget hijo) => Align(
  alignment: Alignment.topCenter,
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560),
    child: hijo,
  ),
);

void cerrarSesion(BuildContext context) {
  datos.sesion = false;
  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sección A',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: morado),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: morado,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: morado,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Rutas con control de sesión local para la demostración.
      onGenerateRoute: (settings) {
        Widget pantalla;
        if (settings.name == '/' || !datos.sesion) {
          pantalla = const LoginPage();
        } else {
          switch (settings.name) {
            case '/menu':
              pantalla = const MenuPage();
              break;
            case '/alumnos':
              pantalla = const AlumnosPage();
              break;
            case '/registro':
              pantalla = RegistroPage(
                alumno: settings.arguments as Map<String, dynamic>?,
              );
              break;
            case '/perfil':
              pantalla = const PerfilPage();
              break;
            default:
              pantalla = const MenuPage();
          }
        }
        return MaterialPageRoute(settings: settings, builder: (_) => pantalla);
      },
    );
  }
}

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final opciones = <Map<String, dynamic>>[
      {
        'texto': 'Registrar Alumnos',
        'icono': Icons.person_add,
        'ruta': '/registro',
      },
      {'texto': 'Listar Alumnos', 'icono': Icons.list_alt, 'ruta': '/alumnos'},
      {'texto': 'Perfil', 'icono': Icons.person, 'ruta': '/perfil'},
    ];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: morado),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Sección A',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
            ),
          ),
          ...opciones.map(
            (opcion) => ListTile(
              leading: Icon(opcion['icono'] as IconData, color: morado),
              title: Text(opcion['texto'] as String),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, opcion['ruta'] as String);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => cerrarSesion(context),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formulario = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool ocultar = true;
  bool procesando = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> ingresar() async {
    if (procesando || !formulario.currentState!.validate()) return;
    setState(() => procesando = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Autenticación de demostración, sin servidor.
    if (email.text.trim().toLowerCase() == 'maria.gonzalez@correo.com' &&
        password.text == '123456') {
      datos.sesion = true;
      Navigator.pushNamedAndRemoveUntil(context, '/menu', (_) => false);
    } else {
      setState(() => procesando = false);
      aviso(context, 'Correo o contraseña incorrectos.');
    }
  }

  Future<void> recuperar() async {
    final controlador = TextEditingController(text: email.text);
    final clave = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Form(
          key: clave,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta versión es una demostración local. '
                'No envía correos de recuperación.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controlador,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    correoValido(v ?? '') ? null : 'Ingresa un correo válido',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              if (!clave.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              aviso(context, 'Cuenta demo: maria.gonzalez@correo.com / 123456');
            },
            child: const Text('Ver acceso demo'),
          ),
        ],
      ),
    );
    controlador.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formulario,
                child: Column(
                  children: [
                    const Icon(Icons.school, color: morado, size: 88),
                    const SizedBox(height: 24),
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa tus credenciales para continuar',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) =>
                          correoValido(v ?? '') ? null : 'Email no válido',
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: password,
                      obscureText: ocultar,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => ocultar = !ocultar),
                          icon: Icon(
                            ocultar
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: obligatorio,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: procesando ? null : ingresar,
                      child: procesando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('LOGIN'),
                    ),
                    TextButton(
                      onPressed: recuperar,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final opciones = <Map<String, dynamic>>[
      {
        'texto': 'Registrar Alumnos',
        'icono': Icons.person_add_outlined,
        'ruta': '/registro',
      },
      {'texto': 'Listar Alumnos', 'icono': Icons.list_alt, 'ruta': '/alumnos'},
      {'texto': 'Perfil', 'icono': Icons.person_outline, 'ruta': '/perfil'},
      {'texto': 'Logout', 'icono': Icons.logout, 'ruta': '/'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Menú')),
      drawer: const MenuLateral(),
      body: contenido(
        ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: opciones.length,
          itemBuilder: (context, index) {
            final opcion = opciones[index];
            final salir = index == 3;
            return Card(
              elevation: 0,
              color: index == 0
                  ? const Color(0xFFF0E8FA)
                  : const Color(0xFFFAF9FC),
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  opcion['icono'] as IconData,
                  color: salir ? Colors.red : morado,
                ),
                title: Text(
                  opcion['texto'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: salir ? Colors.red : null,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (salir) {
                    cerrarSesion(context);
                  } else {
                    Navigator.pushNamed(context, opcion['ruta'] as String);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class AlumnosPage extends StatefulWidget {
  const AlumnosPage({super.key});

  @override
  State<AlumnosPage> createState() => _AlumnosPageState();
}

class _AlumnosPageState extends State<AlumnosPage> {
  String busqueda = '';

  Future<void> eliminar(Map<String, dynamic> alumno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar alumno'),
        content: Text('¿Eliminar a ${alumno['nombre']} ${alumno['apellido']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await datos.eliminar(alumno['id'] as String);
      if (mounted) aviso(context, 'Alumno eliminado.');
    } catch (_) {
      if (mounted) aviso(context, 'No se pudo eliminar. Intenta nuevamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumnos'),
        actions: [
          IconButton(
            tooltip: 'Registrar alumno',
            onPressed: () => Navigator.pushNamed(context, '/registro'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MenuLateral(),
      body: contenido(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar alumno...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (valor) => setState(() => busqueda = valor),
              ),
            ),
            Expanded(
              // EXTRA: reconstruye el listado cuando cambian los datos.
              child: AnimatedBuilder(
                animation: datos,
                builder: (context, _) {
                  final visibles = datos.alumnos
                      .where(
                        (a) => '${a['nombre']} ${a['apellido']}'
                            .toLowerCase()
                            .contains(busqueda.trim().toLowerCase()),
                      )
                      .toList();
                  if (visibles.isEmpty) {
                    return Center(
                      child: Text(
                        datos.alumnos.isEmpty
                            ? 'No hay alumnos registrados'
                            : 'No se encontraron alumnos',
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: visibles.length,
                    itemBuilder: (context, index) {
                      final alumno = visibles[index];
                      final nota = alumno['nota'] as num;
                      final aprobado = nota >= 11;
                      final color = aprobado ? Colors.green : Colors.red;
                      return Card(
                        elevation: 0,
                        color: const Color(0xFFFAF9FC),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFF0E8FA),
                            child: Icon(Icons.school, color: morado),
                          ),
                          title: Text(
                            '${alumno['nombre']} ${alumno['apellido']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nota: ${notaTexto(nota)}'),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  aprobado ? 'Aprobado' : 'Desaprobado',
                                  style: TextStyle(color: color, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (accion) {
                              if (accion == 'editar') {
                                Navigator.pushNamed(
                                  context,
                                  '/registro',
                                  arguments: alumno,
                                );
                              } else {
                                eliminar(alumno);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'editar',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'eliminar',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistroPage extends StatefulWidget {
  final Map<String, dynamic>? alumno;
  const RegistroPage({super.key, this.alumno});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final formulario = GlobalKey<FormState>();
  late final TextEditingController nombre;
  late final TextEditingController apellido;
  late final TextEditingController nota;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    nombre = TextEditingController(text: widget.alumno?['nombre'] as String?);
    apellido = TextEditingController(
      text: widget.alumno?['apellido'] as String?,
    );
    nota = TextEditingController(text: widget.alumno?['nota']?.toString());
  }

  @override
  void dispose() {
    nombre.dispose();
    apellido.dispose();
    nota.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (guardando || !formulario.currentState!.validate()) return;
    setState(() => guardando = true);
    try {
      await datos.guardarAlumno({
        'id':
            widget.alumno?['id'] ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        'nombre': nombre.text.trim(),
        'apellido': apellido.text.trim(),
        'nota': double.parse(nota.text.trim().replaceAll(',', '.')),
      });
      if (!mounted) return;
      aviso(context, 'Alumno guardado correctamente.');
      // Deja el listado sobre el menú, evitando formularios repetidos.
      Navigator.popUntil(context, ModalRoute.withName('/menu'));
      Navigator.pushNamed(context, '/alumnos');
    } catch (_) {
      if (mounted) {
        setState(() => guardando = false);
        aviso(context, 'No se pudo guardar. Intenta nuevamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editar = widget.alumno != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editar ? 'Editar Alumno' : 'Registrar Alumno'),
      ),
      body: contenido(
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formulario,
            child: Column(
              children: [
                TextFormField(
                  controller: nombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del alumno',
                  ),
                  validator: obligatorio,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: apellido,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: obligatorio,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nota,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nota (0 - 20)',
                    suffixIcon: Icon(Icons.school_outlined),
                  ),
                  // EXTRA: acepta punto o coma y limita el rango de la nota.
                  validator: (valor) {
                    final numero = double.tryParse(
                      (valor ?? '').trim().replaceAll(',', '.'),
                    );
                    if (numero == null ||
                        !numero.isFinite ||
                        numero < 0 ||
                        numero > 20) {
                      return 'Ingresa una nota entre 0 y 20';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: guardando ? null : guardar,
                  child: Text(
                    guardando
                        ? 'GUARDANDO...'
                        : editar
                        ? 'GUARDAR CAMBIOS'
                        : 'GUARDAR',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool cambiandoAvatar = false;

  Future<void> cambiarAvatar() async {
    if (cambiandoAvatar) return;
    setState(() => cambiandoAvatar = true);
    try {
      final imagen = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 70,
      );
      if (imagen != null) {
        final bytes = await imagen.readAsBytes();
        if (bytes.length > 500000) {
          if (mounted) aviso(context, 'Elige una imagen menor de 500 KB.');
          return;
        }
        // EXTRA: base64 permite conservar un avatar pequeño localmente.
        await datos.guardarPerfil({
          ...datos.perfil,
          'avatar': base64Encode(bytes),
        });
      }
    } catch (_) {
      if (mounted) aviso(context, 'No se pudo guardar la imagen.');
    } finally {
      if (mounted) setState(() => cambiandoAvatar = false);
    }
  }

  Future<void> editarPerfil() async {
    final nombre = TextEditingController(
      text: datos.perfil['nombre'] as String,
    );
    final telefono = TextEditingController(
      text: datos.perfil['telefono'] as String,
    );
    final formulario = GlobalKey<FormState>();
    bool guardando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (panelContext) => StatefulBuilder(
        builder: (context, actualizar) => PopScope(
          canPop: !guardando,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formulario,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar perfil',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: obligatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: telefono,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    validator: (v) =>
                        RegExp(r'^\d{9}$').hasMatch((v ?? '').trim())
                        ? null
                        : 'Ingresa un teléfono de 9 dígitos',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: guardando
                        ? null
                        : () async {
                            if (!formulario.currentState!.validate()) return;
                            actualizar(() => guardando = true);
                            try {
                              await datos.guardarPerfil({
                                ...datos.perfil,
                                'nombre': nombre.text.trim(),
                                'telefono': telefono.text.trim(),
                              });
                              if (!context.mounted) return;
                              actualizar(() => guardando = false);
                              Navigator.pop(context);
                            } catch (_) {
                              if (!context.mounted) return;
                              actualizar(() => guardando = false);
                              aviso(context, 'No se pudo guardar el perfil.');
                            }
                          },
                    child: Text(guardando ? 'GUARDANDO...' : 'GUARDAR CAMBIOS'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    nombre.dispose();
    telefono.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: contenido(
        AnimatedBuilder(
          animation: datos,
          builder: (context, _) {
            final perfil = datos.perfil;
            final avatar = perfil['avatar'] as String;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFF0E8FA),
                        backgroundImage: avatar.isEmpty
                            ? null
                            : MemoryImage(base64Decode(avatar)),
                        child: avatar.isEmpty
                            ? const Icon(Icons.person, size: 65, color: morado)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton.filled(
                          onPressed: cambiandoAvatar ? null : cambiarAvatar,
                          icon: const Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  perfil['nombre'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(perfil['email'] as String, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Card(
                  elevation: 0,
                  color: const Color(0xFFFAF9FC),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Nombre'),
                        subtitle: Text(perfil['nombre'] as String),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(perfil['email'] as String),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Teléfono'),
                        subtitle: Text(perfil['telefono'] as String),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Roles'),
                        subtitle: Text(perfil['rol'] as String),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: editarPerfil,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: morado),
                  ),
                  child: const Text('EDITAR PERFIL'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
