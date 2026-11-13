from fastapi import FastAPI, Query, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import os
import uuid
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://admin:admin2026@mongodb:27017/nhodp_datasets?authSource=admin")

mongo_client = None
db = None
datasets_collection = None


async def get_collection():
    global mongo_client, db, datasets_collection
    if mongo_client is None:
        mongo_client = AsyncIOMotorClient(MONGODB_URL)
        db = mongo_client.nhodp_datasets
        datasets_collection = db.datasets
        logger.info("MongoDB connected")
    return datasets_collection


# ---------- Models ----------

class DatasetCreate(BaseModel):
    title: str
    description: str
    category: str
    tags: Optional[List[str]] = []
    license: Optional[str] = "CC BY 4.0"
    source: Optional[str] = None
    file_format: Optional[str] = "CSV"
    size_mb: Optional[float] = 0.0
    # OCR-published dataset extra fields
    ocr_job_id: Optional[str] = None
    original_filename: Optional[str] = None
    phi_removed_count: Optional[int] = None
    anonymized_text_preview: Optional[str] = None


class DatasetResponse(BaseModel):
    id: str
    title: str
    description: str
    category: str
    tags: List[str] = []
    license: str = "CC BY 4.0"
    source: Optional[str] = None
    file_format: str = "CSV"
    size_mb: float = 0.0
    downloads: int = 0
    views: int = 0
    rating: float = 0.0
    created_at: datetime
    updated_at: datetime
    ocr_job_id: Optional[str] = None
    original_filename: Optional[str] = None
    phi_removed_count: Optional[int] = None


