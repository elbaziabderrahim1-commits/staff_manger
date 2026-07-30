import 'package:flutter/material.dart';

void main() {
  runApp(const StaffManagerApp());
}

class StaffManagerApp extends StatelessWidget {
  const StaffManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة الموظفين',
      // دعم اللغة العربية والاتجاه من اليمين لليسار
      locale: const Locale('ar', 'MA'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // يمكنك تغيير الخط حسب الرغبة
      ),
      home: const HomeScreen(),
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String role;
  final String restDay;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.restDay,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> daysOfWeek = [
    'الكل',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];

  String selectedDay = 'الكل';

  final List<Employee> _employees = [
    Employee(id: '1', name: 'أحمد العلمي', role: 'سائق', restDay: 'الأحد'),
    Employee(id: '2', name: 'ياسين بونو', role: 'حارس', restDay: 'السبت'),
    Employee(id: '3', name: 'كريم التازي', role: 'تقني', restDay: 'الإثنين'),
  ];

  void _addEmployee(String name, String role, String restDay) {
    setState(() {
      _employees.add(
        Employee(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          role: role,
          restDay: restDay,
        ),
      );
    });
  }

  void _deleteEmployee(String id) {
    setState(() {
      _employees.removeWhere((emp) => emp.id == id);
    });
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    String selectedRestDay = 'الأحد';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة موظف جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الموظف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'المهمة / المنصب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedRestDay,
                items: daysOfWeek
                    .where((day) => day != 'الكل')
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      selectedRestDay = val;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'يوم الراحة الأسبوعية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    _addEmployee(
                      nameController.text.trim(),
                      roleController.text.trim().isEmpty
                          ? 'غير محدد'
                          : roleController.text.trim(),
                      selectedRestDay,
                    );
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('حفظ الموظف', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = selectedDay == 'الكل'
        ? _employees
        : _employees.where((emp) => emp.restDay == selectedDay).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الموظفين (${_employees.length})'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: daysOfWeek.length,
              itemBuilder: (ctx, index) {
                final day = daysOfWeek[index];
                final isSelected = day == selectedDay;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(
                    child: Text(
                      'لا يوجد موظفين لهذا اليوم',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (ctx, index) {
                      final emp = filteredEmployees[index];
                      return Dismissible(
                        key: Key(emp.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteEmployee(emp.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                emp.name.isNotEmpty ? emp.name[0] : '؟',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              emp.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('المهمة: ${emp.role}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'الراحة: ${emp.restDay}',
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة موظف'),
      ),
    );
  }
}
