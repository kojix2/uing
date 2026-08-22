#!/usr/bin/env python3
"""Generate the default background loop for the air hockey example."""

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
BPM = 104
BEAT = 60.0 / BPM
BARS = 8
BEATS_PER_BAR = 4
DURATION = BARS * BEATS_PER_BAR * BEAT
FRAMES = round(DURATION * SAMPLE_RATE)
OUTPUT = Path(__file__).with_name("bgm.wav")


def midi(note):
    return 440.0 * (2.0 ** ((note - 69) / 12.0))


def clamp(value, low=-1.0, high=1.0):
    return low if value < low else high if value > high else value


def smoothstep(value):
    value = clamp(value, 0.0, 1.0)
    return value * value * (3.0 - 2.0 * value)


def adsr(time, length, attack=0.01, decay=0.08, sustain=0.65, release=0.12):
    if time < 0.0 or time >= length:
        return 0.0
    if time < attack:
        return smoothstep(time / attack)
    if time < attack + decay:
        amount = (time - attack) / decay
        return 1.0 + (sustain - 1.0) * smoothstep(amount)

    release_start = max(attack + decay, length - release)
    if time >= release_start:
        amount = (time - release_start) / max(1e-9, length - release_start)
        return sustain * (1.0 - smoothstep(amount))

    return sustain


def sine(frequency, time):
    return math.sin(2.0 * math.pi * frequency * time)


def triangle(frequency, time):
    phase = (frequency * time) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0


def soft_square(frequency, time):
    # A few odd harmonics are enough for a soft game-loop arpeggio.
    value = 0.0
    for harmonic, amplitude in ((1, 1.0), (3, 0.28), (5, 0.13), (7, 0.07)):
        value += amplitude * sine(frequency * harmonic, time)
    return value / 1.48


def one_pole_lowpass(samples, cutoff_hz):
    rc = 1.0 / (2.0 * math.pi * cutoff_hz)
    dt = 1.0 / SAMPLE_RATE
    alpha = dt / (rc + dt)
    value = 0.0
    output = []
    for sample in samples:
        value += alpha * (sample - value)
        output.append(value)
    return output


left = [0.0] * FRAMES
right = [0.0] * FRAMES


def add_stereo(start, length, synth, amplitude=1.0, pan=0.0):
    start_frame = max(0, round(start * SAMPLE_RATE))
    end_frame = min(FRAMES, round((start + length) * SAMPLE_RATE))
    left_gain = math.cos((pan + 1.0) * math.pi / 4.0)
    right_gain = math.sin((pan + 1.0) * math.pi / 4.0)

    for frame in range(start_frame, end_frame):
        time = frame / SAMPLE_RATE - start
        value = synth(time, length) * amplitude
        left[frame] += value * left_gain
        right[frame] += value * right_gain


def add_kick(start):
    def kick(time, length):
        envelope = math.exp(-10.0 * time)
        frequency = 74.0 - 32.0 * smoothstep(time / length)
        return sine(frequency, time) * envelope

    add_stereo(start, BEAT * 0.38, kick, amplitude=0.16)


def add_hat(start, pan):
    length = BEAT * 0.11
    frames = round(length * SAMPLE_RATE)
    noise = [random.uniform(-1.0, 1.0) for _ in range(frames)]
    low = one_pole_lowpass(noise, 9_000)
    high = [noise[index] - low[index] for index in range(frames)]

    def hat(time, _length):
        index = min(frames - 1, int(time * SAMPLE_RATE))
        return high[index] * math.exp(-32.0 * time)

    add_stereo(start, length, hat, amplitude=0.018, pan=pan)


def add_pad(progression, bar_length):
    for section, (_root, chord) in enumerate(progression):
        start = section * 2 * bar_length
        length = 2 * bar_length
        for index, note in enumerate(chord):
            frequency = midi(note)
            detune = 1.003 if index % 2 else 0.997
            pan = [-0.30, 0.25, -0.12, 0.18][index]

            def pad(time, note_length, freq=frequency, det=detune):
                envelope = adsr(time, note_length, 0.25, 0.35, 0.82, 0.65)
                tone = (
                    sine(freq, time) * 0.58
                    + sine(freq * det, time) * 0.30
                    + sine(freq * 2.0, time) * 0.10
                )
                return envelope * tone

            add_stereo(start, length, pad, amplitude=0.085, pan=pan)


def add_bass(progression):
    for beat in range(BARS * BEATS_PER_BAR):
        bar = beat // BEATS_PER_BAR
        section = bar // 2
        root = progression[section][0] - 12
        start = beat * BEAT
        length = BEAT * (0.72 if beat % 2 == 0 else 0.45)
        frequency = midi(root)

        def bass(time, note_length, freq=frequency):
            envelope = adsr(time, note_length, 0.006, 0.07, 0.45, 0.12)
            return envelope * (sine(freq, time) * 0.72 + triangle(freq * 0.5, time) * 0.18)

        add_stereo(start, length, bass, amplitude=0.16)


def add_arpeggio(progression):
    for step in range(BARS * 8):
        section = (step // 16) % 4
        chord = progression[section][1]
        note = chord[(step + section) % len(chord)] + (12 if step % 4 else 0)
        start = step * (BEAT / 2.0)
        length = BEAT * 0.42
        frequency = midi(note)
        pan = -0.36 if step % 2 == 0 else 0.36

        def arp(time, note_length, freq=frequency):
            return adsr(time, note_length, 0.004, 0.06, 0.28, 0.18) * soft_square(freq, time)

        add_stereo(start, length, arp, amplitude=0.035, pan=pan)


def add_percussion():
    for beat in range(BARS * BEATS_PER_BAR):
        if beat % 4 in (0, 2):
            add_kick(beat * BEAT)
        hat_pan = 0.18 if beat % 2 else -0.18
        add_hat(beat * BEAT + BEAT * 0.50, hat_pan)


def crossfade_loop():
    xfade = round(0.25 * SAMPLE_RATE)
    for channel in (left, right):
        for index in range(xfade):
            amount = index / max(1, xfade - 1)
            fade_in = math.sin(amount * math.pi / 2.0)
            fade_out = math.cos(amount * math.pi / 2.0)
            mixed = channel[index] * fade_in + channel[FRAMES - xfade + index] * fade_out
            channel[index] = mixed
            channel[FRAMES - xfade + index] *= 1.0 - smoothstep(amount)


def normalize():
    peak = max(max(abs(value) for value in left), max(abs(value) for value in right), 1e-9)
    return min(0.78 / peak, 1.0)


def write_wave(scale):
    with wave.open(str(OUTPUT), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        for left_sample, right_sample in zip(left, right):
            wav.writeframesraw(
                struct.pack(
                    "<hh",
                    int(clamp(left_sample * scale) * 32767),
                    int(clamp(right_sample * scale) * 32767),
                )
            )


def main():
    random.seed(7)
    progression = [
        (57, [57, 60, 64, 69]),  # Am
        (53, [53, 57, 60, 65]),  # F
        (48, [48, 52, 55, 60]),  # C
        (55, [55, 59, 62, 67]),  # G
    ]
    bar_length = BEATS_PER_BAR * BEAT

    add_pad(progression, bar_length)
    add_bass(progression)
    add_arpeggio(progression)
    add_percussion()
    crossfade_loop()
    write_wave(normalize())
    print(f"wrote {OUTPUT} ({DURATION:.2f}s, stereo, {SAMPLE_RATE}Hz)")


if __name__ == "__main__":
    main()
