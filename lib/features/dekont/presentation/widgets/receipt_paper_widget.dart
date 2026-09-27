import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/transaction_dekont_data.dart';
import 'receipt_teeth_clipper.dart';

/// Styled mobile-first authentic thermal receipt paper widget.
class ReceiptPaperWidget extends StatelessWidget {
  final TransactionDekontData data;
  final bool isArabic;

  const ReceiptPaperWidget({
    super.key,
    required this.data,
    this.isArabic = true,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', isArabic ? 'ar' : 'en');
    return '${formatter.format(amount)} ₺';
  }

  String _formatDateTime(DateTime date) {
    final localDate = date.toLocal();
    final dateFormatter = DateFormat('yyyy/MM/dd', isArabic ? 'ar' : 'en');
    final timeFormatter = DateFormat('hh:mm a', isArabic ? 'ar' : 'en');
    return '${dateFormatter.format(localDate)} - ${timeFormatter.format(localDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final tx = data.transaction;
    final isDebt = tx.isDebt;
    final primaryColor = isDebt ? AppColors.debt : AppColors.payment;
    final statusBgColor = isDebt ? AppColors.debtLight : AppColors.paymentLight;

    return ClipPath(
      clipper: const ReceiptTeethClipper(toothWidth: 12.0, toothDepth: 6.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Store / App Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.marketName,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isArabic ? 'إشعار عملية مالية (Dekont)' : 'Financial Dekont Receipt',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.referenceNumber,
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildDashedLine(),
            const SizedBox(height: 16),

            // Metadata: Customer & Date
            _buildDataRow(
              label: isArabic ? 'التاريخ والوقت' : 'Date & Time',
              value: _formatDateTime(tx.createdAt),
              isBold: false,
            ),
            const SizedBox(height: 8),
            _buildDataRow(
              label: isArabic ? 'اسم الزبون' : 'Customer Name',
              value: data.customer.name,
              isBold: true,
            ),
            if (data.customer.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDataRow(
                label: isArabic ? 'رقم الهاتف' : 'Phone',
                value: data.customer.phone,
                isBold: false,
              ),
            ],

            const SizedBox(height: 12),

            // Transaction Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'نوع العملية' : 'Transaction Type',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        isDebt ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                        size: 12,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDebt
                            ? (isArabic ? 'تسجيل دين (+)' : 'Debt (+)')
                            : (isArabic ? 'سداد دفعة (-)' : 'Payment (-)'),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildDashedLine(),
            const SizedBox(height: 16),

            // Financial Summary Block
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic ? 'مبلغ العملية' : 'Transaction Amount',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatAmount(tx.amount),
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, thickness: 1),
                  _buildDataRow(
                    label: isArabic ? 'الرصيد السابق' : 'Previous Balance',
                    value: _formatAmount(data.beforeBalance),
                    valueColor: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  _buildDataRow(
                    label: isArabic ? 'الرصide المتبقي الحالي' : 'Current Balance',
                    value: _formatAmount(data.afterBalance),
                    isBold: true,
                    valueColor: data.afterBalance > 0
                        ? AppColors.debt
                        : (data.afterBalance < 0 ? AppColors.payment : AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            // Notes Section (if available)
            if (tx.description.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'ملاحظات:' : 'Notes:',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.description,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),
            _buildDashedLine(),
            const SizedBox(height: 14),

            // Barcode & Footer
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      24,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: (index % 3 == 0) ? 3 : (index % 2 == 0 ? 2 : 1),
                        height: 24,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? 'شكراً لتعاملكم معنا' : 'Thank you for your business',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        const dashWidth = 6.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade400),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDataRow({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
