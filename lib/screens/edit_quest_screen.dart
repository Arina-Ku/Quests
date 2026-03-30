import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../blocs/quest/quest_bloc.dart';
import '../blocs/quest/quest_event.dart';
import '../blocs/quest/quest_state.dart';

class EditQuestScreen extends StatefulWidget {
  final String questId;
  final Map<String, dynamic> questData;

  const EditQuestScreen({
    super.key,
    required this.questId,
    required this.questData,
  });

  @override
  State<EditQuestScreen> createState() => _EditQuestScreenState();
}

class _EditQuestScreenState extends State<EditQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  late QuestBloc _questBloc;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _startLocationController;
  late TextEditingController _gatheringTimeController;
  late TextEditingController _maxTeamSizeController;

  late String _selectedDifficulty;
  late String _selectedCategory;
  late bool _isPublished;

  DateTime? _questDate;
  DateTime? _registrationDeadline;

  final List<String> _difficulties = ['легкий', 'средний', 'сложный'];
  final List<String> _categories = [
    'История',
    'Приключения',
    'Спорт',
    'Культура',
    'Детский'
  ];

  @override
  void initState() {
    super.initState();
    _questBloc = QuestBloc();

    // Слушаем состояние BLoC
    _questBloc.stateStream.listen((state) {
      if (state is QuestOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (state is QuestError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Инициализация контроллеров
    _titleController =
        TextEditingController(text: widget.questData['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.questData['description'] ?? '');
    _cityController =
        TextEditingController(text: widget.questData['city'] ?? '');
    _startLocationController =
        TextEditingController(text: widget.questData['startLocation'] ?? '');
    _gatheringTimeController =
        TextEditingController(text: widget.questData['gatheringTime'] ?? '');
    _maxTeamSizeController = TextEditingController(
      text: widget.questData['maxTeamSize']?.toString() ?? '4',
    );

    _selectedDifficulty = widget.questData['difficulty'] ?? 'легкий';
    _selectedCategory = widget.questData['category'] ?? 'История';
    _isPublished = widget.questData['isPublished'] ?? true;

    _questDate = (widget.questData['questDate'] as Timestamp?)?.toDate();
    _registrationDeadline =
        (widget.questData['registrationDeadline'] as Timestamp?)?.toDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _startLocationController.dispose();
    _gatheringTimeController.dispose();
    _maxTeamSizeController.dispose();
    _questBloc.dispose();
    super.dispose();
  }

  Future<void> _selectQuestDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _questDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.orange,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _questDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectRegistrationDeadline(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _registrationDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _questDate ?? DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _registrationDeadline = picked;
      });
    }
  }

  void _updateQuest() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'city': _cityController.text.trim(),
      'startLocation': _startLocationController.text.trim(),
      'gatheringTime': _gatheringTimeController.text.trim(),
      'difficulty': _selectedDifficulty,
      'category': _selectedCategory,
      'maxTeamSize': int.tryParse(_maxTeamSizeController.text) ?? 4,
      'isPublished': _isPublished,
      'questDate': _questDate,
      'registrationDeadline': _registrationDeadline,
    };

    _questBloc.handleEvent(UpdateQuestEvent(
      questId: widget.questId,
      data: data,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Редактирование квеста',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Название квеста',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Описание',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите описание';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                label: 'Город',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите город';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Дата проведения',
                value: _questDate,
                icon: Icons.calendar_today,
                onTap: () => _selectQuestDate(context),
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Дедлайн регистрации',
                value: _registrationDeadline,
                icon: Icons.event_available,
                onTap: () => _selectRegistrationDeadline(context),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _gatheringTimeController,
                label: 'Время сбора',
                icon: Icons.access_time,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _startLocationController,
                label: 'Место старта',
                icon: Icons.flag,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите место старта';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Сложность',
                value: _selectedDifficulty,
                items: _difficulties,
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Категория',
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _maxTeamSizeController,
                label: 'Макс. размер команды',
                icon: Icons.people,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Опубликовано',
                  style: TextStyle(color: Colors.black87),
                ),
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
                activeColor: Colors.orange,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _updateQuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Сохранить изменения',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(color: Colors.black87),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[500], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    value != null
                        ? DateFormat('dd.MM.yyyy HH:mm', 'ru').format(value)
                        : 'Не выбрано',
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
