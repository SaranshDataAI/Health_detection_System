import os
import glob
import json
import pickle
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from rapidfuzz import process, fuzz

# --------------------------------------------------------
# AUTO-DETECT MODEL FILE
# --------------------------------------------------------
model_files = glob.glob("model/*.pkl")
if len(model_files) == 0:
    raise FileNotFoundError("❌ No .pkl model file found in /model folder!")

# Pick the FIRST .pkl file (your nb_model.pkl)
model_path = [f for f in model_files if "label" not in f and "severity" not in f and "symptom" not in f][0]
print("Loading model:", model_path)

model = pickle.load(open(model_path, "rb"))

# --------------------------------------------------------
# Load other required assets
# --------------------------------------------------------
label_encoder = pickle.load(open("model/label_encoder.pkl", "rb"))
severity_map = pickle.load(open("model/severity_map.pkl", "rb"))
symptom_list = pickle.load(open("model/symptom_list.pkl", "rb"))

# CSV files
description_df = pd.read_csv("model/symptom_Description.csv")
precaution_df = pd.read_csv("model/symptom_precaution.csv")

# --------------------------------------------------------
# FastAPI Setup
# --------------------------------------------------------
app = FastAPI(title="Health Diagnosis API", version="1.0")

# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --------------------------------------------------------
# Request Schema
# --------------------------------------------------------
class PredictRequest(BaseModel):
    symptoms: list


# --------------------------------------------------------
# Utility — Correct Spelling / Typos Using RapidFuzz
# --------------------------------------------------------
def correct_symptom(sym):
    best_match, score, _ = process.extractOne(sym.lower().strip(), symptom_list, scorer=fuzz.WRatio)
    return best_match if score > 70 else None


# --------------------------------------------------------
# API — Predict Disease
# --------------------------------------------------------
@app.post("/predict")
async def predict(request: PredictRequest):
    if len(request.symptoms) == 0:
        raise HTTPException(status_code=400, detail="Symptom list cannot be empty.")

    # Fix spelling errors
    corrected = [correct_symptom(s) for s in request.symptoms]
    corrected = [c for c in corrected if c is not None]

    if len(corrected) == 0:
        return {"error": "No valid symptoms detected. Please try again."}

    # Build input vector (135 features)
    input_vector = [1 if sym in corrected else 0 for sym in symptom_list]
    input_df = pd.DataFrame([input_vector], columns=symptom_list)

    # Make prediction
    pred = model.predict(input_df)[0]
    disease = label_encoder.inverse_transform([pred])[0]

    # Severity score
    severity_score = sum(severity_map.get(sym, 0) for sym in corrected)
    is_serious = severity_score >= 13  # threshold chosen earlier

    # Find description
    desc_row = description_df[description_df["Disease"] == disease]
    description = desc_row["Description"].values[0] if not desc_row.empty else "No description available."

    # Find precautions
    prec_row = precaution_df[precaution_df["Disease"] == disease]
    precautions = (
        [prec_row["Precaution_1"].values[0],
         prec_row["Precaution_2"].values[0],
         prec_row["Precaution_3"].values[0],
         prec_row["Precaution_4"].values[0]]
        if not prec_row.empty else []
    )

    return {
        "predicted_disease": disease,
        "corrected_symptoms": corrected,
        "severity_score": severity_score,
        "is_serious": is_serious,
        "description": description,
        "precautions": precautions
    }


@app.get("/")
def root():
    return {"message": "Health API is running successfully!"}
