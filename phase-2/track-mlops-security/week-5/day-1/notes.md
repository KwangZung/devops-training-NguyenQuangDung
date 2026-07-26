# Lý thuyết Week 5 - DevSecOps & MLOps

## Day 1: MLOps - MLflow Tracking Server

### Tổng quan về MLflow

MLflow là một nền tảng mã nguồn mở được thiết kế để quản lý toàn bộ vòng đời của quá trình học máy. Nền tảng này giúp giải quyết các vấn đề liên quan đến việc theo dõi các thực nghiệm, tái tạo lại kết quả và triển khai mô hình học máy vào môi trường thực tế một cách đồng nhất. MLflow cung cấp bốn thành phần chính:

- **MLflow Tracking**: Hệ thống ghi nhận và truy vấn các thông số (parameters), phiên bản mã nguồn, số liệu đánh giá (metrics) và các file kết quả (artifacts) trong quá trình huấn luyện mô hình.
- **MLflow Projects**: Định dạng chuẩn để đóng gói mã nguồn phân tích dữ liệu theo cách có thể tái sử dụng và chạy lại trên nhiều môi trường khác nhau.
- **MLflow Models**: Định dạng chuẩn để đóng gói các mô hình học máy, hỗ trợ triển khai sang nhiều nền tảng serving khác nhau (ví dụ: REST API, Batch Inference).
- **MLflow Model Registry**: Kho lưu trữ tập trung đóng vai trò quản lý các phiên bản mô hình, theo dõi vòng đời từ lúc đang phát triển (Staging) đến khi đưa vào sử dụng thực tế (Production).

Trong khuôn khổ bài học này, trọng tâm sẽ được đặt vào thành phần MLflow Tracking.

### Kiến trúc của MLflow Tracking

MLflow Tracking xoay quanh khái niệm về Runs (mỗi lần chạy một đoạn mã huấn luyện) và Experiments (tập hợp của nhiều Runs có cùng mục tiêu). Khi sử dụng Tracking API, hệ thống sẽ lưu lại các thông tin sau:

- **Parameters**: Các tham số đầu vào (hyperparameters) dưới dạng key-value, ví dụ như `learning_rate` hay `batch_size`.
- **Metrics**: Các giá trị số đo lường hiệu suất mô hình có thể thay đổi theo thời gian, ví dụ như `accuracy` hoặc `loss`. Hệ thống cho phép vẽ biểu đồ xu hướng của các metric này.
- **Tags**: Metadata dạng key-value giúp phân loại và tìm kiếm các Run một cách dễ dàng.
- **Artifacts**: Các file đầu ra được tạo ra trong quá trình huấn luyện, ví dụ như mô hình đã hoàn thiện (model.pkl), file hình ảnh hoặc file dữ liệu định dạng CSV.

MLflow Tracking có thể chạy ở chế độ cục bộ (lưu file trực tiếp trong folder local) hoặc thông qua một Tracking Server. Tracking Server thường sử dụng Database (ví dụ: PostgreSQL, MySQL) để lưu trữ các tham số, metric và cấu hình một Artifact Store (ví dụ: Amazon S3, MinIO) để lưu trữ các file có kích thước lớn.

### Ghi nhận thực nghiệm (Log Experiment)

Để bắt đầu ghi nhận các thực nghiệm, ta cần tích hợp thư viện MLflow vào mã nguồn huấn luyện. Cú pháp chuẩn bao gồm việc khởi tạo một Run mới bằng hàm `mlflow.start_run()` và sử dụng các hàm API tương ứng để lưu thông tin.

Ví dụ cơ bản với thư viện scikit-learn:

```python
import mlflow
import mlflow.sklearn
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error

# Khởi tạo hoặc chọn một Experiment
mlflow.set_experiment("Dự đoán giá nhà")

# Bắt đầu một Run
with mlflow.start_run():
    # Khai báo và ghi nhận tham số
    n_estimators = 100
    max_depth = 5
    mlflow.log_param("n_estimators", n_estimators)
    mlflow.log_param("max_depth", max_depth)
    
    # Khởi tạo và huấn luyện mô hình
    rf = RandomForestRegressor(n_estimators=n_estimators, max_depth=max_depth)
    rf.fit(X_train, y_train)
    
    # Dự đoán và tính toán metric
    predictions = rf.predict(X_val)
    mse = mean_squared_error(y_val, predictions)
    
    # Ghi nhận metric
    mlflow.log_metric("mse", mse)
    
    # Ghi nhận mô hình vào Artifact
    mlflow.sklearn.log_model(rf, "random_forest_model")
```

Ngoài cách ghi nhận thủ công bằng các lệnh `log_param` và `log_metric`, MLflow còn hỗ trợ tính năng Autologging. Khi kích hoạt tính năng này (ví dụ: `mlflow.sklearn.autolog()`), MLflow sẽ tự động bắt các tham số mặc định của thuật toán và các metric tiêu chuẩn mà không cần viết lệnh ghi nhận chi tiết, giúp tiết kiệm thời gian tích hợp vào pipeline.
