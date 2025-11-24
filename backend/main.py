from fastapi import FastAPI
from backend.database import Base, engine
from fastapi.middleware.cors import CORSMiddleware
from backend.routes.auth import router as auth_router
from fastapi.openapi.utils import get_openapi

app = FastAPI(
    title="Subscription API",
    description="Auth with JWT access & refresh tokens",
    version="1.0.0",
    swagger_ui_parameters={"persistAuthorization": True},
)

# Создание таблиц в базе данных
Base.metadata.create_all(bind=engine)

# Подключение роутов
app.include_router(auth_router, prefix="/auth")

# CORS (чтобы фронт мог подключаться)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # сюда позже можно вписать реальный домен фронта
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="Subscription Backend",
        version="1.0.0",
        description="API docs",
        routes=app.routes,
    )
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    # добавляем глобально
    for route in openapi_schema["paths"].values():
        for method in route.values():
            method.setdefault("security", [{"BearerAuth": []}])

    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="127.0.0.1",
        port=8000,
        reload=True
    )





