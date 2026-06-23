import 'package:flutter/material.dart';
import 'cms_service.dart';
import 'lms_service.dart';

class AuthService extends ChangeNotifier {
  final CmsService _cmsService = CmsService();
  final LmsService _lmsService = LmsService();

  bool _isLoading = false;
  String? _studentName;
  String? _enrollmentNumber;

  bool get isLoading => _isLoading;
  String? get studentName => _studentName;
  String? get enrollmentNumber => _enrollmentNumber;

  CmsService get cms => _cmsService;
  LmsService get lms => _lmsService;

  /// Handshakes across CMS and spins up matching active sessions over LMS
  Future<bool> authenticateStudent(String enrollment, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1 & 2: Log into CMS
      final cmsSuccess = await _cmsService.login(enrollment, password);
      if (!cmsSuccess) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 3: Snag the passing transition verification payload URL
      final transitionUrl = await _cmsService.getLmsTransitionUrl();
      if (transitionUrl == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Step 4 & 5: Pass token to establish parallel LMS session cookie
      final lmsSuccess = await _lmsService.establishLmsSession(transitionUrl);
      if (lmsSuccess) {
        _enrollmentNumber = enrollment;
        _studentName =
            "FAHAD BIN NASIR"; // Initializing profile identity mock baseline
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
