// lib/screens/edit_checkpoint_screen.dart

import 'package:flutter/material.dart';
import '../blocs/checkpoint/checkpoint_bloc.dart';
import '../blocs/checkpoint/checkpoint_event.dart';
import '../blocs/checkpoint/checkpoint_state.dart';
import '../models/checkpoint_model.dart';

class EditCheckpointScreen extends StatefulWidget {
  final String questId;
  final String? checkpointId;
  final Map<String, dynamic>? checkpointData;

  const EditCheckpointScreen({
    super.key,
    required this.questId,
    this.checkpointId,
    this.checkpointData,
  });

  @override
  State<EditCheckpointScreen> createState() => _EditCheckpointScreenState();
}

class _EditCheckpointScreenState extends State<EditCheckpointScreen> {
  final _formKey = GlobalKey<FormState>();
  late CheckpointBloc _checkpointBloc;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _taskController;
  late TextEditingController _answerController;
  late TextEditingController _qrCodeController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _pointsRewardController;
  late TextEditingController _hintController;

  String _taskType = 'text';
  final List<String> _taskTypes = ['text', 'qr', 'photo'];

  @override
  void initState() {
    super.initState();
    _checkpointBloc = CheckpointBloc();

    // Слушаем состояние BLoC
    _checkpointBloc.stateStream.listen((state) {
      if (state is CheckpointOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (state is CheckpointError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Инициализация контроллеров
    if (widget.checkpointData != null) {
      // Режим редактирования
      _titleController = TextEditingController(
        text: widget.checkpointData!['title'] ?? '',
      );
      _descriptionController = TextEditingController(
        text: widget.checkpointData!['description'] ?? '',
      );
      _taskController = TextEditingController(
        text: widget.checkpointData!['task'] ?? '',
      );
      _answerController = TextEditingController(
        text: widget.checkpointData!['answer'] ?? '',
      );
      _qrCodeController = TextEditingController(
        text: widget.checkpointData!['qrCode'] ?? '',
      );
      _latitudeController = TextEditingController(
        text: widget.checkpointData!['latitude']?.toString() ?? '',
      );
      _longitudeController = TextEditingController(
        text: widget.checkpointData!['longitude']?.toString() ?? '',
      );
      _pointsRewardController = TextEditingController(
        text: widget.checkpointData!['pointsReward']?.toString() ?? '10',
      );
      _hintController = TextEditingController(
        text: widget.checkpointData!['hint'] ?? '',
      );
      _taskType = widget.checkpointData!['taskType'] ?? 'text';
    } else {
      // Режим создания
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _taskController = TextEditingController();
      _answerController = TextEditingController();
      _qrCodeController = TextEditingController();
      _latitudeController = TextEditingController();
      _longitudeController = TextEditingController();
      _pointsRewardController = TextEditingController(text: '10');
      _hintController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _taskController.dispose();
    _answerController.dispose();
    _qrCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _pointsRewardController.dispose();
    _hintController.dispose();
    _checkpointBloc.dispose();
    super.dispose();
  }

  void _saveCheckpoint() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'questId': widget.questId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'task': _taskController.text.trim(),
      'taskType': _taskType,
      'answer': _answerController.text.trim(),
      'qrCode': _qrCodeController.text.trim(),
      'latitude': double.tryParse(_latitudeController.text),
      'longitude': double.tryParse(_longitudeController.text),
      'pointsReward': int.tryParse(_pointsRewardController.text) ?? 10,
      'hint': _hintController.text.trim(),
    };

    if (widget.checkpointId == null) {
      // Создание новой точки
      final checkpoint = CheckpointModel(
        id: '',
        questId: widget.questId,
        orderNumber: 0, // будет рассчитан в репозитории
        title: data['title'] as String,
        description: data['description'] as String,
        task: data['task'] as String,
        taskType: data['taskType'] as String,
        answer: data['answer'] as String,
        qrCode: data['qrCode'] as String,
        latitude: data['latitude'] as double?,
        longitude: data['longitude'] as double?,
        pointsReward: data['pointsReward'] as int,
        hint: data['hint'] as String,
      );
      _checkpointBloc
          .handleEvent(CreateCheckpointEvent(checkpoint: checkpoint));
    } else {
      // Обновление существующей
      _checkpointBloc.handleEvent(
        UpdateCheckpointEvent(
          checkpointId: widget.checkpointId!,
          data: data,
        ),
      );
    }
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
        title: Text(
          widget.checkpointId == null ? 'Новая точка' : 'Редактирование точки',
          style: const TextStyle(color: Colors.black87, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Название точки',
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
                label: 'Описание места',
                icon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _taskController,
                label: 'Задание',
                icon: Icons.task,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите задание';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Тип задания',
                value: _taskType,
                items: _taskTypes,
                onChanged: (value) {
                  setState(() {
                    _taskType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_taskType == 'text' || _taskType == 'qr')
                _buildTextField(
                  controller: _answerController,
                  label: 'Правильный ответ',
                  icon: Icons.check_circle,
                  validator: (value) {
                    if (_taskType != 'photo' &&
                        (value == null || value.isEmpty)) {
                      return 'Введите ответ';
                    }
                    return null;
                  },
                ),
              if (_taskType == 'qr') ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _qrCodeController,
                  label: 'QR-код (если отличается от ответа)',
                  icon: Icons.qr_code,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: 'Широта',
                      icon: Icons.pin_drop,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Долгота',
                      icon: Icons.pin_drop,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pointsRewardController,
                label: 'Баллы за прохождение',
                icon: Icons.star,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите баллы';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _hintController,
                label: 'Подсказка (необязательно)',
                icon: Icons.lightbulb,
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveCheckpoint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    widget.checkpointId == null
                        ? 'Создать точку'
                        : 'Сохранить изменения',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
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
}
