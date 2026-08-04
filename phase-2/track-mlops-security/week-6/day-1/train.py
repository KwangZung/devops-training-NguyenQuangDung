from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
import joblib
import os

# Tải dataset Iris
iris = load_iris()
X, y = iris.data, iris.target

# Huấn luyện mô hình
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)

# Lưu file model
output_dir = "/mnt/models"
os.makedirs(output_dir, exist_ok=True)
model_path = os.path.join(output_dir, "model.joblib")
joblib.dump(model, model_path)
print(f"Model saved to {model_path}")