SEED_DATASETS = [
    {
        "id": str(uuid.uuid4()), "title": "Egypt National Cancer Registry 2020-2024",
        "description": "Comprehensive cancer incidence and mortality data across all Egyptian governorates with demographic breakdowns.",
        "category": "Oncology", "tags": ["cancer", "registry", "mortality", "egypt"],
        "license": "CC BY 4.0", "source": "Ministry of Health Egypt", "file_format": "CSV",
        "size_mb": 45.2, "downloads": 1240, "views": 8930, "rating": 4.8,
        "created_at": datetime(2024, 1, 15), "updated_at": datetime(2024, 11, 1),
    },
    {
        "id": str(uuid.uuid4()), "title": "COVID-19 Cases & Vaccination Egypt 2020-2023",
        "description": "Daily COVID-19 confirmed cases, recoveries, deaths and vaccination rates by governorate.",
        "category": "Infectious Disease", "tags": ["covid19", "vaccination", "pandemic", "egypt"],
        "license": "CC BY 4.0", "source": "MOHP Egypt", "file_format": "JSON",
        "size_mb": 12.7, "downloads": 4560, "views": 22100, "rating": 4.9,
        "created_at": datetime(2020, 3, 10), "updated_at": datetime(2023, 12, 31),
    },
    {
        "id": str(uuid.uuid4()), "title": "Egyptian Diabetes Prevalence Survey 2023",
        "description": "National survey on Type 1 & Type 2 diabetes prevalence, risk factors and treatment adherence.",
        "category": "Endocrinology", "tags": ["diabetes", "prevalence", "survey", "noncommunicable"],
        "license": "CC BY-NC 4.0", "source": "Ain Shams University Hospital", "file_format": "XLSX",
        "size_mb": 8.3, "downloads": 890, "views": 5400, "rating": 4.6,
        "created_at": datetime(2023, 6, 1), "updated_at": datetime(2024, 2, 14),
    },
    {
        "id": str(uuid.uuid4()), "title": "Maternal Mortality Egypt 2015-2023",
        "description": "Maternal mortality ratio, causes of death, and antenatal care coverage by region.",
        "category": "Maternal Health", "tags": ["maternal", "mortality", "antenatal", "obstetrics"],
        "license": "CC BY 4.0", "source": "CAPMAS Egypt", "file_format": "CSV",
        "size_mb": 3.1, "downloads": 720, "views": 4200, "rating": 4.7,
        "created_at": datetime(2023, 8, 20), "updated_at": datetime(2024, 1, 10),
    },
    {
        "id": str(uuid.uuid4()), "title": "Egypt Child Immunization Coverage 2022",
        "description": "Vaccination coverage rates for children under 5 across all Egyptian governorates.",
        "category": "Pediatrics", "tags": ["vaccination", "children", "immunization", "pediatrics"],
        "license": "CC BY 4.0", "source": "UNICEF Egypt / MOHP", "file_format": "CSV",
        "size_mb": 2.4, "downloads": 560, "views": 3100, "rating": 4.5,
        "created_at": datetime(2022, 12, 1), "updated_at": datetime(2023, 5, 15),
    },
    {
        "id": str(uuid.uuid4()), "title": "Cardiovascular Disease Risk Factors Egypt",
        "description": "Blood pressure, cholesterol, smoking, and obesity prevalence data from 50,000+ participants.",
        "category": "Cardiology", "tags": ["cardiovascular", "hypertension", "obesity", "risk-factors"],
        "license": "CC BY-NC-SA 4.0", "source": "National Heart Institute Cairo", "file_format": "XLSX",
        "size_mb": 22.6, "downloads": 1100, "views": 6700, "rating": 4.7,
        "created_at": datetime(2023, 3, 5), "updated_at": datetime(2024, 3, 22),
    },
    {
        "id": str(uuid.uuid4()), "title": "Hospital Bed Capacity Egypt 2024",
        "description": "Public and private hospital beds, ICU capacity, and healthcare worker distribution.",
        "category": "Health Infrastructure", "tags": ["hospitals", "capacity", "icu", "infrastructure"],
        "license": "CC BY 4.0", "source": "MOHP Egypt", "file_format": "JSON",
        "size_mb": 1.8, "downloads": 980, "views": 7200, "rating": 4.4,
        "created_at": datetime(2024, 1, 1), "updated_at": datetime(2024, 4, 1),
    },
    {
        "id": str(uuid.uuid4()), "title": "Mental Health Prevalence Survey Egypt 2023",
        "description": "Depression, anxiety, and PTSD prevalence across age groups with treatment gap analysis.",
        "category": "Mental Health", "tags": ["mental-health", "depression", "anxiety", "psychiatry"],
        "license": "CC BY-NC 4.0", "source": "WHO Egypt / MOHP", "file_format": "PDF+CSV",
        "size_mb": 15.5, "downloads": 440, "views": 2800, "rating": 4.8,
        "created_at": datetime(2023, 10, 1), "updated_at": datetime(2024, 2, 28),
    },
    {
        "id": str(uuid.uuid4()), "title": "Tuberculosis Notification Egypt 2019-2023",
        "description": "TB case notification rates, drug resistance patterns, and treatment success rates.",
        "category": "Infectious Disease", "tags": ["tuberculosis", "tb", "drug-resistance", "notification"],
        "license": "CC BY 4.0", "source": "National TB Programme Egypt", "file_format": "CSV",
        "size_mb": 5.9, "downloads": 310, "views": 1950, "rating": 4.3,
        "created_at": datetime(2024, 3, 10), "updated_at": datetime(2024, 6, 1),
    },
    {
        "id": str(uuid.uuid4()), "title": "Hepatitis C Elimination Program Data",
        "description": "\"100 Million Health\" campaign screening and treatment outcomes for Hepatitis C.",
        "category": "Hepatology", "tags": ["hepatitis-c", "elimination", "screening", "treatment"],
        "license": "CC BY 4.0", "source": "MOHP Egypt", "file_format": "XLSX",
        "size_mb": 38.4, "downloads": 2340, "views": 14600, "rating": 4.9,
        "created_at": datetime(2019, 10, 1), "updated_at": datetime(2023, 12, 31),
    },
    {
        "id": str(uuid.uuid4()), "title": "Egypt Obesity & Nutrition Survey 2022",
        "description": "BMI distribution, dietary habits, and physical activity levels across Egyptian population.",
        "category": "Nutrition", "tags": ["obesity", "nutrition", "bmi", "diet"],
        "license": "CC BY-NC 4.0", "source": "CAPMAS / MOHP", "file_format": "CSV",
        "size_mb": 7.2, "downloads": 670, "views": 4100, "rating": 4.5,
        "created_at": datetime(2022, 8, 1), "updated_at": datetime(2023, 3, 1),
    },
    {
        "id": str(uuid.uuid4()), "title": "Neonatal Mortality & Birth Outcomes Egypt",
        "description": "Neonatal mortality rates, preterm births, low birth weight, and APGAR score distributions.",
        "category": "Neonatology", "tags": ["neonatal", "birth", "mortality", "preterm"],
        "license": "CC BY 4.0", "source": "MOHP Vital Statistics", "file_format": "CSV",
        "size_mb": 4.6, "downloads": 390, "views": 2300, "rating": 4.6,
        "created_at": datetime(2023, 5, 20), "updated_at": datetime(2024, 1, 15),
    },
]


