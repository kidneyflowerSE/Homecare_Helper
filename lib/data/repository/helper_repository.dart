// import 'dart:convert';
// import 'package:homecare_helper/data/model/request.dart';
// import 'package:http/http.dart' as http;
// import '../model/helper.dart';
//
// class HelperRepository {
//   static const String baseUrl =
//       'api.homekare.site'; // Replace with your actual API URL
//
//   Future<Helper?> loginHelper(String phone, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/helpers/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'phone': phone,
//           'password': password,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('response: $data');
//         return Helper.fromJson(data);
//       }
//       return null;
//     } catch (e) {
//       print('Error logging in helper: $e');
//       return null;
//     }
//   }
//
//   Future<List<Helper>> loadCleanerData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/helpers'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((json) => Helper.fromJson(json)).toList();
//       }
//       return [];
//     } catch (e) {
//       print('Error loading cleaner data: $e');
//       return [];
//     }
//   }
//
//   Future<List<Requests>> getHelperRequests(String helperId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/requests/helper/$helperId'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((json) => Requests.fromJson(json)).toList();
//       }
//       return [];
//     } catch (e) {
//       print('Error loading helper requests: $e');
//       return [];
//     }
//   }
// }
