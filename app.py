from flask import Flask

import os

app = Flask(__name__)

port = int(os.getenv("PORT", "5000"))

@app.route('/')
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port)
