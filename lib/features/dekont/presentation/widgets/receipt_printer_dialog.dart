import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../data/models/transaction_dekont_data.dart';
import '../../services/dekont_calculator.dart';
import '../../services/dekont_share_service.dart';
import 'receipt_paper_widget.dart';

enum ReceiptPrinterStage { processing, printing, complete }

/// Interactive, mobile-first Receipt Printer Modal Dialog.
/// Features a realistic printer machine, paper feed animation, status screen,
/// real vector PDF generation, and native sharing.
class ReceiptPrinterDialog extends StatefulWidget {
  final CustomerModel customer;
  final TransactionModel transaction;
  final List<TransactionModel> allTransactions;
  final String languageCode;

  const ReceiptPrinterDialog({
    super.key,
    required this.customer,
    required this.transaction,
    required this.allTransactions,
    this.languageCode = 'ar',
  });

  static Future<void> show({
    required BuildContext context,
    required CustomerModel customer,
    required TransactionModel transaction,
    required List<TransactionModel> allTransactions,
    String languageCode = 'ar',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => ReceiptPrinterDialog(
        customer: customer,
        transaction: transaction,
        allTransactions: allTransactions,
        languageCode: languageCode,
      ),
    );
  }

  @override
  State<ReceiptPrinterDialog> createState() => _ReceiptPrinterDialogState();
}

class _ReceiptPrinterDialogState extends State<ReceiptPrinterDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _paperSlideAnimation;
  late final Animation<double> _paperOpacityAnimation;

  ReceiptPrinterStage _stage = ReceiptPrinterStage.processing;
  late final TransactionDekontData _dekontData;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    // Compute Dekont Data snapshot
    _dekontData = DekontCalculator.buildTransactionDekontData(
      customer: widget.customer,
      targetTransaction: widget.transaction,
      allTransactions: widget.allTransactions,
    );

    // Initialize animation controller (1.8 seconds paper feed)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _paperSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _paperOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _stage = ReceiptPrinterStage.complete;
          });
          HapticFeedback.mediumImpact();
        }
      }
    });

    _startPrintingSequence();
  }

  Future<void> _startPrintingSequence() async {
    // Check for reduced motion accessibility
    final mediaQuery = WidgetsBinding.instance.platformDispatcher.implicitView != null
        ? MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.implicitView!)
        : null;

    if (mediaQuery?.disableAnimations == true) {
      setState(() {
        _stage = ReceiptPrinterStage.complete;
      });
      _animationController.value = 1.0;
      return;
    }

    // Step 1: Processing delay (700ms)
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Step 2: Start printing
    setState(() {
      _stage = ReceiptPrinterStage.printing;
    });
    HapticFeedback.selectionClick();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSharePdf() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      await DekontShareService.shareTransactionDekont(
        context: context,
        customer: widget.customer,
        transaction: widget.transaction,
        allTransactions: widget.allTransactions,
        languageCode: widget.languageCode,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.languageCode == 'ar';
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark slate theme for printer machine
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle & Close Header
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance close icon space
                ],
              ),
            ),

            // Printer Machine Unit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildPrinterMachineHeader(isArabic),
            ),

            // Output Slot & Animating Paper
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: _stage == ReceiptPrinterStage.complete
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final slideVal = _paperSlideAnimation.value;
                      final opacityVal = _paperOpacityAnimation.value;

                      return FractionalTranslation(
                        translation: Offset(0, slideVal),
                        child: Opacity(
                          opacity: _stage == ReceiptPrinterStage.processing ? 0.0 : opacityVal,
                          child: child,
                        ),
                      );
                    },
                    child: ReceiptPaperWidget(
                      data: _dekontData,
                      isArabic: isArabic,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Share PDF Primary Button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _stage == ReceiptPrinterStage.complete && !_isSharing
                                ? _handleSharePdf
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white10,
                              disabledForegroundColor: Colors.white38,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: _isSharing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.share_rounded, size: 20),
                            label: Text(
                              _isSharing
                                  ? (isArabic ? 'جاري التجهيز...' : 'Preparing...')
                                  : (isArabic ? 'مشاركة الإيصال (PDF)' : 'Share Receipt (PDF)'),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterMachineHeader(bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Machine Title Bar & Screen
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _stage == ReceiptPrinterStage.complete
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_stage == ReceiptPrinterStage.complete
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SAMI PRINTER X1',
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(isArabic),
            ],
          ),

          const SizedBox(height: 14),

          // Thermal Exit Slot Slit
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF090D16),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFF334155), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isArabic) {
    String label;
    IconData icon;
    Color color;

    switch (_stage) {
      case ReceiptPrinterStage.processing:
        label = isArabic ? 'جاري التجهيز...' : 'Preparing...';
        icon = Icons.hourglass_top_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case ReceiptPrinterStage.printing:
        label = isArabic ? 'جاري الطباعة...' : 'Printing...';
        icon = Icons.print_rounded;
        color = const Color(0xFF3B82F6);
        break;
      case ReceiptPrinterStage.complete:
        label = isArabic ? 'الإيصال جاهز' : 'Receipt Ready';
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF22C55E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_stage == ReceiptPrinterStage.processing || _stage == ReceiptPrinterStage.printing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
