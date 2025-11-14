import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> getExpenses(List<int>? ids) async {
    var url = '$baseUrl/expenses';
    final uri = Uri.parse(url).replace(queryParameters: {
      if (ids != null && ids.isNotEmpty) 'ids': ids.join(','),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Map<String, dynamic>> addExpense(Map<String, dynamic> expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...expense,
        'date': (expense['date'] as DateTime).toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add expense');
    }
  }

  Future<Map<String, dynamic>> updateExpense(
      Map<String, dynamic> expense) async {
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/${expense["id"]}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...expense,
        'date': (expense['date'] as DateTime).toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpenses(List<int>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids ?? []}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete expense');
    }
  }

  //Reminders
  Future<List<Map<String, dynamic>>> getReminders(List<int>? ids) async {
    print("Get reminders");
    var url = '$baseUrl/reminders';
    if (ids != null && ids.isNotEmpty) {
      url += '?ids=${ids.join(',')}';
    }
    final response = await http.get(Uri.parse(url));
    print(response);
    print("Get reminders");
    if (response.statusCode == 200) {
      return jsonDecode(response.body).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load reminders');
    }
  }

  Future<Map<String, dynamic>?> getFirstReminderByDate() async {
    print("Get first reminder");
    final response = await http.get(Uri.parse('$baseUrl/reminders/first'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get first reminder');
    }
  }

  Future<Map<String, dynamic>> addReminder(
      Map<String, dynamic> reminder) async {
    print("Add reminder");
    final response = await http.post(
      Uri.parse('$baseUrl/reminders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reminder),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add reminder');
    }
  }

  Future<Map<String, dynamic>> updateReminder(
      Map<String, dynamic> reminder) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reminders/${reminder["id"]}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reminder),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> deleteReminders(List<int>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reminders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids ?? []}),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete reminder');
    }
  }

  //Categories
  Future<List<Map<String, dynamic>>> getCategories(List<int>? ids) async {
    var url = '$baseUrl/categories';
    final uri = Uri.parse(url).replace(queryParameters: {
      if (ids != null && ids.isNotEmpty) 'ids': ids.join(','),
    });

    final response = await http.get(uri);

    print(response.statusCode);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> addCategory(
      Map<String, dynamic> category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...category}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add category');
    }
  }

  Future<void> deleteCategories(List<int>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids ?? []}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }

  //Goals
  Future<List<Map<String, dynamic>>> getGoals(List<int>? ids) async {
    var url = '$baseUrl/goals';
    final uri = Uri.parse(url).replace(queryParameters: {
      if (ids != null && ids.isNotEmpty) 'ids': ids.join(','),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Map<String, dynamic>> addGoal(Map<String, dynamic> goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...goal,
        'date': goal['end_date'] is String
            ? (goal['end_date']).toIso8601String()
            : goal['end_date'],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add goal');
    }
  }

  Future<Map<String, dynamic>> updateGoal(Map<String, dynamic> goal) async {
    final response = await http.put(
      Uri.parse('$baseUrl/goals/${goal["id"]}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...goal,
        'date': goal['end_date'] is String
            ? (goal['end_date']).toIso8601String()
            : goal['end_date'],
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoals(List<int>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/goals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids ?? []}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete goal');
    }
  }
}
