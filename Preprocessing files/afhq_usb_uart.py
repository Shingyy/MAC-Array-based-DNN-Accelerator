import os
import random
import time
import cv2
import joblib
import serial
import numpy as np
import matplotlib.pyplot as plt
from skimage.feature import hog

# Validation dataset (used to randomly select test images)
DATASET_DIR = r"C:\Users\ryank\OneDrive\Desktop\ML and Deep Learning\ML scripts\afhq\val"

# Saved preprocessing objects from training
PREPROCESSORS_PATH = "animal_classifier_preprocessors.joblib"

# UART configuration
SERIAL_PORT = "COM5"
BAUD_RATE = 9600
INTER_BYTE_DELAY = 0.001

print("Loading preprocessing objects...")
bundle = joblib.load(PREPROCESSORS_PATH)
scaler = bundle["scaler"]
pca = bundle["pca"]
minmax_scaler = bundle["minmax_scaler"]
CLASSES = bundle["classes"]
IMG_SIZE = bundle["img_size"]
print("Done.")
print(f"Classes: {CLASSES}")
print(f"Image size: {IMG_SIZE}")
print()

def extract_hog_rgb(img):
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    features = []
    for channel in range(3):
        feat = hog(
            img[:, :, channel],
            orientations=9,
            pixels_per_cell=(8, 8),
            cells_per_block=(2, 2),
            block_norm="L2-Hys",
            feature_vector=True,
        )
        features.append(feat)
    return np.concatenate(features).astype(np.float32)

def get_random_image():
    class_name = random.choice(CLASSES)
    class_dir = os.path.join(DATASET_DIR, class_name)
    files = [
        f for f in os.listdir(class_dir)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ]
    filename = random.choice(files)
    image_path = os.path.join(class_dir, filename)
    return image_path, class_name

def preprocess_image(image_path):
    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError(image_path)
    img = cv2.resize(
        img,
        IMG_SIZE,
        interpolation=cv2.INTER_AREA,
    )

    # Show image to the user
    plt.figure(figsize=(5, 5))
    plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    plt.title(os.path.basename(image_path))
    plt.axis("off")
    plt.show()

    # Extract HOG features
    hog_features = extract_hog_rgb(img).reshape(1, -1)
    print(f"HOG feature dimension: {hog_features.shape[1]}")
    # Apply the exact preprocessing used during training
    features = scaler.transform(hog_features)
    features = pca.transform(features)
    features = minmax_scaler.transform(features)
    features = features.flatten()
    print(f"Final feature dimension: {len(features)}")
    print(
        f"Feature range: [{features.min():.4f}, {features.max():.4f}]"
    )
    return features

def to_q4_4_byte(value):
    """
    Convert a float to an 8-bit signed Q4.4 value.
    Returns the byte as an unsigned integer (0-255).
    """
    value = np.clip(value, -8.0, 7.9375)
    fixed = int(np.round(value * 16))
    fixed = max(-128, min(127, fixed))
    return fixed & 0xFF

def quantise_features(features):
    """
    Convert all floating-point features into Q4.4 bytes.
    """
    return bytes(to_q4_4_byte(f) for f in features)

def print_features(features, payload):
    print("\nFeature Values")
    print("-" * 55)
    print(f"{'Idx':>4} {'Float':>12} {'Q4.4':>10} {'Hex':>8}")
    print("-" * 55)
    for i, (f, b) in enumerate(zip(features, payload)):
        signed = b if b < 128 else b - 256
        reconstructed = signed / 16.0
        print(
            f"{i:4d} "
            f"{f:12.5f} "
            f"{reconstructed:10.5f} "
            f"0x{b:02X}"
        )

def send_features(payload):
    ser = serial.Serial(
        port=SERIAL_PORT,
        baudrate=BAUD_RATE,
        bytesize=8,
        parity='N',
        stopbits=1,
        timeout=1,
    )
    print(f"\nSending {len(payload)} bytes...")
    for byte in payload:
        ser.write(bytes([byte]))
        time.sleep(INTER_BYTE_DELAY)
    ser.close()
    print("Transmission complete.")

def main():

    print("=" * 60)
    print(" FPGA Animal Classifier")
    print(" Image -> HOG -> Scaler -> PCA -> MinMax -> Q4.4 -> UART")
    print("=" * 60)

    while True:
        image_path, ground_truth = get_random_image()
        print("\n" + "=" * 60)
        print(f"Selected image : {os.path.basename(image_path)}")
        print(f"Ground truth   : {ground_truth}")
        features = preprocess_image(image_path)
        payload = quantise_features(features)
        print_features(features, payload)
        send_features(payload)
        print("\nFinished sending all features.")
        choice = input(
            "\nPress ENTER for another image or type 'q' to quit: "
        )
        if choice.lower() == "q":
            break
if __name__ == "__main__":
    main()