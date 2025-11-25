#!/usr/bin/env python3
"""
Phone.email OTP Testing Script
Run with: python test_phone_otp.py
Requires: pip install requests
"""

import requests
import json

# Configuration
CLIENT_ID = "16687983578815655151"
API_KEY = "I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf"
PHONE_NUMBER = "+919811226924"
API_URL = "https://api.phone.email/auth/v1/otp"

def send_otp():
    """Send OTP to the configured phone number"""
    
    print("=" * 60)
    print("🚀 Phone.email OTP Testing")
    print("=" * 60)
    print()
    print(f"📱 Phone Number: {PHONE_NUMBER}")
    print(f"🔑 Client ID: {CLIENT_ID}")
    print()
    print("📡 Sending OTP request...")
    print()
    
    headers = {
        "Content-Type": "application/json",
        "X-Client-Id": CLIENT_ID,
        "X-API-Key": API_KEY
    }
    
    payload = {
        "phone_number": PHONE_NUMBER
    }
    
    try:
        response = requests.post(
            API_URL,
            headers=headers,
            json=payload,
            timeout=10
        )
        
        print(f"📊 Status Code: {response.status_code}")
        print()
        
        # Try to parse JSON response
        try:
            data = response.json()
            print("📄 Response:")
            print(json.dumps(data, indent=2))
            print()
        except:
            print("📄 Response (raw):")
            print(response.text)
            print()
        
        # Check if successful
        if response.status_code in [200, 201]:
            print("✅ SUCCESS! OTP sent successfully")
            print()
            
            if isinstance(data, dict):
                if 'session_id' in data:
                    print(f"📨 Session ID: {data['session_id']}")
                if 'expires_in' in data:
                    print(f"⏰ Expires in: {data['expires_in']} seconds")
            
            print()
            print("💡 Check your phone for the OTP code!")
            print()
            return True
            
        else:
            print("❌ FAILED to send OTP")
            print()
            
            if isinstance(data, dict):
                if 'error' in data:
                    print(f"Error: {data['error']}")
                if 'message' in data:
                    print(f"Message: {data['message']}")
            
            print()
            return False
            
    except requests.exceptions.Timeout:
        print("❌ ERROR: Request timed out")
        print("Check your internet connection")
        return False
        
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Connection failed")
        print("Check your internet connection or firewall settings")
        return False
        
    except requests.exceptions.RequestException as e:
        print(f"❌ ERROR: {str(e)}")
        return False
        
    except Exception as e:
        print(f"❌ UNEXPECTED ERROR: {str(e)}")
        return False
    
    finally:
        print("=" * 60)

if __name__ == "__main__":
    try:
        send_otp()
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
        print("=" * 60)
