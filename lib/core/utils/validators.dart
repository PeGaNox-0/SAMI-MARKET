/// Input validators and security sanitizers for forms
class Validators {
  Validators._();

  /// Maximum transaction amount allowed in a single operation
  static const double maxTransactionAmount = 5000000.00;

  /// Sanitize text inputs by trimming and removing dangerous control characters
  static String sanitize(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '') // Remove non-printable control chars
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize multiple spaces
  }

  /// Validate required field
  static String? required(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || sanitize(value).isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final clean = value.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(clean) || clean.length > 254) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  /// Validate monetary amount — must be > 0 and <= maxTransactionAmount
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'المبلغ مطلوب';
    }
    final cleaned = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) {
      return 'يرجى إدخال مبلغ صالح أكبر من الصفر';
    }
    if (parsed > maxTransactionAmount) {
      return 'المبلغ يتجاوز الحد الأقصى المسموح به (5,000,000 ₺)';
    }
    return null;
  }

  /// Validate payment doesn't exceed debt
  static String? paymentAmount(String? value, double currentDebt) {
    final baseValidation = amount(value);
    if (baseValidation != null) return baseValidation;

    final cleaned = value!.trim().replaceAll(',', '.');
    final payment = double.tryParse(cleaned)!;
    if (payment > (currentDebt + 0.01)) {
      return 'الدفعة لا يمكن أن تتجاوز الدين المتبقي';
    }
    return null;
  }

  /// Validate phone number (optional, but if provided must be valid digits)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // phone is optional
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 7 || cleaned.length > 16 || !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  /// Validate PIN
  static String? pin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الشيفرة مطلوبة';
    }
    final clean = value.trim();
    if (clean.length < 4 || clean.length > 8 || !RegExp(r'^\d+$').hasMatch(clean)) {
      return 'الشيفرة يجب أن تكون بين 4 و 8 أرقام';
    }
    return null;
  }
}