app = FastAPI(title="NHODP Dataset Service", version="2.0.0", description="Health Dataset Catalog & Management")

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])


@app.on_event("startup")
async def startup():
    col = await get_collection()
    count = await col.count_documents({})
    if count == 0:
        await col.insert_many(SEED_DATASETS)
        logger.info(f"Seeded {len(SEED_DATASETS)} datasets")
    logger.info("Dataset Service started")


@app.on_event("shutdown")
async def shutdown():
    global mongo_client
    if mongo_client:
        mongo_client.close()


@app.get("/")
def root():
    return {"service": "Dataset Service", "version": "2.0.0", "status": "operational"}


@app.get("/health")
async def health():
    try:
        col = await get_collection()
        await col.count_documents({})
        db_status = "connected"
    except Exception:
        db_status = "disconnected"
    return {"status": "healthy", "service": "dataset", "database": db_status, "timestamp": datetime.utcnow().isoformat()}


@app.get("/datasets", response_model=List[DatasetResponse])
async def list_datasets(
    skip: int = 0,
    limit: int = 50,
    category: Optional[str] = None,
    search: Optional[str] = None,
):
    try:
        col = await get_collection()
        query = {}
        if category:
            query["category"] = category
        if search:
            query["$or"] = [
                {"title": {"$regex": search, "$options": "i"}},
                {"description": {"$regex": search, "$options": "i"}},
                {"tags": {"$in": [search]}},
            ]
        cursor = col.find(query).sort("downloads", -1).skip(skip).limit(limit)
        datasets = await cursor.to_list(length=limit)
        return [DatasetResponse(**{k: v for k, v in ds.items() if k != "_id"}) for ds in datasets]
    except Exception as e:
        logger.error(f"Error listing datasets: {e}")
        return []


@app.get("/datasets/{dataset_id}", response_model=DatasetResponse)
async def get_dataset(dataset_id: str):
    col = await get_collection()
    ds = await col.find_one({"id": dataset_id})
    if not ds:
        raise HTTPException(status_code=404, detail="Dataset not found")
    await col.update_one({"id": dataset_id}, {"$inc": {"views": 1}})
    ds["views"] = ds.get("views", 0) + 1
    return DatasetResponse(**{k: v for k, v in ds.items() if k != "_id"})


@app.post("/datasets/{dataset_id}/download")
async def record_download(dataset_id: str):
    col = await get_collection()
    result = await col.update_one({"id": dataset_id}, {"$inc": {"downloads": 1}})
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Dataset not found")
    return {"message": "Download recorded"}


@app.post("/datasets", response_model=DatasetResponse, status_code=201)
async def create_dataset(dataset: DatasetCreate):
    col = await get_collection()
    ds_dict = dataset.dict()
    new_ds = {
        "id": str(uuid.uuid4()),
        **ds_dict,
        "downloads": 0,
        "views": 0,
        "rating": 0.0,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }
    await col.insert_one(new_ds)
    return DatasetResponse(**{k: v for k, v in new_ds.items() if k != "_id"})


@app.get("/categories")
async def get_categories():
    try:
        col = await get_collection()
        pipeline = [{"$group": {"_id": "$category", "count": {"$sum": 1}, "total_downloads": {"$sum": "$downloads"}}}, {"$sort": {"count": -1}}]
        result = await col.aggregate(pipeline).to_list(length=100)
        return {"categories": [{"name": cat["_id"], "count": cat["count"], "total_downloads": cat.get("total_downloads", 0)} for cat in result]}
    except Exception as e:
        logger.error(f"Error getting categories: {e}")
        return {"categories": []}


@app.get("/search")
async def search(q: str = Query(..., min_length=2), limit: int = 20):
    try:
        col = await get_collection()
        query = {
            "$or": [
                {"title": {"$regex": q, "$options": "i"}},
                {"description": {"$regex": q, "$options": "i"}},
                {"tags": {"$in": [q.lower()]}},
                {"category": {"$regex": q, "$options": "i"}},
            ]
        }
        cursor = col.find(query).limit(limit)
        results = await cursor.to_list(length=limit)
        return {
            "query": q,
            "total": len(results),
            "results": [DatasetResponse(**{k: v for k, v in r.items() if k != "_id"}) for r in results],
        }
    except Exception as e:
        logger.error(f"Search error: {e}")
        return {"query": q, "total": 0, "results": []}


