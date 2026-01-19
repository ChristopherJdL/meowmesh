from flask import Flask, jsonify
import os

app = Flask(__name__)

MEOWS = {
    "english": "Meow!",
    "japanese": "ニャー (Nyaa)!",
    "french": "Miaou!",
    "german": "Miau!",
    "spanish": "Miau!",
    "korean": "야옹 !",
    "italian": "Miao!",
    "russian": "Мяу!"
}

LANGUAGE = os.getenv("CAT_LANGUAGE", "english")

@app.route("/")
def meow():
    return jsonify({
        "cat": os.getenv("HOSTNAME", "unknown-cat"),
        "language": LANGUAGE,
        "meow": MEOWS.get(LANGUAGE, "Meow!")
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
