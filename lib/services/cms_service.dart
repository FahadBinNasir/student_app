import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/attendance.dart';

class CmsService {
  final http.Client _client = http.Client();
  final Map<String, String> _headers = {
    // Added final here
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
  };

  String? _cmsCookie;

  String? get cmsCookie => _cmsCookie;

  /// Step 1 & 2: Authenticate with CMS and maintain session cookie
  Future<bool> login(String enrollment, String password) async {
    try {
      final loginUrl = Uri.parse(
        'https://cms.bahria.edu.pk/Sys/Common/Login.aspx',
      );

      // 1. GET request to extract current hidden state validation properties
      final getResponse = await _client.get(loginUrl, headers: _headers);
      if (getResponse.statusCode != 200) return false;

      // Extract cookies from the initial GET if any are sent
      _updateCookies(getResponse);

      final document = html_parser.parse(getResponse.body);

      final viewState =
          document
              .querySelector('input[name="__VIEWSTATE"]')
              ?.attributes['value'] ??
          '';
      final viewStateGen =
          document
              .querySelector('input[name="__VIEWSTATEGENERATOR"]')
              ?.attributes['value'] ??
          '';
      final eventValidation =
          document
              .querySelector('input[name="__EVENTVALIDATION"]')
              ?.attributes['value'] ??
          '';

      // 2. POST payload exactly matching ASP.NET requirements
      final Map<String, String> loginFields = {
        '__VIEWSTATE': viewState,
        '__VIEWSTATEGENERATOR': viewStateGen,
        '__EVENTVALIDATION': eventValidation,
        '__EVENTTARGET': '',
        'ctl00\$BodyPH\$tbEnrollment': enrollment,
        'ctl00\$BodyPH\$tbPassword': password,
        'ctl00\$BodyPH\$ddlInstituteID': '2', // Karachi Campus
        'ctl00\$BodyPH\$ddlSubUserType': 'None',
        'ctl00\$hfJsEnabled': '0',
        'ctl00\$BodyPH\$btnLogin': 'Login',
      };

      final postResponse = await _client.post(
        loginUrl,
        headers: _headers,
        body: loginFields,
      );

      // ASP.NET normally redirects (302) on successful login
      if (postResponse.statusCode == 302 || postResponse.statusCode == 200) {
        _updateCookies(postResponse);
        // Check if authentication cookie was captured
        if (_cmsCookie != null && _cmsCookie!.contains('cms=')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Scrapes the attendance metrics table from CMS
  Future<List<Attendance>> fetchAttendance() async {
    List<Attendance> records = [];
    try {
      final attendanceUrl = Uri.parse(
        'https://cms.bahria.edu.pk/Sys/Student/Attendance.aspx',
      );
      final response = await _client.get(attendanceUrl, headers: _headers);

      if (response.statusCode != 200) return records;

      final document = html_parser.parse(response.body);
      // Locate the main data grid table containing student attendance profiles
      final tableRows = document.querySelectorAll(
        'table.gridview tr, table.table tr',
      );

      for (var i = 1; i < tableRows.length; i++) {
        // Skip table header row
        final cols = tableRows[i].querySelectorAll('td');
        if (cols.length >= 4) {
          final courseName = cols[0].text.trim();
          final totalClasses = int.tryParse(cols[1].text.trim()) ?? 0;
          final presentClasses = int.tryParse(cols[2].text.trim()) ?? 0;

          // Parse percentage string (removing the % symbol if present)
          final pctString = cols[3].text.replaceAll('%', '').trim();
          final percentage = double.tryParse(pctString) ?? 0.0;

          records.add(
            Attendance(
              courseName: courseName,
              totalClasses: totalClasses,
              presentClasses: presentClasses,
              percentage: percentage,
            ),
          );
        }
      }
    } catch (_) {}
    return records;
  }

  /// Step 3: Call this to obtain the transient token URL for LMS handoff
  Future<String?> getLmsTransitionUrl() async {
    try {
      final transitionUrl = Uri.parse(
        'https://cms.bahria.edu.pk/Sys/Common/GoToLMS.aspx',
      );

      // Request without automatically following redirects so we can intercept the location token
      final request = http.Request('GET', transitionUrl)
        ..followRedirects = false;
      request.headers.addAll(_headers);

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      final location = response.headers['location'];
      if (location != null && location.contains('lms.bahria.edu.pk')) {
        return location;
      }
    } catch (_) {}
    return null;
  }

  void _updateCookies(http.Response response) {
    final String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      _headers['Cookie'] = rawCookie;
      if (rawCookie.contains('cms=')) {
        _cmsCookie = rawCookie;
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
