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

abstract interface class Repository {
  Future<List<Helper>?> loadCleanerData();

  Future<List<Location>?> loadLocation();

  Future<List<Services>?> loadServices();

  Future<List<Customer>?> loadCustomer();

  Future<void> updateCustomer(Customer customer);

  Future<List<Requests>?> loadRequest();

  Future<List<RequestDetail>?> loadRequestDetail();

  Future<List<RequestDetail>?> getRequestDetailById(String id);

  Future<List<RequestDetail>?> loadRequestDetailId(List<String> id);

  Future<List<TimeOff>?> loadTimeOff();

  Future<void> sendRequest(Requests requests);

  Future<void> canceledRequest(String id);

  Future<void> assignedRequest(String id);

  Future<void> processingRequest(String id);

  Future<void> doneConfirmRequest(String id);

  Future<void> waitPaymentRequest(String id);

  Future<void> finishPayment(String id);

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
  Future<List<RequestDetail>?> getRequestDetailById(String id) async {
    return await remoteDataSource.getAllRequestDetailOfHelperId(id);
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
  Future<void> doneConfirmRequest(String id) async {
    return await remoteDataSource.finishRequest(id);
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
  Future<void> assignedRequest(String id) async{
    return await remoteDataSource.assignedRequest(id);
  }

  @override
  Future<void> finishPayment(String id) async {
    return await remoteDataSource.finishPayment(id);
  }

  @override
  Future<void> processingRequest(String id) async {
    return await remoteDataSource.processingRequest(id);
  }

  @override
  Future<void> waitPaymentRequest(String id) async {
    return await remoteDataSource.waitPayment(id);
  }
}
