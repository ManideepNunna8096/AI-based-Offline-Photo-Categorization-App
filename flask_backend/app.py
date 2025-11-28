import os
import socket
from io import BytesIO

from flask import Flask, request, jsonify
from PIL import Image
import torch
import torchvision.models as models
import torchvision.transforms as transforms
import face_recognition

# -----------------------------
# Flask app
# -----------------------------
app = Flask(__name__)

# -----------------------------
# Model + labels (keep these files next to app.py)
# -----------------------------
MODEL_PATH = "resnet18_places365.pth.tar"
LABELS_PATH = "categories_places365.txt"

print("🔄 Loading ResNet18 Places365 model...")
# Build model structure
model = models.resnet18(num_classes=365)

# Load weights
checkpoint = torch.load(MODEL_PATH, map_location=torch.device("cpu"))
state_dict = {k.replace("module.", ""): v for k, v in checkpoint["state_dict"].items()}
model.load_state_dict(state_dict)
model.eval()
print("✅ Model loaded")

# Load classes
with open(LABELS_PATH, "r", encoding="utf-8") as f:
    classes = [line.strip().split(" ")[0][3:] for line in f]
    classes = tuple(classes)

# Preprocess
transform = transforms.Compose(
    [
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
        ),
    ]
)

def predict_scene(img_pil: Image.Image) -> str:
    """Return top-1 Places365 scene label."""
    try:
        x = transform(img_pil).unsqueeze(0)
        with torch.no_grad():
            logits = model(x)
            probs = torch.nn.functional.softmax(logits, dim=1).squeeze(0)
            top_idx = int(torch.argmax(probs))
            label = classes[top_idx].capitalize()
        return label
    except Exception as e:
        print(f"⚠️ Scene prediction failed: {e}")
        return "Unknown"

def count_faces(img_bytes: bytes) -> int:
    """Return number of faces found."""
    try:
        np_img = face_recognition.load_image_file(BytesIO(img_bytes))
        locations = face_recognition.face_locations(np_img)
        return len(locations)
    except Exception as e:
        print(f"⚠️ Face detection failed: {e}")
        return 0

# -----------------------------
# Health check
# -----------------------------
@app.route("/ping", methods=["GET"])
def ping():
    return jsonify({"status": "ok"}), 200

# -----------------------------
# Multi-image analyze (NO saving on server)
# Field name expected by Flutter: 'files'
# -----------------------------
@app.route("/upload_multiple", methods=["POST"])
def upload_multiple():
    files = request.files.getlist("files")
    if not files:
        return jsonify({"error": "No files uploaded. Use field name 'files'."}), 400

    results = []
    for f in files:
        try:
            # Read once → reuse for both PIL and face_recognition
            raw = f.read()
            img_pil = Image.open(BytesIO(raw)).convert("RGB")

            scene = predict_scene(img_pil)
            faces = count_faces(raw)

            results.append(
                {
                    "filename": f.filename,
                    "scene": scene,
                    "faces_detected": faces,
                }
            )
        except Exception as e:
            print(f"⚠️ Error handling {getattr(f, 'filename', 'unknown')}: {e}")
            results.append(
                {
                    "filename": getattr(f, "filename", "unknown"),
                    "error": str(e),
                }
            )

    return jsonify(results), 200

# -----------------------------
# Utility: local IP for Flutter input
# -----------------------------
def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't actually send; just picks a route to infer IP
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

if __name__ == "__main__":
    ip = get_local_ip()
    print("\n🌐 Open on your PHONE: ", f"http://{ip}:5000/ping")
    print("📦 Upload endpoint:    ", f"http://{ip}:5000/upload_multiple  (field: files)\n")
    app.run(host="0.0.0.0", port=5000)

