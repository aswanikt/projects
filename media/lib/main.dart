import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(PhotoRecordApp());
}

class PhotoRecordApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediaMark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RecordScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            'MediaMark',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// Main Screen
class RecordScreen extends StatefulWidget {
  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _copiesController = TextEditingController();
  String? _photoType;
  File? _image;

  List<List<String>> _records = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _pickImageFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final dir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await pickedFile.copy('${dir.path}/$fileName.jpg');
      setState(() {
        _image = savedImage;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _copiesController.text.isEmpty ||
        _photoType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select a photo type.')),
      );
      return;
    }

    final date = DateTime.now().toIso8601String().split('T').first;
    final newRecord = [
      _nameController.text,
      _phoneController.text,
      _copiesController.text,
      _photoType!,
      date,
      _image?.path ?? '',
    ];

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('records') ?? [];

    if (_editingIndex != null) {
      existing[_editingIndex!] = newRecord.join('|');
      _editingIndex = null;
    } else {
      existing.add(newRecord.join('|'));
    }

    await prefs.setStringList('records', existing);
    _clearForm();
    _loadRecords();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _copiesController.clear();
      _photoType = null;
      _image = null;
      _editingIndex = null;
    });
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('records') ?? [];
    setState(() {
      _records = stored.map((e) => e.split('|')).toList();
    });
  }

  void _editRecord(int index) {
    final record = _records[index];
    setState(() {
      _editingIndex = index;
      _nameController.text = record[0];
      _phoneController.text = record[1];
      _copiesController.text = record[2];
      _photoType = record[3];
      _image = record[5].isNotEmpty ? File(record[5]) : null;
    });
  }

  void _cancelEdit() {
    _clearForm();
  }

  Future<void> _deleteRecord(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('records') ?? [];
    existing.removeAt(index);
    await prefs.setStringList('records', existing);
    _loadRecords();
  }

  Widget _styledTextField(TextEditingController controller, String label, {TextInputType? inputType}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Customer Data Records'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.work_history),
            tooltip: 'Record Video Work',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoWorksPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _styledTextField(_nameController, 'Name'),
            _styledTextField(_phoneController, 'Phone', inputType: TextInputType.phone),
            _styledTextField(_copiesController, 'Number of Copies', inputType: TextInputType.number),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _photoType,
                hint: Text('Nothing Selected'),
                decoration: InputDecoration(
                  labelText: 'Photo Type',
                  border: InputBorder.none,
                ),
                items: ['Passport size', 'Stamp size']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _photoType = val),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Select Image from Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _pickImageFromFile,
            ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 120),
                ),
              ),
            SizedBox(height: 15),
            _editingIndex == null
                ? ElevatedButton(
                    onPressed: _saveRecord,
                    child: Text('Save Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _saveRecord,
                        child: Text('Update Record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _cancelEdit,
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 20),
            Divider(),
            Text("Saved Records", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final rec = _records[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: rec[5].isNotEmpty && File(rec[5]).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(File(rec[5]), width: 50, height: 50, fit: BoxFit.cover),
                          )
                        : Icon(Icons.image_not_supported),
                    title: Text(rec[0], style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${rec[4]} | ${rec[3]} | ${rec[2]} copies\n${rec[1]}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editRecord(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRecord(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class VideoWorksPage extends StatefulWidget {
  @override
  _VideoWorksPageState createState() => _VideoWorksPageState();
}

class _VideoWorksPageState extends State<VideoWorksPage> {
  List<WorkEntry> _tempEntries = [WorkEntry()];
  List<WorkEntry> _savedEntries = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
  }

  Future<void> _loadSavedEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList('saved_entries');
    if (rawList != null) {
      setState(() {
        _savedEntries = rawList.map((str) => WorkEntry.fromRawString(str)).toList();
      });
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _savedEntries.map((e) => e.toRawString()).toList();
    await prefs.setStringList('saved_entries', rawList);
  }

  void _addEntry() {
    setState(() {
      _tempEntries.add(WorkEntry());
    });
  }

  void _saveEntries() {
    setState(() {
      if (_editingIndex != null) {
        _savedEntries[_editingIndex!] = _tempEntries.first;
        _editingIndex = null;
      } else {
        _savedEntries.addAll(_tempEntries);
      }
      _tempEntries = [WorkEntry()];
    });
    _saveToPrefs();
  }

  void _editEntry(int index) {
    setState(() {
      _tempEntries = [WorkEntry.clone(_savedEntries[index])];
      _editingIndex = index;
    });
  }

  void _cancelEdit() {
    setState(() {
      _tempEntries = [WorkEntry()];
      _editingIndex = null;
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      _savedEntries.removeAt(index);
    });
    _saveToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Work Records'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _tempEntries.length,
              itemBuilder: (context, index) {
                return WorkEntryWidget(
                  key: ValueKey(_tempEntries[index]),
                  entry: _tempEntries[index],
                  index: index,
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text(_editingIndex != null ? 'Update Entry' : 'Save Entries'),
                  onPressed: _saveEntries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                if (_editingIndex != null)
                  TextButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel Edit'),
                    onPressed: _cancelEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
              ],
            ),
            Divider(thickness: 1.5),
            Text("Saved Records", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _savedEntries.length,
              itemBuilder: (context, index) {
                final e = _savedEntries[index];
                String typeLabel = '';
                if (e.isStill) typeLabel += 'Still';
                if (e.isStill && e.isVideo) typeLabel += ' | ';
                if (e.isVideo) typeLabel += 'Video';

                return Card(
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      "Date: ${e.date != null ? e.date!.toLocal().toString().split(' ')[0] : '-'}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "$typeLabel\nDesc: ${e.description.isNotEmpty ? e.description : '-'}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editEntry(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class WorkEntry {
  DateTime? date;
  bool isStill = false;
  bool isVideo = false;
  String description = '';

  WorkEntry();

  WorkEntry.clone(WorkEntry entry)
      : date = entry.date,
        isStill = entry.isStill,
        isVideo = entry.isVideo,
        description = entry.description;

  // Convert to simple string
  String toRawString() {
    return '${date?.toIso8601String() ?? ''}|$isStill|$isVideo|$description';
  }

  // Create object from string
  static WorkEntry fromRawString(String raw) {
    final parts = raw.split('|');
    return WorkEntry()
      ..date = parts[0].isNotEmpty ? DateTime.tryParse(parts[0]) : null
      ..isStill = parts.length > 1 ? parts[1] == 'true' : false
      ..isVideo = parts.length > 2 ? parts[2] == 'true' : false
      ..description = parts.length > 3 ? parts.sublist(3).join('|') : '';
  }
}

class WorkEntryWidget extends StatefulWidget {
  final WorkEntry entry;
  final int index;

  WorkEntryWidget({Key? key, required this.entry, required this.index}) : super(key: key);

  @override
  _WorkEntryWidgetState createState() => _WorkEntryWidgetState();
}

class _WorkEntryWidgetState extends State<WorkEntryWidget> {
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.entry.description);
  }

  @override
  void didUpdateWidget(covariant WorkEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _descController.text = widget.entry.description;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Card(
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sl No: ${widget.index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Text(entry.date != null
                    ? 'Date: ${entry.date!.toLocal().toString().split(' ')[0]}'
                    : 'Select Date'),
                Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text('Pick'),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: entry.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => entry.date = picked);
                    }
                  },
                )
              ],
            ),
            CheckboxListTile(
              value: entry.isStill,
              onChanged: (val) => setState(() => entry.isStill = val ?? false),
              title: Text('Still'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: entry.isVideo,
              onChanged: (val) => setState(() => entry.isVideo = val ?? false),
              title: Text('Video'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            TextField(
              controller: _descController,
              onChanged: (val) => entry.description = val,
              decoration: InputDecoration(
                labelText: 'Other Events / Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}