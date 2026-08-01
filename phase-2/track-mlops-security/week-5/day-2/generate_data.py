import pandas as pd
import numpy as np
import os


os.makedirs('data', exist_ok=True)


print("Generating data...")
df = pd.DataFrame(np.random.randint(0, 100, size=(500000, 4)), columns=['Feature_A', 'Feature_B', 'Feature_C', 'Target'])

file_path = 'data/dataset.csv'
df.to_csv(file_path, index=False)
print(f"Create success file: {file_path}")