@app.get("/stats")
async def get_stats():
    try:
        col = await get_collection()
        total = await col.count_documents({})
        pipeline = [{"$group": {"_id": None, "total_downloads": {"$sum": "$downloads"}, "total_views": {"$sum": "$views"}, "avg_rating": {"$avg": "$rating"}}}]
        agg = await col.aggregate(pipeline).to_list(length=1)
        stats = agg[0] if agg else {}
        return {
            "total_datasets": total,
            "total_downloads": stats.get("total_downloads", 0),
            "total_views": stats.get("total_views", 0),
            "average_rating": round(stats.get("avg_rating", 0), 2),
        }
    except Exception as e:
        logger.error(f"Stats error: {e}")
        return {"total_datasets": 0, "total_downloads": 0, "total_views": 0, "average_rating": 0}


# ── OCR RESULT → DATASET SAVE ─────────────────────────────────
class LabResultItem(BaseModel):
    category: str = "Other"
    test_name: str
    result: str
    unit: str = ""
    reference_range: str = ""
    status: str = "normal"
    flag: Optional[str] = None


class OcrDatasetSave(BaseModel):
    ocr_job_id: str
    title: str
    description: str
    category: str = "OCR Processed"
    tags: Optional[List[str]] = []
    license: str = "CC BY 4.0"
    source: Optional[str] = "NHODP OCR Service"
    anonymized_text: str
    phi_count: int = 0
    original_filename: str = "unknown"
    submitted_by: Optional[str] = "anonymous"
    lab_results: Optional[List[LabResultItem]] = []   # ← structured extraction
    ocr_confidence: Optional[float] = None
    lab_count: Optional[int] = None


class OcrDatasetResponse(BaseModel):
    id: str
    title: str
    description: str
    category: str
    tags: List[str]
    license: str
    source: Optional[str]
    file_format: str
    size_mb: float
    downloads: int
    views: int
    rating: float
    created_at: datetime
    updated_at: datetime
    ocr_job_id: Optional[str] = None
    phi_count: Optional[int] = None
    lab_count: Optional[int] = None
    ocr_confidence: Optional[float] = None
    is_ocr_derived: bool = True


@app.post("/datasets/from-ocr", response_model=OcrDatasetResponse, status_code=201)
async def save_ocr_as_dataset(payload: OcrDatasetSave):
    """
    Save an anonymized OCR result as a new researchable dataset.
    Called after OCR processing completes and the user chooses to publish.
    """
    col = await get_collection()

    # Check for duplicate OCR job
    existing = await col.find_one({"ocr_job_id": payload.ocr_job_id})
    if existing:
        raise HTTPException(
            status_code=409,
            detail=f"Dataset from OCR job '{payload.ocr_job_id}' already published."
        )

    size_kb = len(payload.anonymized_text.encode("utf-8")) / 1024
    lab_count = len(payload.lab_results) if payload.lab_results else 0
    new_ds = {
        "id": str(uuid.uuid4()),
        "title": payload.title,
        "description": payload.description,
        "category": payload.category,
        "tags": payload.tags or ["ocr", "anonymized", "nhodp"],
        "license": payload.license,
        "source": payload.source or "NHODP OCR Service",
        "file_format": "JSON",
        "size_mb": round(size_kb / 1024, 4),
        "downloads": 0,
        "views": 0,
        "rating": 0.0,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
        # OCR-specific metadata
        "ocr_job_id": payload.ocr_job_id,
        "phi_count": payload.phi_count,
        "lab_count": lab_count,
        "ocr_confidence": payload.ocr_confidence,
        "original_filename": payload.original_filename,
        "submitted_by": payload.submitted_by,
        "anonymized_text": payload.anonymized_text,
        "lab_results": [lr.dict() for lr in (payload.lab_results or [])],
        "is_ocr_derived": True,
    }

    await col.insert_one(new_ds)
    logger.info(f"OCR-derived dataset saved: {new_ds['id']} from job {payload.ocr_job_id}")

    return OcrDatasetResponse(**{k: v for k, v in new_ds.items() if k != "_id"})


@app.get("/datasets/ocr-derived")
async def list_ocr_derived_datasets(skip: int = 0, limit: int = 20):
    """List all datasets that were created from OCR results."""
    try:
        col = await get_collection()
        cursor = col.find({"is_ocr_derived": True}).sort("created_at", -1).skip(skip).limit(limit)
        datasets = await cursor.to_list(length=limit)
        return {
            "total": await col.count_documents({"is_ocr_derived": True}),
            "datasets": [OcrDatasetResponse(**{k: v for k, v in ds.items() if k != "_id"}) for ds in datasets],
        }
    except Exception as e:
        logger.error(f"Error listing OCR datasets: {e}")
        return {"total": 0, "datasets": []}
