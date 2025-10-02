import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homecare_helper/data/model/customer.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/data/model/request_detail.dart';
import 'dart:async';

import '../data/model/RequestHelper.dart';
import '../data/repository/repository.dart';
import '../services/fcm_service.dart';

class HomeContent extends StatefulWidget {
  final Helper helper;
  final String token;
  final String refreshToken;

  const HomeContent({
    Key? key,
    required this.helper,
    required this.token,
    required this.refreshToken,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  String _selectedStatus = "pending";
  Key pageKey = UniqueKey();
  List<Requests> requests = [];
  List<Requests> helperRequests = [];
  List<Customer> customers = [];
  List<RequestHelper> unassignedRequests = [];
  List<RequestHelper> assignedRequests = [];
  bool isLoading = true;
  late TabController _tabController;
  List<ScrollController> _scrollControllers = [];
  Map<String, Set<int>> completedDaysMap = {};
  final currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  // Countdown timer variables
  Timer? _countdownTimer;
  int _remainingMinutes = 0;
  int _remainingSeconds = 0;

  final Map<String, Map<String, dynamic>> _statusInfo = {
    "pending": {
      "label": "Chờ xác nhận",
      "color": Colors.amber,
      "icon": Icons.access_time,
    },
    "assigned": {
      "label": "Đã nhận việc",
      "color": Colors.cyan,
      "icon": Icons.assignment_turned_in,
    },
    "inProgress": {
      "label": "Đang tiến hành",
      "color": Colors.blue,
      "icon": Icons.hourglass_top,
    },
    "waitPayment": {
      "label": "Chờ thanh toán",
      "color": Colors.orange,
      "icon": Icons.payments,
    },
    "completed": {
      "label": "Hoàn thành",
      "color": Colors.green,
      "icon": Icons.check_circle,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Set the FCMService callback to refresh requests
    FCMService.onRequestRefresh = refreshRequestsOnly;

    // Khởi tạo ScrollController cho mỗi tab
    _scrollControllers = List.generate(5, (index) => ScrollController());

    // Thêm listener cho mỗi scroll controller
    for (int i = 0; i < _scrollControllers.length; i++) {
      _scrollControllers[i].addListener(() => _onScroll(i));
    }

    _tabController.addListener(() {
      setState(() {
        _selectedStatus = _getStatusByTabIndex(_tabController.index);
      });
    });
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    if (unassignedRequests.isNotEmpty) {
      // Tính thời gian hiện tại
      DateTime now = DateTime.now();

      // Tính số phút đã trôi qua trong giờ hiện tại (0-59)
      int currentMinutes = now.minute;

      // Tính thời gian còn lại đến phút thứ 60 (tức là giờ tiếp theo)
      int remainingMinutesToNextHour = 60 - currentMinutes;

      // Nếu chúng ta đang ở phút 0, thì countdown sẽ là 60 phút
      if (remainingMinutesToNextHour == 60) {
        _remainingMinutes = 59;
        _remainingSeconds = 60 - now.second;
      } else {
        _remainingMinutes = remainingMinutesToNextHour - 1;
        _remainingSeconds = 60 - now.second;
      }

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else if (_remainingMinutes > 0) {
          setState(() {
            _remainingMinutes--;
            _remainingSeconds = 59;
          });
        } else {
          // Countdown kết thúc, refresh danh sách
          refreshRequestsOnly().then((_) {
            if (mounted) {
              _startCountdownTimer(); // Restart countdown
            }
          });
        }
      });
    }
  }

  void _onScroll(int tabIndex) {
    ScrollController controller = _scrollControllers[tabIndex];

    // Kiểm tra nếu đã kéo đến cuối danh sách
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      // Nếu user tiếp tục kéo lên (overscroll), reload data
      if (controller.position.pixels > controller.position.maxScrollExtent) {
        refreshRequestsOnly();
      }
    }
  }

  String _getStatusByTabIndex(int index) {
    switch (index) {
      case 0:
        return "pending";
      case 1:
        return "assigned";
      case 2:
        return "inProgress";
      case 3:
        return "waitPayment";
      case 4:
        return "completed";
      default:
        return "pending";
    }
  }
  
