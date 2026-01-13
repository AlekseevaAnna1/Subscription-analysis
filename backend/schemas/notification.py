# schemas/notification.py
from pydantic import BaseModel, ConfigDict, field_validator
from typing import Optional, List
from datetime import datetime
import uuid


class NotificationBase(BaseModel):
    """Схема для создания уведомлений"""
    type: str
    title: str
    message: str
    scheduled_date: Optional[datetime] = None
    action_url: Optional[str] = None


class NotificationResponse(BaseModel):
    """Схема для ответа при получении уведомлений"""
    model_config = ConfigDict(from_attributes=True)

    id: str  # ✅ Меняем с uuid.UUID на str
    user_id: str  # ✅ Меняем с uuid.UUID на str
    subscription_id: int
    type: str
    title: str
    message: str
    scheduled_date: Optional[datetime] = None
    sent_at: Optional[datetime] = None
    read: bool
    action_url: Optional[str] = None
    created_at: datetime

    # ✅ Добавляем валидатор для безопасного преобразования
    @field_validator('id', 'user_id', mode='before')
    @classmethod
    def convert_to_string(cls, v):
        if isinstance(v, uuid.UUID):
            return str(v)
        # Если уже строка, оставляем как есть
        if isinstance(v, str):
            return v
        # Для любых других типов преобразуем в строку
        return str(v)


class NotificationGroup(BaseModel):
    """Схема для группировки уведомлений по подпискам (для фронтенда)"""
    subscription_id: int
    subscription_name: str
    subscription_amount: float
    subscription_category: Optional[str] = None
    notifications: List[NotificationResponse]
    unread_count: int
    last_notification_date: Optional[datetime] = None


class NotificationReadRequest(BaseModel):
    """Схема для запроса на прочтение уведомления"""
    read: bool = True


class ReadAllResponse(BaseModel):
    """Схема для ответа при прочтении всех уведомлений"""
    message: str
    count: int