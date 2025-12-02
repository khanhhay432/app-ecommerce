import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';
import '../utils/currency_format.dart' as currency;

class PdfService {
  static Future<void> generateOrderPdf(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'HÓA ĐƠN ĐẶT HÀNG',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Order info
              pw.Text('Mã đơn hàng: ${order.id}'),
              pw.Text('Ngày đặt: ${_formatDate(order.createdAt)}'),
              pw.Text('Trạng thái: ${_getStatusText(order.status)}'),
              pw.SizedBox(height: 20),
              
              // Shipping info
              pw.Text(
                'THÔNG TIN GIAO HÀNG',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Người nhận: ${order.shippingName}'),
              pw.Text('Số điện thoại: ${order.shippingPhone}'),
              pw.Text('Địa chỉ: ${order.shippingAddress}'),
              pw.SizedBox(height: 20),
              
              // Items table
              pw.Text(
                'CHI TIẾT ĐƠN HÀNG',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Sản phẩm', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Số lượng', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Đơn giá', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Thành tiền', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Items
                  ...order.items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.product.name),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${item.quantity}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(currency.formatCurrency(item.product.price)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(currency.formatCurrency(item.subtotal)),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Tạm tính: ${currency.formatCurrency(order.subtotal)}'),
                    if (order.discount > 0)
                      pw.Text('Giảm giá: -${currency.formatCurrency(order.discount)}'),
                    pw.Text('Phí vận chuyển: ${currency.formatCurrency(order.shippingFee)}'),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Tổng cộng: ${currency.formatCurrency(order.total)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'SHIPPING':
        return 'Đang giao';
      case 'DELIVERED':
        return 'Đã giao';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
