import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/account_statement_data.dart';
import '../data/models/transaction_dekont_data.dart';

/// Professional PDF Generator for Account Statements and Transaction Dekonts
class PdfDekontGenerator {
  PdfDekontGenerator._();

  // Colors
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF1A56DB);
  static const PdfColor darkHeader = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor debtRed = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor paymentGreen = PdfColor.fromInt(0xFF16A34A);
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor cardBorder = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF64748B);
  static const String _pdfCurrency = 'TL';

  static pw.Font? _cachedRegularFont;
  static pw.Font? _cachedBoldFont;

  /// Load Arabic-compatible font (Cairo) with cache & timeout
  static Future<pw.Font> _loadRegularFont() async {
    if (_cachedRegularFont != null) return _cachedRegularFont!;
    try {
      _cachedRegularFont = await PdfGoogleFonts.cairoRegular().timeout(const Duration(seconds: 8));
      return _cachedRegularFont!;
    } catch (_) {
      try {
        _cachedRegularFont = await PdfGoogleFonts.amiriRegular().timeout(const Duration(seconds: 5));
        return _cachedRegularFont!;
      } catch (_) {
        return pw.Font.helvetica();
      }
    }
  }

  static Future<pw.Font> _loadBoldFont() async {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    try {
      _cachedBoldFont = await PdfGoogleFonts.cairoBold().timeout(const Duration(seconds: 8));
      return _cachedBoldFont!;
    } catch (_) {
      try {
        _cachedBoldFont = await PdfGoogleFonts.amiriBold().timeout(const Duration(seconds: 5));
        return _cachedBoldFont!;
      } catch (_) {
        return pw.Font.helveticaBold();
      }
    }
  }

  /// Try loading SAMI MARKET logo from assets
  static Future<pw.MemoryImage?> _loadLogoImage() async {
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────
  // 1. ACCOUNT STATEMENT PDF (Multi-page supported)
  // ─────────────────────────────────────────────────────────

  static Future<Uint8List> generateAccountStatement({
    required AccountStatementData data,
    String languageCode = 'ar',
  }) async {
    final isArabic = languageCode == 'ar';
    final regularFont = await _loadRegularFont();
    final boldFont = await _loadBoldFont();
    final logoImage = await _loadLogoImage();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
      ),
    );

    final textDir = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    // Formatted date string
    final dateStr = _formatDateTime(data.generatedAt, isArabic);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: textDir,
        header: (context) => _buildStatementHeader(
          data: data,
          logoImage: logoImage,
          isArabic: isArabic,
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        footer: (context) => _buildFooter(
          marketName: data.marketName,
          isArabic: isArabic,
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount,
        ),
        build: (context) => [
          pw.SizedBox(height: 10),

          // Customer Info & Summary Boxes
          _buildCustomerAndSummarySection(
            data: data,
            dateStr: dateStr,
            isArabic: isArabic,
          ),

          pw.SizedBox(height: 16),

          // Transactions Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: cardBorder),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  isArabic ? 'سجل العمليات المالية' : 'Transaction History',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: darkHeader,
                  ),
                ),
                pw.Text(
                  '(${data.transactions.length} ${isArabic ? "عملية" : "records"})',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // Transactions Table
          if (data.transactions.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              alignment: pw.Alignment.center,
              child: pw.Text(
                isArabic
                    ? 'لا توجد عمليات مسجلة حتى الآن.'
                    : 'No transactions registered yet.',
                style: const pw.TextStyle(color: textMuted, fontSize: 11),
              ),
            )
          else
            _buildTransactionsTable(
              transactions: data.transactions,
              isArabic: isArabic,
            ),

          pw.SizedBox(height: 16),

          // Notes / Status Note
          _buildStatementStatusNote(
            isFullyPaid: data.isFullyPaid,
            remainingDebt: data.remainingDebt,
            isArabic: isArabic,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────
  // 2. TRANSACTION DEKONT / RECEIPT PDF
  // ─────────────────────────────────────────────────────────

  static Future<Uint8List> generateTransactionDekont({
    required TransactionDekontData data,
    String languageCode = 'ar',
  }) async {
    final isArabic = languageCode == 'ar';
    final regularFont = await _loadRegularFont();
    final boldFont = await _loadBoldFont();
    final logoImage = await _loadLogoImage();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
      ),
    );

    final textDir = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final tx = data.transaction;
    final isDebt = tx.isDebt;
    final txColor = isDebt ? debtRed : paymentGreen;
    final txTitle = isDebt
        ? (isArabic ? 'إشعار تسجيل دين' : 'Debt Transaction')
        : (isArabic ? 'إشعار تسجيل دفعة / قبض' : 'Payment Receipt');

    final dateFormatted = _formatDate(tx.createdAt, isArabic);
    final timeFormatted = _formatTime(tx.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        textDirection: textDir,
        build: (context) => pw.Directionality(
          textDirection: textDir,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
              border: pw.Border.all(color: cardBorder, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Top Header with Logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 55,
                        height: 55,
                        child: pw.Image(logoImage),
                      )
                    else
                      pw.Container(
                        width: 50,
                        height: 50,
                        decoration: const pw.BoxDecoration(
                          color: primaryBlue,
                          shape: pw.BoxShape.circle,
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'SM',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          data.marketName,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 22,
                            color: primaryBlue,
                            letterSpacing: 1.2,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: pw.BoxDecoration(
                            color: primaryBlue,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                          ),
                          child: pw.Text(
                            'DEKONT / ${isArabic ? "إشعار مالي" : "RECEIPT"}',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          isArabic ? 'رقم العملية:' : 'Ref No:',
                          style: const pw.TextStyle(color: textMuted, fontSize: 9),
                        ),
                        pw.Text(
                          data.referenceNumber,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                            color: darkHeader,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(color: cardBorder, thickness: 1.5),
                pw.SizedBox(height: 16),

                // Customer Info Banner
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    border: pw.Border.all(color: cardBorder),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            isArabic ? 'اسم الزبون' : 'Customer Name',
                            style: const pw.TextStyle(color: textMuted, fontSize: 10),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            data.customer.name,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: darkHeader,
                            ),
                          ),
                        ],
                      ),
                      if (data.customer.customerCode.isNotEmpty)
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              isArabic ? 'رمز الزبون' : 'Customer Code',
                              style: const pw.TextStyle(color: textMuted, fontSize: 10),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '#${data.customer.customerCode}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 13,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            isArabic ? 'التاريخ والوقت' : 'Date & Time',
                            style: const pw.TextStyle(color: textMuted, fontSize: 10),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '$dateFormatted - $timeFormatted',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: darkHeader,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Main Transaction Detail Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(18),
                  decoration: pw.BoxDecoration(
                    color: isDebt ? const PdfColor.fromInt(0xFFFEF2F2) : const PdfColor.fromInt(0xFFF0FDF4),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    border: pw.Border.all(color: txColor, width: 1.5),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                isArabic ? 'نوع العملية' : 'Transaction Type',
                                style: const pw.TextStyle(color: textMuted, fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                txTitle,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 15,
                                  color: txColor,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                isArabic ? 'المبلغ' : 'Amount',
                                style: const pw.TextStyle(color: textMuted, fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '${isDebt ? "+" : "-"}${_formatCurrency(tx.amount)} $_pdfCurrency',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 22,
                                  color: txColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (tx.description.isNotEmpty) ...[
                        pw.SizedBox(height: 12),
                        pw.Divider(color: cardBorder),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              isArabic ? 'البيان / الوصف: ' : 'Description: ',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                                color: textMuted,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                tx.description,
                                style: const pw.TextStyle(fontSize: 11, color: darkHeader),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Financial Balance Flow Calculation Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    border: pw.Border.all(color: cardBorder),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text(
                        isArabic ? 'تفاصيل تسوية الرصيد' : 'Balance Settlement Flow',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: darkHeader,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      _buildBalanceRow(
                        label: isArabic ? 'الدين قبل العملية:' : 'Debt Before Transaction:',
                        value: '${_formatCurrency(data.beforeBalance)} $_pdfCurrency',
                        isArabic: isArabic,
                      ),
                      pw.SizedBox(height: 6),
                      _buildBalanceRow(
                        label: isDebt
                            ? (isArabic ? 'قيمة الدين المضاف (+):' : 'Added Debt (+):')
                            : (isArabic ? 'المبلغ المسدد (-):' : 'Paid Amount (-):'),
                        value: '${isDebt ? "+" : "-"}${_formatCurrency(tx.amount)} $_pdfCurrency',
                        valueColor: txColor,
                        isArabic: isArabic,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Divider(color: cardBorder),
                      pw.SizedBox(height: 6),
                      _buildBalanceRow(
                        label: isArabic ? 'الدين المتبقي بعد العملية:' : 'Remaining Debt After:',
                        value: '${_formatCurrency(data.afterBalance)} $_pdfCurrency',
                        isBold: true,
                        valueColor: data.afterBalance > 0 ? debtRed : paymentGreen,
                        isArabic: isArabic,
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Bottom Legal / Thank you section
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        isArabic ? 'شكراً لتعاملكم مع سامي ماركت' : 'Thank you for choosing SAMI MARKET',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: primaryBlue,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        isArabic
                            ? 'هذا المستند تم استخراجه إلكترونياً من تطبيق SAMI MARKET'
                            : 'This document was electronically generated from SAMI MARKET app',
                        style: const pw.TextStyle(fontSize: 8, color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────────────────

  static pw.Widget _buildStatementHeader({
    required AccountStatementData data,
    required pw.MemoryImage? logoImage,
    required bool isArabic,
    required int pageNumber,
    required int totalPages,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: cardBorder, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              if (logoImage != null)
                pw.Container(
                  width: 44,
                  height: 44,
                  margin: const pw.EdgeInsets.only(left: 8),
                  child: pw.Image(logoImage),
                )
              else
                pw.Container(
                  width: 40,
                  height: 40,
                  margin: const pw.EdgeInsets.only(left: 8),
                  decoration: const pw.BoxDecoration(
                    color: primaryBlue,
                    shape: pw.BoxShape.circle,
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'SM',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    data.marketName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                      color: primaryBlue,
                    ),
                  ),
                  pw.Text(
                    isArabic ? 'كشف حساب الزبون' : 'Customer Account Statement',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: darkHeader,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '${isArabic ? "رقم الكشف:" : "Statement Ref:"} ${data.statementNumber}',
                style: const pw.TextStyle(color: textMuted, fontSize: 9),
              ),
              pw.Text(
                '${isArabic ? "صفحة" : "Page"} $pageNumber / $totalPages',
                style: const pw.TextStyle(color: textMuted, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerAndSummarySection({
    required AccountStatementData data,
    required String dateStr,
    required bool isArabic,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: Customer Info Card
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: cardBorder),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isArabic ? 'معلومات الزبون' : 'Customer Details',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: primaryBlue,
                  ),
                ),
                pw.SizedBox(height: 6),
                _buildInfoLine(
                  label: isArabic ? 'الاسم:' : 'Name:',
                  value: data.customer.name,
                ),
                if (data.customer.customerCode.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  _buildInfoLine(
                    label: isArabic ? 'الرمز:' : 'Code:',
                    value: '#${data.customer.customerCode}',
                  ),
                ],
                if (data.customer.phone.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  _buildInfoLine(
                    label: isArabic ? 'الهاتف:' : 'Phone:',
                    value: data.customer.phone,
                  ),
                ],
                pw.SizedBox(height: 4),
                _buildInfoLine(
                  label: isArabic ? 'تاريخ التقرير:' : 'Date:',
                  value: dateStr,
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 12),

        // Right: Financial Summary Totals Card
        pw.Expanded(
          flex: 6,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: cardBorder),
            ),
            child: pw.Column(
              children: [
                _buildSummaryRow(
                  label: isArabic ? 'إجمالي الديون:' : 'Total Debts:',
                  value: '${_formatCurrency(data.totalDebts)} $_pdfCurrency',
                  valueColor: debtRed,
                ),
                pw.SizedBox(height: 6),
                _buildSummaryRow(
                  label: isArabic ? 'إجمالي الدفعات:' : 'Total Payments:',
                  value: '${_formatCurrency(data.totalPayments)} $_pdfCurrency',
                  valueColor: paymentGreen,
                ),
                pw.SizedBox(height: 6),
                pw.Divider(color: cardBorder),
                pw.SizedBox(height: 6),
                _buildSummaryRow(
                  label: isArabic ? 'الدين المتبقي:' : 'Remaining Debt:',
                  value: '${_formatCurrency(data.remainingDebt)} $_pdfCurrency',
                  valueColor: data.remainingDebt > 0 ? debtRed : paymentGreen,
                  isBold: true,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTransactionsTable({
    required List<dynamic> transactions,
    required bool isArabic,
  }) {
    final headers = isArabic
        ? ['التاريخ', 'النوع', 'الوصف / التفاصيل', 'المبلغ ($_pdfCurrency)']
        : ['Date', 'Type', 'Description', 'Amount ($_pdfCurrency)'];

    return pw.Table(
      border: pw.TableBorder.all(color: cardBorder, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.2), // Date
        1: const pw.FlexColumnWidth(1.8), // Type
        2: const pw.FlexColumnWidth(4.0), // Description
        3: const pw.FlexColumnWidth(2.2), // Amount
      },
      children: [
        // Header Row
        pw.TableRow(
          repeat: true,
          decoration: const pw.BoxDecoration(color: lightBg),
          children: headers.map((h) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: pw.Text(
                h,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: darkHeader,
                ),
                textAlign: pw.TextAlign.center,
              ),
            );
          }).toList(),
        ),

        // Data Rows
        ...transactions.map((tx) {
          final isDebt = tx.isDebt;
          final color = isDebt ? debtRed : paymentGreen;
          final typeText = isDebt
              ? (isArabic ? 'دين' : 'Debt')
              : (isArabic ? 'دفعة' : 'Payment');
          final dateText = _formatDate(tx.createdAt, isArabic);

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: pw.Text(
                  dateText,
                  style: const pw.TextStyle(fontSize: 8, color: textMuted),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: pw.Text(
                  typeText,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: pw.Text(
                  tx.description.isNotEmpty ? tx.description : '-',
                  style: const pw.TextStyle(fontSize: 8, color: darkHeader),
                  maxLines: 2,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: pw.Text(
                  '${isDebt ? "+" : "-"}${_formatCurrency(tx.amount)} $_pdfCurrency',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildStatementStatusNote({
    required bool isFullyPaid,
    required double remainingDebt,
    required bool isArabic,
  }) {
    if (isFullyPaid) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFDCFCE7),
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        alignment: pw.Alignment.center,
        child: pw.Text(
          isArabic ? 'الحساب مسدد بالكامل — لا توجد ديون متبقية' : 'Account fully paid — No remaining debt',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: paymentGreen,
            fontSize: 11,
          ),
        ),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: cardBorder),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            isArabic ? 'يرجى مراجعة الرصيد المتبقي أعلاه وتسديده في أقرب وقت.' : 'Please review and settle the remaining balance.',
            style: const pw.TextStyle(fontSize: 9, color: textMuted),
          ),
          pw.Text(
            '${_formatCurrency(remainingDebt)} $_pdfCurrency',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: debtRed),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter({
    required String marketName,
    required bool isArabic,
    required int pageNumber,
    required int totalPages,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: cardBorder, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$marketName — ${isArabic ? "شكراً لتعاملكم معنا" : "Thank you for your business"}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: primaryBlue),
          ),
          pw.Text(
            'SAMI MARKET SYSTEM',
            style: const pw.TextStyle(fontSize: 8, color: textMuted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoLine({required String label, required String value}) {
    return pw.Row(
      children: [
        pw.Text(label, style: const pw.TextStyle(color: textMuted, fontSize: 9)),
        pw.SizedBox(width: 4),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: darkHeader)),
      ],
    );
  }

  static pw.Widget _buildSummaryRow({
    required String label,
    required String value,
    PdfColor? valueColor,
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: isBold ? darkHeader : textMuted,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: valueColor ?? darkHeader,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBalanceRow({
    required String label,
    required String value,
    PdfColor? valueColor,
    bool isBold = false,
    required bool isArabic,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: isBold ? darkHeader : textMuted,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isBold ? 11 : 10,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: valueColor ?? darkHeader,
            fontSize: isBold ? 13 : 11,
          ),
        ),
      ],
    );
  }

  static String _formatCurrency(double amount) {
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }

  static String _formatDate(DateTime dt, bool isArabic) {
    final localDt = dt.toLocal();
    return '${localDt.year}/${localDt.month.toString().padLeft(2, '0')}/${localDt.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    return '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dt, bool isArabic) {
    return '${_formatDate(dt, isArabic)} ${_formatTime(dt)}';
  }
}
