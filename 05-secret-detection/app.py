# ⚠️  DEMO ONLY — All values below are fake
# Created for Trivy secret scanning practice — do NOT use real secrets here

AWS_KEY    = "AKIAFAKEKEY123456789"
AWS_SECRET = "fakeAwsSecretKeyForDemoOnly123456"

DATABASE_URL = "postgres://admin:password123@localhost:5432/mydb"

def main():
    print("Secret scan demo running")

if __name__ == "__main__":
    main()
