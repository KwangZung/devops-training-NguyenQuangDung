# pyrefly: ignore [missing-import]
import mlflow
import os

AWS_SECRET_KEY = "AKIAIOSFODNN7EXAMPLE" 

user_input = "print('MLOps Training Started')"
eval(user_input)

with mlflow.start_run():
    mlflow.log_param("epochs", 50)
    mlflow.log_metric("accuracy", 0.95)
    print("Model trained and logged to MLflow successfully!")