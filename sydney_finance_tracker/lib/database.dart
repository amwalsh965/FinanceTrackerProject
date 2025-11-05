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
      body: jsonEncode(expense),
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
        body: jsonEncode(expense));
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
    print(response);
    print(response.statusCode);
    print(response.headers);
    print(response.body);
    print("add reminder");
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
}
