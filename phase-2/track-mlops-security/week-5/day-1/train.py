# pyrefly: ignore [missing-import]
import mlflow
# pyrefly: ignore [missing-import]
import mlflow.sklearn
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split

# 1. Trỏ kết nối về phía Tracking Server vừa khởi tạo
mlflow.set_tracking_uri("http://127.0.0.1:5000")

# 2. Khởi tạo một Experiment mới để nhóm các lần chạy lại với nhau
mlflow.set_experiment("Random_Forest_Experiment")

# Tạo dữ liệu giả lập để kiểm tra (Mock data)
X = np.random.rand(100, 5)
y = np.random.rand(100)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# 3. Mở một Run session mới
with mlflow.start_run():
    # Định nghĩa các siêu tham số
    n_estimators = 50
    max_depth = 10
    
    # Ghi nhận các tham số (Parameters)
    mlflow.log_param("n_estimators", n_estimators)
    mlflow.log_param("max_depth", max_depth)
    
    # Khởi tạo và huấn luyện
    rf = RandomForestRegressor(n_estimators=n_estimators, max_depth=max_depth)
    rf.fit(X_train, y_train)
    
    # Đánh giá và ghi nhận kết quả (Metrics)
    predictions = rf.predict(X_test)
    mse = mean_squared_error(y_test, predictions)
    mlflow.log_metric("mse", mse)
    
    # Lưu mô hình hoàn thiện dưới dạng Artifact
    mlflow.sklearn.log_model(rf, "rf_model")
    
    print(f"Quá trình huấn luyện hoàn tất! MSE: {mse}")