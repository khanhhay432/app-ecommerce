import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'Làm sao để đặt hàng?', 'a': 'Bạn chọn sản phẩm, thêm vào giỏ hàng, sau đó tiến hành thanh toán và điền thông tin giao hàng.'},
      {'q': 'Thời gian giao hàng bao lâu?', 'a': 'Thời gian giao hàng từ 2-5 ngày tùy khu vực. Nội thành HCM và Hà Nội giao trong 1-2 ngày.'},
      {'q': 'Chính sách đổi trả như thế nào?', 'a': 'Bạn có thể đổi trả trong vòng 7 ngày kể từ ngày nhận hàng nếu sản phẩm còn nguyên tem mác.'},
      {'q': 'Làm sao để sử dụng mã giảm giá?', 'a': 'Nhập mã giảm giá tại trang thanh toán và nhấn "Áp dụng" để được giảm giá.'},
      {'q': 'Phương thức thanh toán nào được hỗ trợ?', 'a': 'Chúng tôi hỗ trợ COD, chuyển khoản ngân hàng, và các ví điện tử phổ biến.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContactCard(context),
          const SizedBox(height: 24),
          const Text('Câu hỏi thường gặp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...faqs.map((faq) => _buildFaqItem(faq['q']!, faq['a']!)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showChatDialog(context),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat với chúng tôi'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.support_agent, size: 60, color: AppTheme.primaryColor),
            const SizedBox(height: 12),
            const Text('Cần hỗ trợ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Liên hệ với chúng tôi qua các kênh sau', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactButton(Icons.phone, 'Hotline', () {}),
                _buildContactButton(Icons.email, 'Email', () {}),
                _buildContactButton(Icons.chat, 'Chat', () => _showChatDialog(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Builder(
              builder: (context) => Text(answer, style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chat hỗ trợ'),
        content: const Text('Tính năng chat đang được phát triển. Vui lòng liên hệ hotline 1900-xxxx để được hỗ trợ.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
      ),
    );
  }
}
