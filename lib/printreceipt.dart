class PrintReceipt {
  static String _formatCurrency(String value) {
    if (value.isEmpty || value == '0') return '0';
    
    String cleanValue = value.replaceAll(',', '');
    
    try {
      double amount = double.parse(cleanValue);
      return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return value;
    }
  }

  static String generateReceipt(String amount) {
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    
    String receiptText = '''
=====================================
          tom store
=====================================
address: vientiane, laos
tel: +856 20 xxxxxxx
email: info@p10store.la

date: $dateStr          time: $timeStr
receipt no: pos${now.millisecondsSinceEpoch.toString().substring(8)}

-------------------------------------
transaction details
-------------------------------------
description:           sale transaction
amount:                lak ${_formatCurrency(amount)}

=====================================
        ຂອບໃຈທີ່ມາຊື້ເຄື່ອງ!
       thank you for shopping!
=====================================
   customer service: +856 20 xxxxxxx
    visit us: www.p10store.la
=====================================

cashier: pos terminal
transaction id: t${now.millisecondsSinceEpoch}

please keep this receipt for your records
valid for returns within 7 days

=====================================
''';
    
    // Ensure all text is lowercase except Lao text and symbols
    return receiptText.toLowerCase().replaceAll('ຂອບໃຈທີ່ມາຊື້ເຄື່ອງ!', 'ຂອບໃຈທີ່ມາຊື້ເຄື່ອງ!');
  }
}