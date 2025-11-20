import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../providers/task_provider.dart';
import '../widgets/subtask_list.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // Nullable task for edit mode

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  RepeatType _repeatType = RepeatType.none;
  List<int> _repeatDays = [];

  List<SubTask> _subTasks = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      final task = widget.task!;
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description);
      _selectedDate = task.date;
      _selectedTime = task.time;
      _repeatType = task.repeatType;
      _repeatDays = List<int>.from(task.repeatDays);
      _subTasks = task.subTasks
          .map((e) => SubTask(title: e.title, isCompleted: e.isCompleted))
          .toList();
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _repeatType = RepeatType.none;
      _repeatDays = [];
      _subTasks = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _toggleRepeatDay(int day) {
    setState(() {
      if (_repeatDays.contains(day)) {
        _repeatDays.remove(day);
      } else {
        _repeatDays.add(day);
      }
    });
  }

  void _addSubTask() {
    setState(() {
      _subTasks.add(SubTask(title: '', isCompleted: false));
    });
  }

  bool _isDateTimeExpired() {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    return selectedDateTime.isBefore(now);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isDateTimeExpired()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Selected date and time have already passed. Please select a valid time.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    _formKey.currentState!.save();

    final newTask = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      repeatType: _repeatType,
      repeatDays: _repeatType == RepeatType.weekly ? _repeatDays : [],
      subTasks: _subTasks.where((sub) => sub.title.trim().isNotEmpty).toList(),
      isCompleted: widget.task?.isCompleted ?? false,
    );

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.task != null) {
      await taskProvider.updateTask(newTask, context);
    } else {
      await taskProvider.addTask(newTask, context);
    }

    setState(() => _isSaving = false);

    Navigator.pop(context);
  }

  Widget _buildRepeatOptions() {
    if (_repeatType == RepeatType.weekly) {
      return Wrap(
        spacing: 8,
        children: List.generate(7, (index) {
          final dayNum = index + 1;
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
          final selected = _repeatDays.contains(dayNum);
          return ChoiceChip(
            label: Text(dayName),
            selected: selected,
            onSelected: (_) => _toggleRepeatDay(dayNum),
          );
        }),
      );
    } else if (_repeatType == RepeatType.daily) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Task will repeat every day.'),
      );
    } else if (_repeatType == RepeatType.monthly) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Task will repeat every month on the same date.'),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      // Updated AppBar color for enhanced UI
      appBar: AppBar(
        backgroundColor: Colors.white, // Nude shade background
        iconTheme: const IconThemeData(color: Colors.black), // Back arrow color
        titleTextStyle: const TextStyle(
          color: Colors.black, // Title text color
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          IconButton(
            onPressed: (_isSaving ||
                !(_formKey.currentState?.validate() ?? false) ||
                _isDateTimeExpired())
                ? null
                : _saveTask,
            icon: _isSaving
                ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              ),
            )
                : Opacity(
              opacity: 1.0, // full opacity (you can tweak e.g. 0.9 if you want)
              child: const Icon(
                Icons.save,
                color: Colors.black, // save icon color black
              ),
            ),
            tooltip: 'Save Task',
          ),
        ],
      ),


      body: Stack(
        children: [
          // Background image (same as HomeScreen)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Semi-transparent white overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
            ),
          ),

          // Main form content with padding
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Title required' : null,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date picker
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Colors.grey.shade100,
                      title: const Text('Date'),
                      subtitle: Text(formattedDate),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: 8),

                    // Time picker
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Colors.grey.shade100,
                      title: const Text('Time'),
                      subtitle: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _pickTime,
                    ),

                    const SizedBox(height: 16),

                    // Repeat dropdown
                    DropdownButtonFormField<RepeatType>(
                      value: _repeatType,
                      decoration: const InputDecoration(
                        labelText: 'Repeat',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      items: RepeatType.values
                          .map(
                            (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last.toUpperCase()),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _repeatType = val ?? RepeatType.none;
                          if (_repeatType != RepeatType.weekly) {
                            _repeatDays.clear();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Repeat options (weekly days, daily, monthly)
                    _buildRepeatOptions(),

                    const SizedBox(height: 24),

                    // Subtasks header & add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sub Tasks', style: TextStyle(fontSize: 18)),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          onPressed: _addSubTask,
                        ),
                      ],
                    ),

                    // Subtasks list widget
                    SubTaskList(
                      subTasks: _subTasks,
                      onChanged: (index, val) {
                        setState(() {
                          _subTasks[index].title = val;
                        });
                      },
                      onRemove: (index) {
                        setState(() {
                          _subTasks.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
