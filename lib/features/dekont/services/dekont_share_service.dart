import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/transaction_model.dart';
import 'dekont_calculator.dart';
import 'pdf_dekont_generator.dart';

import '../presentation/widgets/receipt_printer_dialog.dart';

/// Service responsible for generating PDF documents and triggering native Android share sheet
class DekontShareService {
  DekontShareService._();

  /// Open interactive mobile Receipt Printer Modal for a single transaction
  static Future<void> showReceiptPrinter({
    required BuildContext context,
    required CustomerModel customer,
    required TransactionModel transaction,
    required List<TransactionModel> allTransactions,
    String languageCode = 'ar',
  }) async {
    await ReceiptPrinterDialog.show(
      context: context,
      customer: customer,
      transaction: transaction,
      allTransactions: allTransactions,
      languageCode: languageCode,
    );
  }

  /// Generate and share customer account statement PDF
  static Future<bool> shareAccountStatement({
    required BuildContext context,
    required CustomerModel customer,
    required List<TransactionModel> transactions,
    String languageCode = 'ar',
  }) async {
    try {
      HapticFeedback.lightImpact();

      // 1. Build snapshot data
      final statementData = DekontCalculator.buildStatementData(
        customer: customer,
        transactions: transactions,
      );

      // 2. Generate PDF bytes
      final pdfBytes = await PdfDekontGenerator.generateAccountStatement(
        data: statementData,
        languageCode: languageCode,
      );

      // 3. Save to temporary directory with clean safe name
      final tempDir = await getTemporaryDirectory();
      final safeCustomerName = customer.name
          .trim()
          .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF-]'), '')
          .replaceAll(' ', '_');
      final dateTag = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'SAMI_MARKET_Statement_${safeCustomerName}_$dateTag.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);

      // 4. Trigger native share sheet
      final isArabic = languageCode == 'ar';
      final shareText = isArabic
          ? 'كشف حساب الزبون: ${customer.name} — سامي ماركت (SAMI MARKET)'
          : 'Customer Account Statement: ${customer.name} — SAMI MARKET';

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        subject: shareText,
        text: shareText,
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error generating or sharing account statement: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر إنشاء كشف الحساب. يرجى المحاولة لاحقاً.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      return false;
    }
  }

  /// Generate and share single transaction Dekont receipt PDF
  static Future<bool> shareTransactionDekont({
    required BuildContext context,
    required CustomerModel customer,
    required TransactionModel transaction,
    required List<TransactionModel> allTransactions,
    String languageCode = 'ar',
  }) async {
    try {
      HapticFeedback.lightImpact();

      // 1. Build snapshot data with before/after balance calculation
      final dekontData = DekontCalculator.buildTransactionDekontData(
        customer: customer,
        targetTransaction: transaction,
        allTransactions: allTransactions,
      );

      // 2. Generate PDF bytes
      final pdfBytes = await PdfDekontGenerator.generateTransactionDekont(
        data: dekontData,
        languageCode: languageCode,
      );

      // 3. Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'SAMI_MARKET_Dekont_${dekontData.referenceNumber}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);

      // 4. Trigger native share sheet
      final isArabic = languageCode == 'ar';
      final txTypeLabel = transaction.isDebt
          ? (isArabic ? 'دين' : 'Debt')
          : (isArabic ? 'دفعة' : 'Payment');
      final shareText = isArabic
          ? 'إشعار $txTypeLabel (${dekontData.referenceNumber}) — ${customer.name} — SAMI MARKET'
          : 'Dekont $txTypeLabel (${dekontData.referenceNumber}) — ${customer.name} — SAMI MARKET';

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        subject: shareText,
        text: shareText,
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error generating or sharing transaction dekont: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر إنشاء إشعار العملية (Dekont). حاول مرة أخرى.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
      return false;
    }
  }
}
