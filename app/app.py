from flask import Flask
app = Flask(__name__)

VERSION = "1.0"

@app.route("/")
def home():
    return f"Hello from v{VERSION}"

@app.route("/health")
def health():
    return {"status": "ok"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
