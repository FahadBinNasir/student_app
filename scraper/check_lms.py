import os
import sys
import json
import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, messaging

# ---------------------------------------------------------------------------
# INITIALIZE FIREBASE ADMIN ENGINE
# ---------------------------------------------------------------------------
def init_firebase():
    """Initializes Firebase Admin SDK using repository runtime environment vars."""
    cred_json_str = os.environ.get('FIREBASE_SERVICE_ACCOUNT_JSON')
    if not cred_json_str:
        print("[-] Error: Missing FIREBASE_SERVICE_ACCOUNT_JSON. Cannot push notifications.")
        sys.exit(1)
        
    try:
        cred_dict = json.loads(cred_json_str)
        cred = credentials.Certificate(cred_dict)
        firebase_admin.initialize_app(cred)
        print("[+] Firebase Admin SDK initialized successfully.")
    except Exception as e:
        print(f"[-] Failed to instantiate Firebase credentials schema: {e}")
        sys.exit(1)

# ---------------------------------------------------------------------------
# SECURE NOTIFICATION DELIVERY
# ---------------------------------------------------------------------------
def send_push_notification(token, title, body):
    """Dispatches precise FCM background sync payloads to the device channel."""
    if not token:
        print("[-] Skipping push notification dispatch: Target FCM device token is null.")
        return
        
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                sound='default',
                color='#2563EB',
            ),
        ),
        token=token,
    )
    
    try:
        response = messaging.send(message)
        print(f"[+] Notification pushed successfully. Message ID: {response}")
    except Exception as e:
        print(f"[-] FCM transaction failure down the wire: {e}")

# ---------------------------------------------------------------------------
# CMS & LMS WEBSCRAPING HANDSHAKE PIPELINE
# ---------------------------------------------------------------------------
def run_scraper():
    enrollment = os.environ.get('ENROLLMENT')
    password = os.environ.get('PASSWORD')
    device_token = os.environ.get('FCM_DEVICE_TOKEN')

    if not enrollment or not password:
        print("[-] Missing ENROLLMENT or PASSWORD environment context variables.")
        sys.exit(1)

    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5'
    })

    # Calibrated to the exact sub-directory student landing page
    login_url = "https://cms.bahria.edu.pk/Logins/Student/Login.aspx"
    
    # STEP 1: Parse passing state verification values out of hidden framework outputs
    print("[+] Fetching fresh ASP.NET ViewState metrics from CMS portal...")
    try:
        get_res = session.get(login_url, timeout=20)
        print(f"[i] CMS Server responded with Status Code: {get_res.status_code}")
        
        soup = BeautifulSoup(get_res.text, 'html.parser')
        
        vs_element = soup.find('input', {'name': '__VIEWSTATE'})
        vsg_element = soup.find('input', {'name': '__VIEWSTATEGENERATOR'})
        ev_element = soup.find('input', {'name': '__EVENTVALIDATION'})
        
        if not vs_element or not vsg_element or not ev_element:
            print("[-] Critical Error: ASP.NET lifecycle variables are missing from the HTML body.")
            sys.exit(1)
            
        view_state = vs_element['value']
        view_state_gen = vsg_element['value']
        event_val = ev_element['value']
        print("[+] Base ViewState elements compiled successfully.")
        
    except Exception as e:
        print(f"[-] Failed structural compilation of base ViewState elements: {e}")
        sys.exit(1)

    # STEP 2: Issue authoritative POST matching exact HTML structural parameters
    payload = {
        '__VIEWSTATE': view_state,
        '__VIEWSTATEGENERATOR': view_state_gen,
        '__EVENTVALIDATION': event_val,
        '__EVENTTARGET': '',
        '__EVENTARGUMENT': '',
        '__LASTFOCUS': '',
        'ctl00$BodyPH$tbEnrollment': enrollment,
        'ctl00$BodyPH$tbPassword': password,
        'ctl00$BodyPH$ddlInstituteID': '2',     # Karachi Campus
        'ctl00$BodyPH$ddlSubUserType': 'None',   # Fixed: Programmatic option mapping value for Student
        'ctl00$hfJsEnabled': '0',
        'ctl00$BodyPH$btnLogin': 'Sign In'       # Matches the new action text
    }

    print("[+] Executing stateful authentication handshake across CMS portal...")
    login_res = session.post(login_url, data=payload, timeout=20)
    
    if "cms=" not in session.cookies.get_dict():
        print("[-] Authentication Rejected: Cookie state validation checks failed.")
        sys.exit(1)
    print("[+] CMS Session established.")

    # STEP 3: Handle structural transition pass onto LMS
    print("[+] Intercepting temporary LMS redirect tracking vectors...")
    handoff_url = "https://cms.bahria.edu.pk/Sys/Common/GoToLMS.aspx"
    transition_res = session.get(handoff_url, allow_redirects=True, timeout=20)
    
    if "PHPSESSID" not in session.cookies.get_dict():
        print("[-] Handshake broken: Failed to claim PHPSESSID cookie down the chain.")
        sys.exit(1)
    print("[+] LMS Core Synchronization complete.")

    # STEP 4: Pull target Course Assignment Lists
    courses_to_check = [
        {'id': '101', 'name': 'Software Quality Engineering'},
        {'id': '103', 'name': 'Cloud Computing'},
        {'id': '106', 'name': 'Software Applications for Mobile Devices'},
        {'id': '108', 'name': 'Agile Development'}
    ]
    
    assignments_endpoint = "https://lms.bahria.edu.pk/Student/Assignments.php"
    cache_file = "scraper/last_known_state.json"
    
    if os.path.exists(cache_file):
        with open(cache_file, 'r') as f:
            history = json.load(f)
    else:
        history = {}

    current_state = {}
    new_assignments_found = []

    for course in courses_to_check:
        print(f"[+] Querying tasks data map arrays for: {course['name']}")
        course_data = {'course': course['id'], 'semester': 'Spring-2026'}
        
        res = session.post(assignments_endpoint, data=course_data, timeout=20)
        c_soup = BeautifulSoup(res.text, 'html.parser')
        
        rows = c_soup.select('table tbody tr')
        for row in rows:
            cols = row.find_all('td')
            if len(cols) >= 8:
                title = cols[1].text.strip()
                status = cols[4].text.strip()
                deadline = cols[7].text.strip()
                
                task_key = f"{course['id']}_{hash(title)}"
                current_state[task_key] = {'title': title, 'status': status, 'deadline': deadline}
                
                if task_key not in history:
                    new_assignments_found.append((course['name'], title, deadline))

    with open(cache_file, 'w') as f:
        json.dump(current_state, f, indent=4)

    # STEP 5: Parse, evaluate, and push dynamic alerts out to user device
    if new_assignments_found:
        init_firebase()
        for course_name, task_title, task_deadline in new_assignments_found:
            alert_title = f"🚨 New Assignment: {course_name}"
            alert_body = f"Title: {task_title}\nDue: {task_deadline}"
            send_push_notification(device_token, alert_title, alert_body)
    else:
        print("[+] Sync cycle complete: No unrendered assignment tracks discovered.")

if __name__ == "__main__":
    run_scraper()