import time
import numpy as np
import sounddevice as sd
import librosa
import serial
import joblib
SERIAL_PORT      = 'COM5'
BAUD_RATE        = 9600
INTER_BYTE_DELAY = 0.001      # seconds between bytes
RECORD_SR    = 48000
TARGET_SR    = 22050
DURATION     = 2              # seconds to record
DEVICE_INDEX = 9             # sounddevice input device index
SILENCE_THRESHOLD = 0.02
TARGET_RMS = 0.06098
N_MFCC     = 16
N_FFT      = 2048
HOP_LENGTH = 512
SCALER_PATH = "scaler_delta.pkl"
scaler = joblib.load(SCALER_PATH)
print(f"  Scaler loaded from '{SCALER_PATH}'.")

def record_audio():
    """Record DURATION seconds at RECORD_SR, mix to mono, resample to TARGET_SR."""
    audio = sd.rec(
        int(DURATION * RECORD_SR),
        samplerate=RECORD_SR,
        channels=2,
        device=DEVICE_INDEX,
        dtype='float32'
    )
    sd.wait()
    audio = np.mean(audio, axis=1)
    audio = librosa.resample(audio, orig_sr=RECORD_SR, target_sr=TARGET_SR)
    audio = audio - np.mean(audio)  # remove DC offset
    return audio

def is_silent(audio):
    rms = np.sqrt(np.mean(audio ** 2))
    print(f"  [RMS: {rms:.5f}]")
    return rms < SILENCE_THRESHOLD

def extract_features(audio):
    """Return 64 standardised + clipped float features."""
    trimmed, _ = librosa.effects.trim(audio, top_db=20,
                                       frame_length=512, hop_length=64)
    if len(trimmed) > TARGET_SR * 0.1:
        audio = trimmed
    rms = np.sqrt(np.mean(audio ** 2))
    if rms > 0:
        audio = audio * (TARGET_RMS / rms)
    mfcc  = librosa.feature.mfcc(y=audio, sr=TARGET_SR, n_mfcc=N_MFCC,
                                  n_fft=N_FFT, hop_length=HOP_LENGTH)
    delta = librosa.feature.delta(mfcc, mode='nearest')
    # 16 MFCC mean + 16 MFCC var + 16 delta mean + 16 delta var = 64 features
    raw = np.concatenate([
        mfcc.mean(axis=1),  mfcc.var(axis=1),
        delta.mean(axis=1), delta.var(axis=1),
    ]).reshape(1, -1)                                      # shape (1, 64)
    # Standardise with training scaler then clip to [-1, 1]
    scaled = np.clip(scaler.transform(raw), -1.0, 1.0)
    return scaled.flatten()                                # shape (64,)
 
def to_q4_4_byte(val: float) -> int:
    """
    Convert a float to a signed Q4.4 byte (int8 two's-complement).
    The FPGA recovers the value as: signed_byte / 16.0
    """
    clipped = np.clip(val, -8.0, 7.9375)
    fixed   = int(np.round(clipped * 16))
    fixed   = max(-128, min(127, fixed))
    return fixed & 0xFF                                    # pack as unsigned

def quantise_features(features: np.ndarray) -> bytes:
    """Convert 64 floats → 64 Q4.4 bytes ready for transmission."""
    return bytes(to_q4_4_byte(f) for f in features)

def send_features(payload: bytes):
    """Open COM5, transmit all 64 bytes, close."""
    ser = serial.Serial(
        port     = SERIAL_PORT,
        baudrate = BAUD_RATE,
        bytesize = 8,
        parity   = 'N',
        stopbits = 1,
        timeout  = 1
    )
    print(f"  Sending {len(payload)} bytes → {SERIAL_PORT} @ {BAUD_RATE} baud ...")
    for byte in payload:
        ser.write(bytes([byte]))
        time.sleep(INTER_BYTE_DELAY)
    ser.close()
    print("  Transmission complete.")

def print_features(features: np.ndarray, payload: bytes):
    print(f"\n  {'#':>3}  {'scaled':>12}  {'Q4.4':>8}  {'hex':>6}")
    print(f"  {'─'*3}  {'─'*12}  {'─'*8}  {'─'*6}")
    for i, (f, b) in enumerate(zip(features, payload)):
        signed = b if b < 128 else b - 256
        reconstructed = signed / 16.0
        print(f"  {i:>3}  {f:>12.4f}  {reconstructed:>8.4f}  {b:#04x}")

def main():
    print("=" * 55)
    print("  Audio → MFCC → Scaler → Q4.4 → UART  (Ctrl+C to quit)")
    print("=" * 55)
    while True:
        print("\nSpeak a digit (0-9)...")
        audio = record_audio()
        if is_silent(audio):
            print("  (silence detected — skipping)\n")
            continue
        features = extract_features(audio)   # 64 scaled floats
        payload  = quantise_features(features)  # 64 Q4.4 bytes

        print_features(features, payload)
        send_features(payload)

if __name__ == "__main__":
    main()