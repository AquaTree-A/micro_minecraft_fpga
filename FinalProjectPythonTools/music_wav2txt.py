# import numpy as np
# import wave
# import scipy.signal
#
# # 打开原始wav文件
# music = wave.open("mj.wav", 'r')
# frame_rate = music.getframerate()
# n_channels = music.getnchannels()
# sampwidth = music.getsampwidth()
# n_frames = music.getnframes()
#
# # 读取wav文件数据
# signal = music.readframes(n_frames)
# music.close()
#
# # 将数据转换为numpy数组
# if sampwidth == 1:  # 8-bit audio
#     dtype = np.uint8
# elif sampwidth == 2:  # 16-bit audio
#     dtype = np.int16
# elif sampwidth == 3:  # 24-bit audio
#     dtype = np.int32
#     signal = np.frombuffer(signal, dtype=dtype)  # Special handling for 24-bit
#     signal = signal >> 8  # Only use the top 16-bits
# else:
#     raise ValueError("Unsupported sample width")
#
# signal = np.frombuffer(signal, dtype=dtype)
#
# # 如果是立体声，取平均值转换为单声道
# if n_channels == 2:
#     signal = signal.reshape((-1, 2)).mean(axis=1)
#
# # 降采样到17600Hz，使用抗混叠滤波器
# target_rate = 4400
# num_samples = int(len(signal) * target_rate / frame_rate)
# signal_resampled = scipy.signal.resample(signal, num_samples)
#
# # 将数据转换为16位无符号整数
# signal_resampled = np.round(signal_resampled).astype(np.uint16)
#
# # 限制输出txt的长度为20万行
# max_lines = 200000
# signal_resampled = signal_resampled[:max_lines]
#
# # 写入txt文件
# output_file = "mj_downsampled.txt"
# with open(output_file, "w") as f:
#     for i in signal_resampled:
#         f.write('{:04X}'.format(i))
#         f.write("\n")
#
# output_file

import numpy as np
import wave
import scipy.signal

def quantize_to_4bit(signal):
    # Normalize the signal to range [-1, 1]
    signal = signal / np.max(np.abs(signal))
    # Quantize to 4-bit
    signal = np.round(signal * 7)  # 4-bit has 16 levels, [-7, 7]
    signal = np.clip(signal, -7, 7)
    return signal.astype(np.int8)  # Use int8 to store values in [-7, 7]

# 打开原始wav文件
music = wave.open("mj.wav", 'r')
frame_rate = music.getframerate()
n_channels = music.getnchannels()
sampwidth = music.getsampwidth()
n_frames = music.getnframes()

# 读取wav文件数据
signal = music.readframes(n_frames)
music.close()

# 将数据转换为numpy数组
if sampwidth == 1:  # 8-bit audio
    dtype = np.uint8
elif sampwidth == 2:  # 16-bit audio
    dtype = np.int16
elif sampwidth == 3:  # 24-bit audio
    dtype = np.int32
    signal = np.frombuffer(signal, dtype=dtype)  # Special handling for 24-bit
    signal = signal >> 8  # Only use the top 16-bits
else:
    raise ValueError("Unsupported sample width")

signal = np.frombuffer(signal, dtype=dtype)

# 如果是立体声，取平均值转换为单声道
if n_channels == 2:
    signal = signal.reshape((-1, 2)).mean(axis=1)

# 重新量化为4位
signal_4bit = quantize_to_4bit(signal)

# 降采样到4400Hz，使用抗混叠滤波器
target_rate = 4400
num_samples = int(len(signal_4bit) * target_rate / frame_rate)
signal_resampled = scipy.signal.resample(signal_4bit, num_samples)

# 将数据转换为16位无符号整数
signal_resampled = np.round(signal_resampled).astype(np.uint16)

# 限制输出txt的长度为20万行
max_lines = 200000
signal_resampled = signal_resampled[:max_lines]

# 写入txt文件
output_file = "mj_downsampled.txt"
with open(output_file, "w") as f:
    for i in signal_resampled:
        f.write('{:04X}'.format(i))
        f.write("\n")

output_file
