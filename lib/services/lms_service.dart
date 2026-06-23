import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/assignment.dart';

class LmsService {
  final http.Client _client = http.Client();
  final Map<String, String> _headers = {
    // Added final here
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  String? _lmsCookie;

  /// Steps 4 & 5: Complete the authentication handoff using the CMS transition URL
  Future<bool> establishLmsSession(String transitionUrl) async {
    try {
      final uri = Uri.parse(transitionUrl);

      // Hit the auth.php target link to grab the tracking session token
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 302) {
        final String? setCookie = response.headers['set-cookie'];
        if (setCookie != null && setCookie.contains('PHPSESSID=')) {
          _lmsCookie = setCookie;
          _headers['Cookie'] = _lmsCookie!;
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Scrapes assignment records for a given course ID for the current semester
  Future<List<Assignment>> fetchAssignments(
    String courseId, {
    String semester = 'Spring-2026',
  }) async {
    List<Assignment> assignments = [];
    try {
      final url = Uri.parse(
        'https://lms.bahria.edu.pk/Student/Assignments.php',
      );

      // POST body parameters tracking specific assignments fields
      final Map<String, String> bodyFields = {
        'course': courseId,
        'semester': semester,
      };

      final response = await _client.post(
        url,
        headers: _headers,
        body: bodyFields,
      );
      if (response.statusCode != 200) return assignments;

      final document = html_parser.parse(response.body);

      // Pinpoint data grid matching standard assignment lists
      final tableRows = document.querySelectorAll('table tbody tr');

      for (var row in tableRows) {
        final cols = row.querySelectorAll('td');

        // Ensure standard width matching column boundaries:
        // [0]=number, [1]=title, [4]=status, [5]=marks, [7]=deadline
        if (cols.length >= 8) {
          final title = cols[1].text.trim();
          final submissionStatus = cols[4].text.trim();
          final marks = cols[5].text.trim();
          final deadline = cols[7].text.trim();

          // Evaluation mapping rule matching requirements logic
          final bool isSubmitted = submissionStatus != 'No Submission';

          // Generate a safe unique ID based on title hash + course metadata combinations
          final generatedId = '${courseId}_${title.hashCode}';

          assignments.add(
            Assignment(
              id: generatedId,
              courseId: courseId,
              title: title,
              marks: marks,
              deadlineRaw: deadline,
              isSubmitted: isSubmitted,
            ),
          );
        }
      }
    } catch (_) {}
    return assignments;
  }

  void dispose() {
    _client.close();
  }
}