  void updateWorkingStatus(String status) async {
    var repository = DefaultRepository();
    await repository.updateWorkingStatus(status, widget.token);
    if (mounted) {
      setState(() {
        widget.helper.workingStatus = status;
      });
      if (widget.helper.workingStatus == "online") {
        // Nếu chuyển sang online, chỉ tải lại danh sách công việc
        refreshRequestsOnly();
      } else {
        // Nếu chuyển sang offline, dừng timer và xóa danh sách công việc
        _countdownTimer?.cancel();
        setState(() {
          unassignedRequests.clear();
          assignedRequests.clear();
        });
      }
    }
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      var repository = DefaultRepository();

      var fetchedRequests = await repository.loadRequest();
      var fetchedCustomers = await repository.loadCustomer();
      var unassignedRequestsData =
          await repository.loadUnassignedRequest(widget.token);
      var assignedRequestsData =
          await repository.loadAssignedRequest(widget.token);

      if (mounted) {
        setState(() {
          requests = fetchedRequests ?? [];
          customers = fetchedCustomers ?? [];
          unassignedRequests = unassignedRequestsData ?? [];
          assignedRequests = assignedRequestsData ?? [];
          isLoading = false;
        });

        // Start countdown timer after loading data
        _startCountdownTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> refreshRequestsOnly() async {
    try {
      var repository = DefaultRepository();

      var unassignedRequestsData =
          await repository.loadUnassignedRequest(widget.token);
      var assignedRequestsData =
          await repository.loadAssignedRequest(widget.token);

      if (mounted) {
        setState(() {
          unassignedRequests = unassignedRequestsData ?? [];
          assignedRequests = assignedRequestsData ?? [];
        });

        // Restart countdown timer after refresh
        _startCountdownTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _countWeeklyJobs(List<Requests> requests) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return requests.where((req) {
      try {
        final jobDate = DateTime.parse(req.startTime);
        return jobDate.isAfter(startOfWeek) &&
            jobDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).length;
  }

  int _getJobCountByStatus(String status) {
    if (status == 'pending') {
      return unassignedRequests.length;
    } else {
      return assignedRequests
          .where((req) => req.schedules.first.status == status)
          .length;
    }
  }

  Future<void> assignedRequest(RequestHelper request) async {
    var repository = DefaultRepository();
    await repository.remoteDataSource
        .assignedRequest(request.schedules.first.id, widget.token);
    if (mounted) {
      setState(() {
        request.schedules.first.status = 'assigned';
        // Move request from unassigned to assigned list
        unassignedRequests.removeWhere((r) => r.id == request.id);
        assignedRequests.add(request);
      });
      // Switch to assigned tab
      _switchToStatusTab('assigned');
      await refreshRequestsOnly();
    }
  }

  Future<void> processingRequest(RequestHelper request, int index) async {
    var repository = DefaultRepository();
    await repository.processingRequest(
        request.schedules.first.id, widget.token);
    if (mounted) {
      setState(() {
        request.schedules.first.status = 'inProgress';
      });
      // Switch to in progress tab
      _switchToStatusTab('inProgress');
      await refreshRequestsOnly();
    }
  }

  Future<void> finishRequest(RequestHelper request, int index) async {
    var repository = DefaultRepository();
    await repository.finishRequest(request.schedules.first.id, widget.token);
    if (mounted) {
      setState(() {
        request.schedules.first.status = 'waitPayment';
      });
      // Switch to wait payment tab
      _switchToStatusTab('waitPayment');
      await refreshRequestsOnly();
    }
  }

  Future<void> finishPayment(RequestHelper request) async {
    var repository = DefaultRepository();
    await repository.remoteDataSource
        .finishPayment(request.schedules.first.id, widget.token);
    if (mounted) {
      setState(() {
        request.schedules.first.status = 'completed';
      });
      // Switch to done tab
      _switchToStatusTab('completed');
      await refreshRequestsOnly();
    }
  }

  Future<void> cancelRequest(RequestHelper request) async {
    var repository = DefaultRepository();
    await repository.remoteDataSource.cancelRequest(request.id);
    print("Thông tin huỷ request $request");
    if (mounted) {
      setState(() {
        request.schedules.first.status = 'cancelled';
        // Remove from current lists
        unassignedRequests.removeWhere((r) => r.id == request.id);
        assignedRequests.removeWhere((r) => r.id == request.id);
      });
      await refreshRequestsOnly();
    }
  }

  // Add method to switch tabs based on status
  void _switchToStatusTab(String status) {
    final statusKeys = _statusInfo.keys.toList();
    final tabIndex = statusKeys.indexOf(status);
    if (tabIndex != -1 && _tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day/$month/$year';
  }

  String formatTime(DateTime date) {
    String minutes = date.minute.toString().padLeft(2, '0');
    String hours = date.hour.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    // Remove this line since we're not using helperRequests anymore
    // updateHelperRequests();

    // Filter requests based on selected status - this is now unused
    List<Requests> filteredRequests =
        helperRequests.where((req) => req.status == _selectedStatus).toList()
          ..sort((a, b) {
            DateTime dateA =
                DateTime.parse(a.startTime ?? DateTime.now().toString());
            DateTime dateB =
                DateTime.parse(b.startTime ?? DateTime.now().toString());
            return dateB.compareTo(dateA); // Sort by most recent first
          });

    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshRequestsOnly,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                    SliverToBoxAdapter(
                      child: _buildDashboard(),
                    ),
                    // Chỉ hiển thị TabBar khi helper đang online
                    if (widget.helper.workingStatus == "online")
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: Colors.green,
                            unselectedLabelColor: Colors.grey.shade400,
                            indicatorColor: Colors.green,
                            tabs: _statusInfo.entries.map((entry) {
                              return Tab(
                                icon: Badge(
                                  backgroundColor: Colors.red,
                                  label: Text(_getJobCountByStatus(entry.key)
                                      .toString()),
                                  isLabelVisible:
                                      _getJobCountByStatus(entry.key) > 0,
                                  child: Icon(entry.value["icon"]),
                                ),
                                text: entry.value["label"],
                              );
                            }).toList(),
                          ),
                        ),
                        pinned: true,
                      ),
                  ];
                },
                body: widget.helper.workingStatus == "online"
                    ? TabBarView(
                        controller: _tabController,
                        children: _statusInfo.keys.map((status) {
                          final tabIndex =
                              _statusInfo.keys.toList().indexOf(status);
                          final statusRequests = status == 'pending'
                              ? unassignedRequests
                              : assignedRequests
                                  .where((req) =>
                                      req.schedules.first.status == status)
                                  .toList()
                            ..sort((a, b) {
                              DateTime dateA = a.startTime;
                              DateTime dateB = b.startTime;
                              return dateB.compareTo(dateA);
                            });

                          if (statusRequests.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                await refreshRequestsOnly();
                                // Auto refresh every 30 seconds for pending tab
                                if (status == 'pending') {
                                  _startCountdownTimer();
                                }
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: _buildEmptyState(status),
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              await refreshRequestsOnly();
                              // Auto refresh every 30 seconds for pending tab
                              if (status == 'pending') {
                                _startCountdownTimer();
                              }
                            },
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                // Kiểm tra nếu đã scroll đến cuối và user vẫn tiếp tục kéo
                                if (scrollInfo is OverscrollNotification &&
                                    scrollInfo.overscroll > 0 &&
                                    scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent) {
                                  // Kéo lên ở cuối danh sách - reload
                                  refreshRequestsOnly();
                                  return true;
                                }
                                return false;
                              },
                              child: ListView.builder(
                                controller: tabIndex < _scrollControllers.length
                                    ? _scrollControllers[tabIndex]
                                    : null,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                itemCount: statusRequests.length,
                                itemBuilder: (context, index) {
                                  return _buildJobCard(statusRequests[index]);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : RefreshIndicator(
                        onRefresh: refreshRequestsOnly,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildInactiveState(),
                          ),
                        ),
                      ),
              ),
            ),
    );
  }

  // Thêm widget cho trạng thái inactive
  Widget _buildInactiveState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Bạn đang tạm dừng nhận việc",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bật trạng thái 'Sẵn sàng nhận việc' để xem danh sách công việc",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Quicksand',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.helper.avatar!.isEmpty
                      ? NetworkImage('${widget.helper.avatar}')
                      : null,
                  child: widget.helper.avatar!.isEmpty
                      ? Icon(Icons.person, color: Colors.green)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Xin chào,",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    Text(
                      '${widget.helper.fullName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: 'Quicksand',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.helper.workingStatus == "online"
                        ? Colors.green.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.helper.workingStatus == "online" ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.helper.workingStatus == "online" ? "Trực tuyến" : "Ngoại tuyến",
                          style: TextStyle(
                            color: widget.helper.workingStatus == "online" ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: 'Quicksand',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Thêm toggle switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.helper.workingStatus == "online" ? Icons.work : Icons.work_off,
                  color: widget.helper.workingStatus == "online" ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.helper.workingStatus == "online"
                        ? "Đang sẵn sàng nhận việc"
                        : "Tạm dừng nhận việc",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.helper.workingStatus == "online" ? Colors.green : Colors.grey,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
                Switch(
                  value: widget.helper.workingStatus == "online",
                  onChanged: (value) {
                    updateWorkingStatus(value ? 'online' : 'offline');
                    setState(() {
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment tạm thời phần thống kê
          // final weeklyIncome = _calculateWeeklyIncome();
          // final totalEarnings = _calculateTotalEarnings();
          // final weeklyJobs = _countWeeklyJobs(helperRequests);

          Text(
            widget.helper.workingStatus == "online"
                ? "Danh sách công việc"
                : "Bạn đang tạm dừng nhận việc",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              color: widget.helper.workingStatus == "online" ? Colors.black : Colors.grey,
            ),
          ),
          // Hiển thị countdown cho tab chờ xác nhận
          if (widget.helper.workingStatus == "online" &&
              unassignedRequests.isNotEmpty &&
              _selectedStatus == "pending")
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Danh sách sẽ được cập nhật trong: ${_remainingMinutes.toString().padLeft(2, '0')}:${_remainingSeconds.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _statusInfo[status]?["icon"] ?? Icons.work_off_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Không có công việc ${_statusInfo[status]?["label"] ?? ""}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bạn chưa có công việc nào ở trạng thái này",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Quicksand',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(RequestHelper request) {
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime start = DateTime(
        request.startTime.year, request.startTime.month, request.startTime.day);

    final statusInfo = _statusInfo[request.schedules.first.status] ??
        {
          "color": Colors.grey,
          "label": "Không xác định",
          "icon": Icons.help_outline,
        };

    int index = request.scheduleIds.length; // Default
    if ((request.schedules.first.status == "inProcess" ||
            request.schedules.first.status == 'assigned') &&
        start.isAtSameMomentAs(now)) {
      index = now.difference(start).inDays + 1;
    }

    String formattedDate = '';
    try {
      final date = request.startTime;
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      // formattedDate = request.startTime;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusInfo["color"].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusInfo["color"].withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  statusInfo["icon"],
                  color: statusInfo["color"],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusInfo["label"],
                    style: TextStyle(
                      color: statusInfo["color"],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getServiceIcon(request.service.title),
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.service.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Quicksand',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Mã đơn: #${request.id.substring(0, 8)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontFamily: 'Quicksand',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  currencyFormat.format(request.totalCost),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontFamily: 'Quicksand',
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.person,
                  label: "Khách hàng",
                  value: request.customerInfo.fullName,
                ),
                _buildInfoRow(
                  icon: Icons.phone,
                  label: "Điện thoại",
                  value: request.customerInfo.phone,
                ),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: "Địa chỉ",
                  value: request.customerInfo.address,
                ),
                if (request.scheduleIds.length > 1)
                  _buildInfoRow(
                      icon: Icons.access_time,
                      label: "Ngày thực hiện",
                      value: '${formatDate(request.startTime)} - ${formatDate(request.endTime)}'),
                if (request.scheduleIds.length == 1)
                  _buildInfoRow(
                      icon: Icons.access_time,
                      label: "Ngày thực hiện",
                      value: '${formatDate(request.startTime)}'),
                _buildInfoRow(
                    icon: Icons.access_time,
                    label: "Thời gian",
                    value: '${formatTime(request.schedules.first.startTime)} - ${formatTime(request.schedules.first.endTime)}'),
                if (request.schedules.length > 1)
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: "Số ngày",
                    value: "${request.scheduleIds.length} ngày",
                    valueColor: Colors.blue[700],
                  ),
                const SizedBox(height: 16),
                _buildActionButtons(request, index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Quicksand',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
                fontSize: 16,
                fontFamily: 'Quicksand',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RequestHelper request, int index) {
    switch (request.schedules.first.status) {
      case "pending":
        if (assignedRequests.contains((req) =>
            req.schedules.first.status == 'inProgress' ||
            req.schedules.first.status == 'assigned' ||
            req.schedules.first.status == 'waitPayment')) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Bạn đã có công vi��c được giao, hoàn thành trước khi nhận việc mới",
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Expanded(
            //   child: OutlinedButton.icon(
            //     onPressed: () => _showRejectConfirmationDialog(request),
            //     icon: const Icon(Icons.close, size: 16, color: Colors.red),
            //     label: const Text(
            //       "Từ chối",
            //       style: TextStyle(
            //         fontFamily: 'Quicksand',
            //       ),
            //     ),
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: Colors.red,
            //       side: const BorderSide(color: Colors.red),
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAcceptConfirmationDialog(request),
                icon: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  "Nhận việc",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      case "assigned":
        return ElevatedButton.icon(
          onPressed: () => processingRequest(request, index),
          // icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text(
            "Bắt đầu làm việc",
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case "inProgress":
        return ElevatedButton.icon(
          onPressed: () => finishRequest(request, index),
          icon: const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.white,
          ),
          label: Text(
            "Xác nhận hoàn thành công việc",
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      case "waitPayment":
        return const SizedBox.shrink(); // Remove the "Xác nhận thanh toán" button
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showRejectConfirmationDialog(RequestHelper request) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận từ chối',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Bạn có chắc chắn muốn từ chối công việc n��y?',
                ),
                const SizedBox(height: 12),
                Text(
                  'Dịch vụ: ${request.service.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Khách hàng: ${request.customerInfo.fullName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'H��y',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Từ chối',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                // Get the navigator and scaffold messenger before async operation
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop();

                try {
                  await cancelRequest(request);

                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Đã từ chối công việc thành công'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Lỗi khi từ chối việc: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAcceptConfirmationDialog(RequestHelper request) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận nhận việc',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Bạn có chắc chắn muốn nhận công việc này?',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dịch vụ: ${request.service.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
                Text(
                  'Khách hàng: ${request.customerInfo.fullName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
                Text(
                  'Thời gian: ${DateFormat('dd/MM/yyyy').format(request.startTime)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Địa chỉ: ${request.customerInfo.address}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'Quicksand',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Nhận việc',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
              onPressed: () async {
                // Get the navigator and scaffold messenger before async operation
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop();

                try {
                  await assignedRequest(request);

                  // Check if widget is still mounted before showing snackbar
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Đã nhận công việc thành công',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                            )),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Lỗi khi nhận việc: $e',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                            )),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getServiceIcon(String serviceTitle) {
    // Map service titles to appropriate icons
    switch (serviceTitle.toLowerCase()) {
      case 'dọn dẹp nhà cửa':
      case 'dọn dẹp nhà':
      case 'vệ sinh nhà':
        return Icons.cleaning_services;
      case 'nấu ăn':
      case 'nấu ăn gia đình':
        return Icons.restaurant;
      case 'giặt ủi':
      case 'giặt đồ':
        return Icons.local_laundry_service;
      case 'chăm sóc người già':
      case 'chăm sóc người cao tuổi':
        return Icons.elderly;
      case 'chăm sóc trẻ em':
      case 'trông trẻ':
        return Icons.child_care;
      case 'chăm sóc thú cưng':
        return Icons.pets;
      default:
        return Icons.home_repair_service;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
