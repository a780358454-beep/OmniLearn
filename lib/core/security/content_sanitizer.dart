/// فلتر الأمان وتطهير المدخلات لمنع حقن السكربتات وعرض الأكواد البرمجية بأمان
class ContentSanitizer {
  static final RegExp _dangerousTagPattern = RegExp(
    r'<\s*(script|iframe|object|embed|applet|meta|link|style)[^>]*>.*?<\s*/\s*\1\s*>|<\s*(script|iframe|object|embed|applet|meta|link|style)[^>]*>',
    caseSensitive: false,
    multiLine: true,
    dotAll: true,
  );

  static final RegExp _dangerousAttrPattern = RegExp(
    r'\b(on\w+|javascript:|vbscript:|data:text/html)\s*=',
    caseSensitive: false,
  );

  /// تطهير النصوص العادية والمقالات لمنع أي هجمات XSS أو سكربتات خبيثة
  static String sanitizeText(String? input) {
    if (input == null || input.isEmpty) return '';
    
    // إزالة تاغات السكربتات والتضمين الخطرة
    var sanitized = input.replaceAll(_dangerousTagPattern, '');
    
    // تحييد السمات التفاعلية الخطرة مثل onerror أو onclick
    sanitized = sanitized.replaceAll(_dangerousAttrPattern, 'blocked_attr=');
    
    return sanitized.trim();
  }

  /// تنقية نصوص الأكواد البرمجية لضمان سلامة العرض كـ Read-Only Monospace
  static String sanitizeCode(String? code) {
    if (code == null || code.isEmpty) return '';
    // إزالة الأحرف الصفرية وأكواد التحكم الطرفية غير المرئية مع الحفاظ على المسافات والأسطر
    return code.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
  }

  /// التحقق السريع من سلامة النص وخلوه من السكربتات المشبوهة
  static bool isSafe(String? input) {
    if (input == null || input.isEmpty) return true;
    return !_dangerousTagPattern.hasMatch(input) && !_dangerousAttrPattern.hasMatch(input);
  }
}
