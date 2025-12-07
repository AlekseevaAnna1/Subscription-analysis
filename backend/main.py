from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, field_validator
import re
import logging

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Временное хранилище для тестирования
users_db = []


class UserCreate(BaseModel):
    email: EmailStr  # Автоматическая валидация email
    password: str

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters')
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain at least one number')
        if not any(char.isalpha() for char in v):
            raise ValueError('Password must contain at least one letter')
        return v


@app.post("/api/register")
async def register(user: UserCreate):
    logger.info(f"Registration attempt for email: {user.email}")

    # Проверяем, есть ли уже такой email
    for existing_user in users_db:
        if existing_user["email"] == user.email:
            logger.warning(f"Email already exists: {user.email}")
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )

    # Создаем нового пользователя
    new_user = {
        "id": len(users_db) + 1,
        "email": user.email,
        "password": user.password,  # В реальном приложении хэшируйте пароль!
        "created_at": "2024-01-01T00:00:00"  # Пример даты
    }

    users_db.append(new_user)

    logger.info(f"User registered: {user.email} (ID: {new_user['id']})")
    logger.info(f"Total users: {len(users_db)}")

    return {
        "message": "User registered successfully",
        "email": user.email,
        "id": new_user["id"],
        "created_at": new_user["created_at"]
    }


@app.post("/api/login")
async def login(user: UserCreate):
    logger.info(f"Login attempt for email: {user.email}")

    # Ищем пользователя
    for db_user in users_db:
        if db_user["email"] == user.email:
            if db_user["password"] == user.password:
                logger.info(f"Login successful: {user.email}")
                return {
                    "message": "Login successful",
                    "email": user.email,
                    "token": f"jwt_token_{db_user['id']}",
                    "id": db_user["id"]
                }
            else:
                logger.warning(f"Invalid password for: {user.email}")
                raise HTTPException(
                    status_code=401,
                    detail="Invalid password"
                )

    logger.warning(f"User not found: {user.email}")
    raise HTTPException(
        status_code=404,
        detail="User not found"
    )


@app.get("/api/users")
async def get_users():
    """Эндпоинт для проверки зарегистрированных пользователей"""
    logger.info(f"Fetching all users. Total: {len(users_db)}")
    return {"users": users_db, "total": len(users_db)}


@app.delete("/api/users/{user_id}")
async def delete_user(user_id: int):
    """Удалить пользователя (для тестирования)"""
    global users_db
    original_count = len(users_db)
    users_db = [user for user in users_db if user["id"] != user_id]

    if len(users_db) < original_count:
        logger.info(f"User {user_id} deleted")
        return {"message": f"User {user_id} deleted"}
    else:
        raise HTTPException(status_code=404, detail="User not found")


@app.get("/")
async def root():
    return {"message": "Subscription Analyzer API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.get("/api/test-data")
async def create_test_data():
    """Создать тестовых пользователей"""
    test_users = [
        {"email": "test@example.com", "password": "test123"},
        {"email": "user@example.com", "password": "user123"},
        {"email": "admin@example.com", "password": "admin123"},
    ]

    for test_user in test_users:
        # Проверяем, есть ли уже такой пользователь
        if not any(u["email"] == test_user["email"] for u in users_db):
            new_user = {
                "id": len(users_db) + 1,
                "email": test_user["email"],
                "password": test_user["password"],
                "created_at": "2024-01-01T00:00:00"
            }
            users_db.append(new_user)

    logger.info(f"Created test data. Total users: {len(users_db)}")
    return {"message": "Test data created", "users": users_db}


# ТОЛЬКО ОДИН ИЗ ЭТИХ ВАРИАНТОВ:
if __name__ == "__main__":
    import uvicorn

    # Вариант А: С reload (передаем как строку)
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)