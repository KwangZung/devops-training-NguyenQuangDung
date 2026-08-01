# pyrefly: ignore [missing-import]
import mlflow
import os
import pickle

with mlflow.start_run():
    mlflow.log_param("epochs", 50)
    mlflow.log_metric("accuracy", 0.99)
    print("Model trained and logged to MLflow successfully!")
    
    dummy_model = {"model_name": "Secure_RF_Model", "accuracy": 0.99}
    with open("model.pkl", "wb") as f:
        pickle.dump(dummy_model, f)
    print("Model artifact saved to model.pkl")