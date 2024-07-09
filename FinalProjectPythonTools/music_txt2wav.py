from scipy.io.wavfile import write
import numpy as np

# 读取文件内容
with open('mj_downsampled.txt', 'r') as file:
    data = file.readlines()

# 解析数据
signal = []
for line in data:
    value = int(line.strip(), 16)  # 将十六进制字符串转换为整数
    signal.append(value)

# 将信号标准化到16位
signal = np.array(signal)
signal = signal - np.min(signal)
signal = signal / np.max(signal)
signal = signal * 32767  # 标准化到16位整数范围
signal = signal.astype(np.int16)

# 生成wav文件
samplerate = 4400  # 采样率
write('output_mc.wav', samplerate, signal)

