import 'package:flutter/material.dart';
import '../models/serie.dart';
import '../services/mongo_service.dart';
import '../theme.dart';

class FormPage extends StatefulWidget {
  final Serie? serie;
  const FormPage({super.key, this.serie});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool get _isEdit => widget.serie != null;

  late final TextEditingController _titulo;
  late final TextEditingController _genero;
  late final TextEditingController _canal;
  late final TextEditingController _rating;
  late final TextEditingController _temporadas;
  late final TextEditingController _imagen;
  late final TextEditingController _sinopsis;
  String _estado = 'Running';

  @override
  void initState() {
    super.initState();
    final s = widget.serie;
    _titulo     = TextEditingController(text: s?.titulo ?? '');
    _genero     = TextEditingController(text: s?.genero ?? '');
    _canal      = TextEditingController(text: s?.canal ?? '');
    _rating     = TextEditingController(text: s != null && s.rating > 0 ? s.rating.toString() : '');
    _temporadas = TextEditingController(text: s != null && s.temporadas > 0 ? s.temporadas.toString() : '');
    _imagen     = TextEditingController(text: s?.imagen ?? '');
    _sinopsis   = TextEditingController(text: s?.sinopsis ?? '');
    _estado     = s?.estado ?? 'Running';
  }

  @override
  void dispose() {
    for (final c in [_titulo, _genero, _canal, _rating, _temporadas, _imagen, _sinopsis]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final serie = Serie(
        id: widget.serie?.id ?? '',
        titulo: _titulo.text.trim(),
        genero: _genero.text.trim(),
        estado: _estado,
        rating: double.tryParse(_rating.text) ?? 0.0,
        temporadas: int.tryParse(_temporadas.text) ?? 0,
        imagen: _imagen.text.trim(),
        sinopsis: _sinopsis.text.trim(),
        canal: _canal.text.trim(),
        fuente: widget.serie?.fuente ?? 'manual',
        tvmazeId: widget.serie?.tvmazeId,
      );
      late Serie resultado;
      if (_isEdit) {
        await MongoService.update(serie);
        resultado = serie;
      } else {
        resultado = await MongoService.insert(serie);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? '✅ Serie actualizada' : '✅ Serie agregada')));
        Navigator.pop(context, resultado);
      }
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar serie' : 'Nueva serie')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _field(_titulo, 'Título *',
                validator: (v) => v!.trim().isEmpty ? 'El título es obligatorio' : null),
            _field(_genero, 'Géneros', hint: 'Drama, Thriller…'),
            _field(_canal, 'Canal / Plataforma', hint: 'Netflix, HBO…'),
            Row(children: [
              Expanded(child: _field(_rating, 'Rating', hint: '0–10',
                  keyboard: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = double.tryParse(v);
                    return (n == null || n < 0 || n > 10) ? '0 – 10' : null;
                  })),
              const SizedBox(width: 10),
              Expanded(child: _field(_temporadas, 'Temporadas',
                  keyboard: TextInputType.number)),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                dropdownColor: AppTheme.card,
                items: const [
                  DropdownMenuItem(value: 'Running',          child: Text('▶  Running')),
                  DropdownMenuItem(value: 'Ended',            child: Text('⏹  Ended')),
                  DropdownMenuItem(value: 'To Be Determined', child: Text('?  To Be Determined')),
                  DropdownMenuItem(value: 'In Development',   child: Text('🔧  In Development')),
                ],
                onChanged: (v) => setState(() => _estado = v!),
              ),
            ),
            _field(_imagen, 'URL imagen (poster)'),
            _field(_sinopsis, 'Sinopsis', maxLines: 4),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text(_isEdit ? 'Guardar cambios' : 'Agregar serie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {
    String? hint, int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}
