from pydantic import BaseModel, EmailStr, field_validator, Field
import re
from typing import Optional

class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    confirm_password: str  # ✅ ДОБАВИЛ поле подтверждения

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        v = v.lower().strip()

        disposable_domains = [
            'tempmail.com', '10minutemail.com', 'guerrillamail.com',
            'mailinator.com', 'yopmail.com', 'throwawaymail.com',
            'fakeinbox.com', 'trashmail.com', 'temp-mail.org'
        ]

        domain = v.split('@')[-1]
        if domain in disposable_domains:
            raise ValueError('Temporary email addresses are not allowed')

        return v

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if len(v) > 128:
            raise ValueError('Password must be less than 128 characters')
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain at least one number')
        if not any(char.isalpha() for char in v):
            raise ValueError('Password must contain at least one letter')
        if not any(char.isupper() for char in v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not any(char.islower() for char in v):
            raise ValueError('Password must contain at least one lowercase letter')

        special_chars = r'[!@#$%^&*(),.?":{}|<>]'
        if not re.search(special_chars, v):
            raise ValueError('Password must contain at least one special character')

        weak_passwords = [
            'password', '12345678', 'qwertyui', 'admin123',
            'letmein', 'welcome', 'monkey', '1234567890'
        ]
        if v.lower() in weak_passwords:
            raise ValueError('Password is too common, choose a stronger one')

        if re.search(r'(.)\1{2,}', v):
            raise ValueError('Password contains repeating characters')

        if re.search(r'(012|123|234|345|456|567|678|789|890)', v):
            raise ValueError('Password contains sequential numbers')

        if re.search(
                r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
                v.lower()):
            raise ValueError('Password contains sequential letters')

        return v

    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v: str, info) -> str:
        # Получаем пароль из других полей
        if 'password' in info.data and info.data['password'] != v:
            raise ValueError('Passwords do not match')
        return v