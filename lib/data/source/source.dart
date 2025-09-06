import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:homecare_helper/data/model/RequestHelper.dart';
import 'package:homecare_helper/data/model/coefficient.dart';
import 'package:homecare_helper/data/model/cost_factor.dart';
import 'package:homecare_helper/data/model/customer.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:homecare_helper/data/model/location.dart';
import 'package:homecare_helper/data/model/message.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/data/model/request_detail.dart';
import 'package:homecare_helper/data/model/services.dart';
import 'package:homecare_helper/data/model/time_off.dart';

import 'package:http/http.dart' as http;

import '../model/Authen.dart';

abstract interface class DataSource {
  Future<List<Helper>?> loadCleanerData();

  Future<List<Location>?> loadLocationData();

  Future<List<Services>?> loadServicesData();

  Future<List<Customer>?> loadCustomerData();

  Future<List<Requests>?> loadRequestData();

  Future<List<RequestDetail>?> loadRequestDetailData();

  Future<void> sendRequests(Requests requests);

  Future<void> cancelRequest(String id);

  Future<void> finishRequest(String id, String token);

  Future<void> assignedRequest(String id, String token);

  Future<void> processingRequest(String id, String token);

  Future<void> finishPayment(String id, String token);

  Future<void> waitPayment(String id);

  Future<List<TimeOff>?> loadTimeOffData();

  Future<List<Message>?> loadMessageData(Message message);

  Future<void> sendMessage(String phone);

  Future<List<CostFactor>?> loadCostFactorData();

  Future<CoefficientOther?> loadCoefficientOther();

  Future<List<CoefficientOther>?> loadCoefficientService();

  Future<void> sendCustomerRegisterRequest(Customer customer);

  Future<Map<String, dynamic>?> calculateCost(
      num servicePrice,
      String startTime,
      String endTime,
      String startDate,
      CoefficientOther coefficientOther,
      num serviceFactor);

  Future<Authen?> loginHelper(String phone, String password);

  Future<Authen?> registerHelper(String phone, String password, String name,
      String email, Addresses addresses);

  Future<List<RequestHelper>?> loadUnassignedRequest(String token);

  Future<List<RequestHelper>?> loadAssignedRequest(String token);

  Future<void> updateWorkingStatus(String workingStatus, String token);
}

