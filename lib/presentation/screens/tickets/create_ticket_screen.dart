import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../../data/models/ticket_model.dart';
import '../../../core/theme/app_theme.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TicketCategory _category = TicketCategory.hardware;
  TicketPriority _priority = TicketPriority.medium;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (img == null) return;
      final bytes = await img.readAsBytes();
      setState(() => _attachments.add({'type': 'image', 'bytes': bytes, 'name': img.name.isEmpty ? 'foto_kamera.jpg' : img.name}));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamera tidak tersedia: $e'), backgroundColor: AppTheme.acidRed, shape: AppTheme.brutalShape),
      );
    }
  }

  Future<void> _pickGallery() async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (img == null) return;
      final bytes = await img.readAsBytes();
      setState(() => _attachments.add({'type': 'image', 'bytes': bytes, 'name': img.name}));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka galeri: $e'), backgroundColor: AppTheme.acidRed, shape: AppTheme.brutalShape),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'], withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      setState(() => _attachments.add({'type': 'file', 'bytes': file.bytes!, 'name': file.name}));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file: $e'), backgroundColor: AppTheme.acidRed, shape: AppTheme.brutalShape),
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.adaptiveBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4)), side: BorderSide(color: AppTheme.adaptiveText(context), width: 3)),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(2))),
              Text('LAMPIRAN', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 3)),
              const SizedBox(height: 8),
              _optionRow(Icons.camera_alt_rounded, 'KAMERA', 'Ambil foto dari kamera', _pickCamera),
              _optionRow(Icons.photo_library_rounded, 'GALERI', 'Pilih gambar dari perangkat', _pickGallery),
              _optionRow(Icons.insert_drive_file_rounded, 'FILE', 'PDF, DOC, XLS', _pickFile),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: AppTheme.primary)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.adaptiveText(context), letterSpacing: 1)),
                Text(subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.adaptiveTextSecondary(context))),
              ])),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.adaptiveTextSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tp = Provider.of<TicketProvider>(context, listen: false);

    final imageAttachments = _attachments.where((item) => item['type'] == 'image').map((item) => item['bytes'] as Uint8List).toList();

    await tp.createTicket(title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(), category: _category, priority: _priority, createdBy: auth.currentUser!.id, attachments: imageAttachments.isNotEmpty ? imageAttachments : null);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TIKET BERHASIL DIBUAT!', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1)), backgroundColor: AppTheme.acidLime, behavior: SnackBarBehavior.floating, shape: AppTheme.brutalShape),
    );
    context.go('/tickets');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppTheme.adaptiveBackground(context),
        foregroundColor: AppTheme.adaptiveText(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('BUAT TIKET', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.adaptiveText(context), width: 3)),
          ),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(4)),
            child: Icon(Icons.arrow_back_rounded, color: AppTheme.primary, size: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Title
            _brutalLabel('JUDUL MASALAH'),
            TextFormField(
              controller: _titleCtrl,
              style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Contoh: Printer tidak bisa nyala',
                hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveTextSecondary(context), fontWeight: FontWeight.w600),
                filled: true,
                fillColor: AppTheme.adaptiveSurface(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppTheme.adaptiveText(context), width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppTheme.adaptiveText(context), width: 3)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Judul tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Deskripsi
            _brutalLabel('DESKRIPSI'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Jelaskan masalah secara detail...',
                hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveTextSecondary(context), fontWeight: FontWeight.w600),
                filled: true,
                fillColor: AppTheme.adaptiveSurface(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppTheme.adaptiveText(context), width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppTheme.adaptiveText(context), width: 3)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            // Kategori
            _brutalLabel('KATEGORI'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.adaptiveSurface(context),
                border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonFormField<TicketCategory>(
                initialValue: _category,
                dropdownColor: AppTheme.adaptiveSurface(context),
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: AppTheme.adaptiveText(context)),
                icon: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.adaptiveText(context)),
                items: TicketCategory.values.map((c) {
                  final label = c == TicketCategory.hardware ? 'HARDWARE' : c == TicketCategory.software ? 'SOFTWARE' : c == TicketCategory.network ? 'NETWORK' : 'OTHER';
                  return DropdownMenuItem(value: c, child: Text(label));
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            const SizedBox(height: 16),

            // Prioritas
            _brutalLabel('PRIORITAS'),
            Row(
              children: [
                _BrutPriorityChip(label: 'LOW', color: AppTheme.acidLime, isSelected: _priority == TicketPriority.low, onTap: () => setState(() => _priority = TicketPriority.low)),
                const SizedBox(width: 10),
                _BrutPriorityChip(label: 'MEDIUM', color: AppTheme.adaptiveText(context), textColor: AppTheme.primary, isSelected: _priority == TicketPriority.medium, onTap: () => setState(() => _priority = TicketPriority.medium)),
                const SizedBox(width: 10),
                _BrutPriorityChip(label: 'HIGH', color: AppTheme.acidRed, textColor: AppTheme.adaptiveText(context), isSelected: _priority == TicketPriority.high, onTap: () => setState(() => _priority = TicketPriority.high)),
              ],
            ),
            const SizedBox(height: 20),

            // Lampiran
            _brutalLabel('LAMPIRAN (OPSIONAL)'),
            GestureDetector(
              onTap: _showAttachmentOptions,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 2, strokeAlign: BorderSide.strokeAlignInside),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file_rounded, size: 22, color: AppTheme.acidLime),
                    const SizedBox(width: 8),
                    Text('TAMBAH LAMPIRAN', style: GoogleFonts.spaceGrotesk(color: AppTheme.acidLime, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13)),
                  ],
                ),
              ),
            ),

            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._attachments.asMap().entries.map((entry) {
                final i = entry.key;
                final a = entry.value;
                final bytes = a['bytes'] as Uint8List;
                final isImage = a['type'] == 'image';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.adaptiveSurface(context),
                    border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: isImage
                            ? Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover)
                            : Container(width: 40, height: 40, color: AppTheme.acidLime.withOpacity(0.2), child: Icon(Icons.insert_drive_file_rounded, color: AppTheme.adaptiveText(context))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a['name'], style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.adaptiveText(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: AppTheme.adaptiveTextSecondary(context))),
                        ]),
                      ),
                      IconButton(icon: Icon(Icons.close, color: AppTheme.acidRed, size: 20), onPressed: () => setState(() => _attachments.removeAt(i))),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 30),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.acidLime,
                  foregroundColor: AppTheme.adaptiveText(context),
                  side: BorderSide(color: AppTheme.adaptiveText(context), width: 3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _isLoading
                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.adaptiveText(context)))
                    : Text('KIRIM TIKET', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 3)),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _brutalLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 2),
        ),
      );
}

class _BrutPriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback onTap;
  const _BrutPriorityChip({required this.label, required this.color, this.textColor, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color : AppTheme.adaptiveSurface(context),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.adaptiveText(context), width: isSelected ? 3 : 2),
            boxShadow: isSelected ? [BoxShadow(color: color, offset: const Offset(3, 3), blurRadius: 0)] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.adaptiveText(context),
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
