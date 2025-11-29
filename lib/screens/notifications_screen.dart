import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'title': 'Đơn hàng đã được xác nhận', 'message': 'Đơn hàng #ORD123456 đã được xác nhận và đang chuẩn bị', 'time': '2 giờ trước', 'type': 'order', 'read': false},
      {'title': 'Flash Sale bắt đầu!', 'message': 'Giảm giá đến 50% cho tất cả sản phẩm điện tử', 'time': '5 giờ trước', 'type': 'promo', 'read': false},
      {'title': 'Đơn hàng đang giao', 'message': 'Đơn hàng #ORD123455 đang trên đường giao đến bạn', 'time': '1 ngày trước', 'type': 'order', 'read': true},
      {'title': 'Mã giảm giá mới', 'message': 'Bạn nhận được mã SAVE20 giảm 20% cho đơn tiếp theo', 'time': '2 ngày trước', 'type': 'promo', 'read': true},
      {'title': 'Đánh giá sản phẩm', 'message': 'Hãy đánh giá sản phẩm bạn vừa mua để nhận 50 điểm', 'time': '3 ngày trước', 'type': 'review', 'read': true},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Đọc tất cả')),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Không có thông báo', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) => _buildNotificationItem(notifications[i], i),
            ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    IconData icon;
    Color color;
    switch (notification['type']) {
      case 'order': icon = Icons.local_shipping; color = Colors.blue; break;
      case 'promo': icon = Icons.local_offer; color = Colors.orange; break;
      case 'review': icon = Icons.star; color = Colors.amber; break;
      default: icon = Icons.notifications; color = Colors.grey;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (_, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(50 * (1 - value), 0), child: child)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: notification['read'] ? Colors.white : AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notification['read'] ? Colors.grey[200]! : AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          title: Text(notification['title'], style: TextStyle(fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification['message'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 4),
              Text(notification['time'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          trailing: !notification['read'] ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)) : null,
        ),
      ),
    );
  }
}