class RemoteDataSource implements DataSource {
  @override
  Future<List<Helper>?> loadCleanerData() async {
    const url = 'https://homecareapi.vercel.app/helper/';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> cleanerList = jsonDecode(bodyContent);

        List<Helper> helpers = [];
        for (int i = 0; i < cleanerList.length; i++) {
          try {
            final helper = Helper.fromJson(cleanerList[i]);
            helpers.add(helper);
          } catch (e) {
            print('Error parsing helper at index $i: $e');
            print('Helper data: ${cleanerList[i]}');
            // Continue with other helpers instead of failing completely
            continue;
          }
        }

        return helpers;
      } else {
        print(
            'Failed to load cleaner data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading cleaner data: $e');
      return null;
    }
  }

  @override
  Future<List<Location>?> loadLocationData() async {
    const url = 'https://homecareapi.vercel.app/location';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> locationList = jsonDecode(bodyContent);
        return locationList
            .map((location) => Location.fromJson(location))
            .toList();
      } else {
        print(
            'Failed to load location data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading location data: $e');
      return null;
    }
  }

  @override
  Future<List<Customer>?> loadCustomerData() async {
    const url = 'https://homecareapi.vercel.app/customer';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> customerList = jsonDecode(bodyContent);
        return customerList
            .map((customer) => Customer.fromJson(customer))
            .toList();
      } else {
        print(
            'Failed to load customer data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading customer data: $e');
      return null;
    }
  }

  Future<void> updateCustomerInfo(Customer customer) async {
    final url = 'https://homecareapi.vercel.app/customer/${customer.phone}';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(customer.toJson());

    try {
      final response = await http.patch(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Customer updated successfully!');
      } else {
        print('Failed to update customer. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  @override
  Future<List<Services>?> loadServicesData() async {
    const url = 'https://homecareapi.vercel.app/service';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> servicesList = jsonDecode(bodyContent);
        return servicesList
            .map((services) => Services.fromJson(services))
            .toList();
      } else {
        print(
            'Failed to load services data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading services data: $e');
      return null;
    }
  }

  @override
  Future<List<Requests>?> loadRequestData() async {
    const url = 'https://homecareapi.vercel.app/request';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // print(response.body);
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> requestList = jsonDecode(bodyContent);
        return requestList
            .map((request) => Requests.fromJson(request))
            .toList();
      } else {
        print(
            'Failed to load request data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading request data: $e');
      return null;
    }
  }

  @override
  Future<List<RequestDetail>?> loadRequestDetailData() async {
    const url = 'https://homecareapi.vercel.app/request';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> requestList = jsonDecode(bodyContent);

        List<String> requestIds = [];

        for (var request in requestList) {
          Requests req = Requests.fromJson(request);
          if (req.scheduleIds.isNotEmpty) {
            requestIds.addAll(req.scheduleIds);
          }
        }
        return await loadRequestDetailId(requestIds);
      } else {
        print(
            'Failed to load request detail data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading request detail data: $e');
      return null;
    }
  }

  Future<List<RequestDetail>?> loadRequestDetailId(List<String> id) async {
    String idString = id.join(',');
    if (idString.endsWith(',')) {
      idString = idString.substring(0, idString.length - 1);
    }
    String url = 'https://homecareapi.vercel.app/requestDetail?ids=$idString';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> detailsList = jsonDecode(bodyContent);
        return detailsList
            .map((detail) => RequestDetail.fromJson(detail))
            .toList();
      } else {
        print(
            'Failed to load request detail IDs. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading request detail IDs: $e');
      return null;
    }
  }

  @override
  Future<List<TimeOff>?> loadTimeOffData() async {
    const url = 'https://homecareapi.vercel.app/timeOff/test';
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> timeOffList = jsonDecode(bodyContent);
        return timeOffList.map((timeOff) => TimeOff.fromJson(timeOff)).toList();
      } else {
        print(
            'Failed to load request detail IDs. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading request detail IDs: $e');
      return null;
    }
  }

  @override
  Future<void> sendRequests(Requests requests) async {
    const url = 'https://homecareapi.vercel.app/request';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(requests.toJson());

    print(body);

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Requests posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<void> cancelRequest(String id) async {
    final url = 'https://homecareapi.vercel.app/request/cancel';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'id': id});
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Cancel request posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<void> waitPayment(String id) async {
    final url = 'https://homecareapi.vercel.app/request/waitpayment';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'id': id});
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Wait payment request posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<void> finishRequest(String id, String token) async {
    final url = 'https://homecareapi.vercel.app/request/finish';
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({'detailId': id});
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Done request posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<void> assignedRequest(String id, String token) async {
    final url = 'https://homecareapi.vercel.app/request/assign';
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({'detailId': id});
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Assigned request posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<List<Message>?> loadMessageData(Message message) async {
    final url = Uri.parse(
        'https://homecareapi.vercel.app/message?phone=${message.phone}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final bodyContent = json.decode(response.body);
        final List<dynamic> messageList = jsonDecode(bodyContent);
        return messageList.map((message) => Message.fromJson(message)).toList();
      } else {
        print('Failed to load message. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  @override
  Future<void> sendMessage(String phone) async {
    const url = 'https://homecareapi.vercel.app/message';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'phone': phone});

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Requests posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<List<CostFactor>?> loadCostFactorData() async {
    final url = "https://homecareapi.vercel.app/costFactor";
    final uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> costFactorList = jsonDecode(bodyContent);
        return costFactorList
            .map((costFactor) => CostFactor.fromJson(costFactor))
            .toList();
      } else {
        print(
            'Failed to load request data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading CostFactor data: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> calculateCost(
      num servicePrice,
      String startTime,
      String endTime,
      String startDate,
      CoefficientOther coefficientOther,
      num serviceFactor) async {
    const url = 'https://homecareapi.vercel.app/request/calculateCost';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "servicePrice": servicePrice,
      "startTime": startTime,
      "endTime": endTime,
      "workDate": startDate,
      "officeStartTime": "08:00",
      "officeEndTime": "18:00",
      "coefficient_other": coefficientOther.toJson(),
      "serviceFactor": serviceFactor
    });

    debugPrint(body);

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        // debugPrint("Response Body: $decodedResponse");
        return decodedResponse;
      } else {
        print(
            'Failed to post requests calculation. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error posting requests calculation: $e');
      return null;
    }
  }

  @override
  Future<CoefficientOther?> loadCoefficientOther() async {
    final url = "https://homecareapi.vercel.app/costFactor/other";
    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> coefficientOtherMap =
            jsonDecode(bodyContent);

        return CoefficientOther.fromJson(coefficientOtherMap);
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading CostFactor data: $e');
      return null;
    }
  }

  @override
  Future<List<CoefficientOther>?> loadCoefficientService() async {
    const String url =
        "https://homecareapi.vercel.app/costFactor/service"; // Thay bằng URL API thực tế
    final Uri uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final List<dynamic> coefficientServiceList = jsonDecode(bodyContent);
        return coefficientServiceList
            .map((coefficient) => CoefficientOther.fromJson(coefficient))
            .toList();
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error loading CostFactor data: $e');
      return [];
    }
  }

  @override
  Future<void> sendCustomerRegisterRequest(Customer customer) async {
    const url = 'https://homecareapi.vercel.app/customer';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "email": customer.email,
      "fullName": customer.name,
      "phone": customer.phone,
      "password": customer.password,
      "points": [
        {
          "point": 100000000,
        }
      ],
      "addresses":
          customer.addresses.map((address) => address.toJson()).toList(),
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Requests posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<void> finishPayment(String id, String token) async {
    final url = 'https://homecareapi.vercel.app/request/finishpayment';
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({'detailId': id});
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Done request posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<void> processingRequest(String id, String token) async {
    final url = 'https://homecareapi.vercel.app/request/processing';
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({'detailId': id});
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Done request posted successfully!');
        }
      } else {
        print('Failed to post requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting requests: $e');
    }
  }

  @override
  Future<Authen?> loginHelper(String phone, String password) {
    const url = 'https://homecareapi.vercel.app/auth/login/helper';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "phone": phone,
      "password": password,
    });

    try {
      return http.post(uri, headers: headers, body: body).then((response) {
        if (response.statusCode == 200) {
          final bodyContent = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> authMap = jsonDecode(bodyContent);
          final Authen auth = Authen.fromJson(authMap);
          return auth;
        } else {
          print('Failed to authenticate. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        return null;
      });
    } catch (e) {
      print('Error during authentication: $e');
      return Future.error(e);
    }
  }

  @override
  Future<Authen?> registerHelper(String phone, String password, String name,
      String email, Addresses addresses) {
    const url = 'https://homecareapi.vercel.app/auth/register/helper';
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "fullName": name,
      "phone": phone,
      "password": password,
      "email": email,
      "address": addresses.toJson(),
    });

    try {
      return http.post(uri, headers: headers, body: body).then((response) {
        if (response.statusCode == 201) {
          final bodyContent = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> authenMap = jsonDecode(bodyContent);
          final Authen authen = Authen.fromJson(authenMap);
          return authen;
        } else {
          print('Failed to register. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return Future.error('Failed to register');
        }
      });
    } catch (e) {
      print('Error during registration: $e');
      return Future.error(e);
    }
  }

  @override
  Future<List<RequestHelper>?> loadUnassignedRequest(String token) {
    final url = "https://homecareapi.vercel.app/request";
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    try {
      return http.get(uri, headers: headers).then((response) {
        if (response.statusCode == 200) {
          final bodyContent = utf8.decode(response.bodyBytes);
          final List<dynamic> requestList = jsonDecode(bodyContent);
          print('body: $bodyContent');
          return requestList
              .map((request) => RequestHelper.fromJson(request))
              .toList();
        } else {
          print(
              'Failed to load unassigned requests. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return null;
        }
      });
    } catch (e) {
      print('Error loading unassigned requests: $e');
      return Future.error(e);
    }
  }

  @override
  Future<List<RequestHelper>?> loadAssignedRequest(String token) {
    final url = "https://homecareapi.vercel.app/request/my-assigned";
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    try {
      return http.get(uri, headers: headers).then((response) {
        if (response.statusCode == 200) {
          final bodyContent = utf8.decode(response.bodyBytes);
          final List<dynamic> requestList = jsonDecode(bodyContent);
          print('body: $bodyContent');
          return requestList
              .map((request) => RequestHelper.fromJson(request))
              .toList();
        } else {
          print(
              'Failed to load assigned requests. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return null;
        }
      });
    } catch (e) {
      print('Error loading assigned requests: $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> updateWorkingStatus(String workingStatus, String token) {
    final url = 'https://homecareapi.vercel.app/helper/status';
    final uri = Uri.parse(url);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({'workingStatus': workingStatus});
    try {
      return http.patch(uri, headers: headers, body: body).then((response) {
        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('Status updated successfully!');
          }
        } else {
          print('Failed to update status. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      });
    } catch (e) {
      print('Error updating status: $e');
      return Future.error(e);
    }
  }
}
