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
import 'package:homecare_helper/data/source/source.dart';

import '../model/Authen.dart';

abstract interface class Repository {
  Future<List<Helper>?> loadCleanerData();

  Future<List<Location>?> loadLocation();

  Future<List<Services>?> loadServices();

  Future<List<Customer>?> loadCustomer();

  Future<void> updateCustomer(Customer customer);

  Future<List<Requests>?> loadRequest();

  Future<List<RequestDetail>?> loadRequestDetail();

  Future<List<TimeOff>?> loadTimeOff();

  Future<void> sendRequest(Requests requests);

  Future<void> canceledRequest(String id);

  Future<void> assignedRequest(String id, String token);

  Future<void> processingRequest(String id, String token);

  Future<void> finishRequest(String id, String token);

  Future<void> waitPaymentRequest(String id);

  Future<void> finishPayment(String id, String token);

  Future<void> sendMessage(String phone);

  Future<List<Message>?> loadMessage(Message message);

  Future<List<CostFactor>?> loadCostFactor();

  Future<CoefficientOther?> loadCoefficientOther();

  Future<List<CoefficientOther>?> loadCoefficientService();

  Future<Map<String, dynamic>?> calculateCost(
      num servicePrice,
      String startTime,
      String endTime,
      String startDate,
      CoefficientOther coefficientOther,
      num serviceFactor);

  Future<void> sendCustomerRegisterRequest(Customer customer);

  Future<void> loginHelper(String phone, String password);

  Future<void> registerHelper(String phone, String password, String fullName, String email, Addresses addresses);

  Future<List<RequestHelper>?> loadUnassignedRequest(String token);

  Future<List<RequestHelper>?> loadAssignedRequest(String token);

  Future<void> updateWorkingStatus(String status, String token);

  Future<bool?> registerHelperDeviceToken(String token, String phone);
}

class DefaultRepository implements Repository {
  final remoteDataSource = RemoteDataSource();

  @override
  Future<List<Helper>?> loadCleanerData() async {
    return await remoteDataSource.loadCleanerData();
  }

  @override
  Future<List<Location>?> loadLocation() async {
    return await remoteDataSource.loadLocationData();
  }

  @override
  Future<List<Customer>?> loadCustomer() async {
    return await remoteDataSource.loadCustomerData();
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await remoteDataSource.updateCustomerInfo(customer);
  }

  @override
  Future<List<Services>?> loadServices() async {
    return await remoteDataSource.loadServicesData();
  }

  @override
  Future<List<Requests>?> loadRequest() async {
    return await remoteDataSource.loadRequestData();
  }

  @override
  Future<List<RequestDetail>?> loadRequestDetail() async {
    return await remoteDataSource.loadRequestDetailData();
  }

  @override
  Future<void> sendRequest(Requests request) async {
    await remoteDataSource.sendRequests(request);
  }

  @override
  Future<List<TimeOff>?> loadTimeOff() async {
    return await remoteDataSource.loadTimeOffData();
  }

  @override
  Future<List<Message>?> loadMessage(Message message) async {
    return await remoteDataSource.loadMessageData(message);
  }

  @override
  Future<void> sendMessage(String phone) async {
    return await remoteDataSource.sendMessage(phone);
  }

  @override
  Future<List<CostFactor>?> loadCostFactor() async {
    return await remoteDataSource.loadCostFactorData();
  }

  @override
  Future<void> canceledRequest(String id) async {
    return await remoteDataSource.cancelRequest(id);
  }

  @override
  Future<void> finishRequest(String id, String token) async {
    return await remoteDataSource.finishRequest(id, token);
  }

  @override
  Future<Map<String, dynamic>?> calculateCost(
      num servicePrice,
      String startTime,
      String endTime,
      String startDate,
      CoefficientOther coefficientOther,
      num serviceFactor) async {
    return await remoteDataSource.calculateCost(servicePrice, startTime,
        endTime, startDate, coefficientOther, serviceFactor);
  }

  @override
  Future<CoefficientOther?> loadCoefficientOther() async {
    return await remoteDataSource.loadCoefficientOther();
  }

  @override
  Future<List<CoefficientOther>?> loadCoefficientService() async {
    return await remoteDataSource.loadCoefficientService();
  }

  @override
  Future<List<RequestDetail>?> loadRequestDetailId(List<String> id) async {
    return await remoteDataSource.loadRequestDetailId(id);
  }

  @override
  Future<void> sendCustomerRegisterRequest(Customer customer) async {
    return await remoteDataSource.sendCustomerRegisterRequest(customer);
  }

  @override
  Future<void> assignedRequest(String id, String token) async{
    return await remoteDataSource.assignedRequest(id, token);
  }

  @override
  Future<void> finishPayment(String id, String token) async {
    return await remoteDataSource.finishPayment(id, token);
  }

  @override
  Future<void> processingRequest(String id, String token) async {
    return await remoteDataSource.processingRequest(id, token);
  }

  @override
  Future<void> waitPaymentRequest(String id) async {
    return await remoteDataSource.waitPayment(id);
  }


  @override
  Future<Authen?> loginHelper(String phone, String password) async{
    return await remoteDataSource.loginHelper(phone, password);
  }

  @override
  Future<Authen?> registerHelper(String phone, String password, String fullName, String email, Addresses addresses) async{
    return await remoteDataSource.registerHelper(phone, password, fullName, email, addresses);
  }

  @override
  Future<List<RequestHelper>?> loadUnassignedRequest(String token) async{
    return await remoteDataSource.loadUnassignedRequest(token);
  }

  @override
  Future<List<RequestHelper>?> loadAssignedRequest(String token) async{
    return await remoteDataSource.loadAssignedRequest(token);
  }

  @override
  Future<void> updateWorkingStatus(String status, String token) {
    return remoteDataSource.updateWorkingStatus(status, token);
  }

  @override
  Future<bool?> registerHelperDeviceToken(String token, String phone) async {
    return await remoteDataSource.registerHelperDeviceToken(token, phone);
  }
}
