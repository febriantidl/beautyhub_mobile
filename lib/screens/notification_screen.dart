import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await ApiService.getNotifications();
      if (result['success'] == true) {
        setState(() => _notifications = result['data'] ?? []);
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isLoading = false);
    }
  }

  IconData _getIcon(String? type) {
    if (type == 'booking_approved') return Icons.check_circle;
    if (type == 'booking_rejected') return Icons.cancel;
    return Icons.notifications;
  }

  Color _getColor(String? type) {
    if (type == 'booking_approved') return Colors.green;
    if (type == 'booking_rejected') return Colors.red;
    return const Color(0xFFCF4C4C);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Notifikasi',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4D0012),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFCF4C4C)))
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada notifikasi',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xFFCF4C4C),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final type = notif['type'] ?? '';
                      final isRead = notif['read_at'] != null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isRead
                              ? Colors.white
                              : const Color(0xFFCF4C4C)
                                  .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: isRead
                              ? null
                              : Border.all(
                                  color: const Color(0xFFCF4C4C)
                                      .withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getColor(type)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(type),
                              color: _getColor(type),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            notif['data']?['title'] ??
                                notif['title'] ??
                                'Notifikasi',
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notif['data']?['message'] ??
                                    notif['message'] ??
                                    '',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif['created_at'] ?? '',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: isRead
                              ? null
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFCF4C4C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}