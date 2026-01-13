from datetime import datetime, date
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import and_
from typing import List, Optional

from backend.database import get_db
from backend.models.user import User
from backend.models.subscription import Subscription, PriceHistory, Sub_category, Sub_period
from backend.schemas.sub import (
    CreateSubscriptionRequest,
    SubscriptionResponse,
    SubscriptionWithPriceHistory,
    PriceHistoryItem,
    SubCategoryEnum,
    SubPeriodEnum,
    UpdateSubscriptionRequest
)
from backend.routes.auth import get_current_user
from backend.services.notifications_service import NotificationService

router = APIRouter()
router = APIRouter(prefix="/api", tags=["subscriptions"])
@router.post("/subscriptions", 
             response_model=SubscriptionWithPriceHistory,
             status_code=status.HTTP_201_CREATED,
             summary="Создать подписку",
             description="При создании подписки автоматически добавляется первая запись в историю цен")
@router.post("/subscriptions",
             response_model=SubscriptionWithPriceHistory,
             status_code=status.HTTP_201_CREATED,
             summary="Создать подписку",
             description="При создании подписки автоматически добавляется первая запись в историю цен и создается уведомление")
def create_subscription(
        subscription_data: CreateSubscriptionRequest,
        current_user: User = Depends(get_current_user),
        db: Session = Depends(get_db)
):
    print("=" * 50)
    print("✅ CreateSubscriptionRequest model successfully validated!")
    print(f"   User ID: {current_user.id}")
    print(f"   Subscription name: {subscription_data.name}")
    print(f"   Category: {subscription_data.category}")
    print(f"   Amount: {subscription_data.currentAmount}")
    print(f"   Billing cycle: {subscription_data.billingCycle}")
    print("=" * 50)

    # Проверяем уникальность имени подписки
    existing_subscription = db.query(Subscription).filter(
        Subscription.name == subscription_data.name
    ).first()

    if existing_subscription:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Subscription with this name already exists"
        )

    # Валидация дат
    today = date.today()
    if subscription_data.nextPaymentDate and subscription_data.nextPaymentDate < today:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Next payment date cannot be in the past"
        )

    if subscription_data.connectedDate and subscription_data.connectedDate > today:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Connection date cannot be in the future"
        )

    # Проверяем notifyDays в допустимом диапазоне
    notify_days = subscription_data.notifyDays or 3
    if notify_days < 1 or notify_days > 30:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Notify days must be between 1 and 30"
        )

    # Конвертируем Enum в строки для базы данных
    category_str = subscription_data.category.value if isinstance(subscription_data.category, SubCategoryEnum) else str(
        subscription_data.category)
    billing_cycle_str = subscription_data.billingCycle.value if isinstance(subscription_data.billingCycle,
                                                                           SubPeriodEnum) else str(
        subscription_data.billingCycle)

    # Создаем новую подписку
    new_subscription = Subscription(
        userId=current_user.id,
        name=subscription_data.name,
        currentAmount=subscription_data.currentAmount,
        nextPaymentDate=subscription_data.nextPaymentDate,
        connectedDate=subscription_data.connectedDate or today,
        archivedDate=subscription_data.archivedDate,
        category=category_str,
        notifyDays=notify_days,
        billingCycle=billing_cycle_str,
        autoRenewal=subscription_data.autoRenewal or False,
        notificationsEnabled=subscription_data.notificationsEnabled or True,
        createdAt=datetime.utcnow(),
        updatedAt=datetime.utcnow()
    )

    try:
        db.add(new_subscription)
        db.commit()
        db.refresh(new_subscription)

        print(f"✅ Подписка создана с ID: {new_subscription.id}")

        # 1. Создаем первую запись в истории цен
        price_history_item = None
        if new_subscription.currentAmount > 0:
            new_price_history = PriceHistory(
                subscriptionId=new_subscription.id,
                amount=new_subscription.currentAmount,
                startDate=today,
                createdAt=datetime.utcnow()
            )
            db.add(new_price_history)
            price_history_item = new_price_history

        # 2. ✅ СОЗДАЕМ УВЕДОМЛЕНИЕ О ПОДКЛЮЧЕНИИ
        print(f"📨 Создаю уведомление для подписки {new_subscription.id}...")
        NotificationService.for_subscription_created(
            db=db,
            user_id=str(current_user.id),
            subscription_id=new_subscription.id,
            subscription_name=new_subscription.name,
            amount=new_subscription.currentAmount,
            next_payment_date=new_subscription.nextPaymentDate
        )
        print("✅ Уведомление создано!")

        db.commit()

        # Создаем ответ
        price_history_list = []
        if price_history_item:
            db.refresh(price_history_item)
            price_history_list.append(
                PriceHistoryItem(
                    id=price_history_item.id,
                    amount=price_history_item.amount,
                    startDate=price_history_item.startDate,
                    createdAt=price_history_item.createdAt
                )
            )

        response = SubscriptionWithPriceHistory(
            id=new_subscription.id,
            userId=new_subscription.userId,
            name=new_subscription.name,
            currentAmount=new_subscription.currentAmount,
            nextPaymentDate=new_subscription.nextPaymentDate,
            connectedDate=new_subscription.connectedDate,
            archivedDate=new_subscription.archivedDate,
            category=new_subscription.category,
            notifyDays=new_subscription.notifyDays,
            billingCycle=new_subscription.billingCycle,
            autoRenewal=new_subscription.autoRenewal,
            notificationsEnabled=new_subscription.notificationsEnabled,
            createdAt=new_subscription.createdAt,
            updatedAt=new_subscription.updatedAt,
            priceHistory=price_history_list
        )

        return response

    except Exception as e:
        db.rollback()
        print(f"❌ Ошибка при создании подписки: {str(e)}")
        import traceback
        traceback.print_exc()

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Subscription creation failed, please try again"
        )

@router.get("/subscriptions", 
            response_model=List[SubscriptionResponse],
            summary="Получить подписки пользователя")
def get_user_subscriptions(
    archived: bool = Query(False, description="Включить архивные подписки"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(Subscription).filter(Subscription.userId == current_user.id)
    
    if not archived:
        # Важно: archived=False должно показывать ТОЛЬКО неархивированные
        query = query.filter(Subscription.archivedDate.is_(None))
    else:
        # archived=True должно показывать ТОЛЬКО архивированные
        query = query.filter(Subscription.archivedDate.is_not(None))
    
    # Сортировка по дате следующего платежа (ближайшие сверху)
    subscriptions = query.order_by(Subscription.nextPaymentDate.asc()).all()
    
    print(f"🔍 Запрос подписок: archived={archived}, найдено: {len(subscriptions)}")
    
    return [
        SubscriptionResponse(
            id=sub.id,
            userId=sub.userId,
            name=sub.name,
            currentAmount=sub.currentAmount,
            nextPaymentDate=sub.nextPaymentDate,
            connectedDate=sub.connectedDate,
            archivedDate=sub.archivedDate,
            category=sub.category,
            notifyDays=sub.notifyDays,
            billingCycle=sub.billingCycle,
            autoRenewal=sub.autoRenewal,
            notificationsEnabled=sub.notificationsEnabled,
            createdAt=sub.createdAt,
            updatedAt=sub.updatedAt
        )
        for sub in subscriptions
    ]

@router.get("/subscriptions/{subscription_id}",
            response_model=SubscriptionWithPriceHistory,
            summary="Получить подписку по ID с историей цен")
def get_subscription_by_id(
    subscription_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    
    subscription = db.query(Subscription).filter(
        and_(
            Subscription.id == subscription_id,
            Subscription.userId == current_user.id
        )
    ).first()
    
    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subscription not found"
        )
    
    # Получаем историю цен
    price_history = db.query(PriceHistory).filter(
        PriceHistory.subscriptionId == subscription_id
    ).all()
    
    price_history_items = [
        PriceHistoryItem(
            id=ph.id,
            amount=ph.amount,
            startDate=ph.startDate,
            createdAt=ph.createdAt
        )
        for ph in price_history
    ]
    
    return SubscriptionWithPriceHistory(
        id=subscription.id,
        userId=subscription.userId,
        name=subscription.name,
        currentAmount=subscription.currentAmount,
        nextPaymentDate=subscription.nextPaymentDate,
        connectedDate=subscription.connectedDate,
        archivedDate=subscription.archivedDate,
        category=subscription.category,
        notifyDays=subscription.notifyDays,
        billingCycle=subscription.billingCycle,
        autoRenewal=subscription.autoRenewal,
        notificationsEnabled=subscription.notificationsEnabled,
        createdAt=subscription.createdAt,
        updatedAt=subscription.updatedAt,
        priceHistory=price_history_items
    )

@router.get("/subscriptions/{subscription_id}/price-history",
            response_model=List[PriceHistoryItem],
            summary="Получить историю цен подписки")
def get_subscription_price_history(
    subscription_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):

    subscription = db.query(Subscription).filter(
        and_(
            Subscription.id == subscription_id,
            Subscription.userId == current_user.id
        )
    ).first()
    
    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subscription not found"
        )

    price_history = db.query(PriceHistory).filter(
        PriceHistory.subscriptionId == subscription_id
    ).order_by(PriceHistory.startDate.desc()).all()
    
    return [
        PriceHistoryItem(
            id=ph.id,
            amount=ph.amount,
            startDate=ph.startDate,
            createdAt=ph.createdAt
        )
        for ph in price_history
    ]
@router.patch("/subscriptions/{subscription_id}",
              response_model=SubscriptionResponse,
              summary="Обновить подписку",
              description="Обновляет данные подписки. Если изменяется цена, создается новая запись в истории цен")
def update_subscription(
    subscription_id: int,
    update_data: UpdateSubscriptionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Находим подписку
    subscription = db.query(Subscription).filter(
        and_(
            Subscription.id == subscription_id,
            Subscription.userId == current_user.id
        )
    ).first()
    
    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subscription not found"
        )
    
    # Проверяем, не архивирована ли подписка
    if subscription.archivedDate:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot update archived subscription"
        )
    
    # Проверяем уникальность имени, если оно изменяется
    if update_data.name and update_data.name != subscription.name:
        existing_subscription = db.query(Subscription).filter(
            and_(
                Subscription.name == update_data.name,
                Subscription.userId == current_user.id,
                Subscription.id != subscription_id
            )
        ).first()
        
        if existing_subscription:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Subscription with this name already exists"
            )
    
    # Валидация даты следующего платежа
    if update_data.nextPaymentDate and update_data.nextPaymentDate < date.today():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Next payment date cannot be in the past"
        )
    
    # Запоминаем старую цену для проверки
    old_amount = subscription.currentAmount
    
    # Обновляем поля - используем exclude_none=True
    update_dict = update_data.dict(exclude_none=True)
    
    # Удаляем None значения, оставляем только те, что действительно переданы
    update_dict = {k: v for k, v in update_dict.items() if v is not None}
    
    # Конвертируем Enum в строки при необходимости
    if 'category' in update_dict:
        if isinstance(update_dict['category'], SubCategoryEnum):
            update_dict['category'] = update_dict['category'].value
    
    if 'billingCycle' in update_dict:
        if isinstance(update_dict['billingCycle'], SubPeriodEnum):
            update_dict['billingCycle'] = update_dict['billingCycle'].value
    
    # Обновляем подписку
    for field, value in update_dict.items():
        if hasattr(subscription, field):
            setattr(subscription, field, value)
    
    subscription.updatedAt = datetime.utcnow()
    
    try:
        # Если цена изменилась, создаем запись в истории цен
        if 'currentAmount' in update_dict and update_data.currentAmount != old_amount:
            # Завершаем текущую запись в истории цен
            current_price_history = db.query(PriceHistory).filter(
                and_(
                    PriceHistory.subscriptionId == subscription_id,
                    PriceHistory.endDate.is_(None)
                )
            ).first()
            
            if current_price_history:
                current_price_history.endDate = date.today()
            
            # Создаем новую запись
            new_price_history = PriceHistory(
                subscriptionId=subscription_id,
                amount=update_data.currentAmount,
                startDate=date.today(),
                createdAt=datetime.utcnow()
            )
            db.add(new_price_history)
        
        db.commit()
        db.refresh(subscription)
        
        # Создаем ответ вручную (без from_orm)
        return SubscriptionResponse(
            id=subscription.id,
            userId=subscription.userId,
            name=subscription.name,
            currentAmount=subscription.currentAmount,
            nextPaymentDate=subscription.nextPaymentDate,
            connectedDate=subscription.connectedDate,
            archivedDate=subscription.archivedDate,
            category=subscription.category,
            notifyDays=subscription.notifyDays,
            billingCycle=subscription.billingCycle,
            autoRenewal=subscription.autoRenewal,
            notificationsEnabled=subscription.notificationsEnabled,
            createdAt=subscription.createdAt,
            updatedAt=subscription.updatedAt
        )
        
    except Exception as e:
        db.rollback()
        print(f"❌ Ошибка при обновлении подписки: {str(e)}")
        import traceback
        traceback.print_exc()
        
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update subscription: {str(e)}"
        )
    
@router.patch("/subscriptions/{subscription_id}/archive",
              response_model=SubscriptionResponse,
              summary="Архивировать подписку",
              description="Устанавливает текущую дату в поле archivedDate")
def archive_subscription(
    subscription_id: int,
    current_user: User = Depends(get_current_user),  # Убираем archive_data из параметров
    db: Session = Depends(get_db)
):
    """
    Просто устанавливает дату архивации = сегодня.
    Тело запроса не требуется.
    """
    
    print(f"🔍 Архивация подписки ID: {subscription_id} для пользователя ID: {current_user.id}")
    
    # Находим подписку
    subscription = db.query(Subscription).filter(
        and_(
            Subscription.id == subscription_id,
            Subscription.userId == current_user.id
        )
    ).first()
    
    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Subscription not found"
        )
    
    # Проверяем, не архивирована ли уже
    if subscription.archivedDate:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Subscription is already archived"
        )
    
    # Устанавливаем дату архивации на сегодня
    subscription.archivedDate = date.today()
    subscription.updatedAt = datetime.utcnow()
    
    try:
        db.commit()
        db.refresh(subscription)
        
        print(f"✅ Подписка '{subscription.name}' успешно архивирована")
        
        # Возвращаем обновленную подписку
        return SubscriptionResponse(
            id=subscription.id,
            userId=subscription.userId,
            name=subscription.name,
            currentAmount=subscription.currentAmount,
            nextPaymentDate=subscription.nextPaymentDate,
            connectedDate=subscription.connectedDate,
            archivedDate=subscription.archivedDate,
            category=subscription.category,
            notifyDays=subscription.notifyDays,
            billingCycle=subscription.billingCycle,
            autoRenewal=subscription.autoRenewal,
            notificationsEnabled=subscription.notificationsEnabled,
            createdAt=subscription.createdAt,
            updatedAt=subscription.updatedAt
        )
        
    except Exception as e:
        db.rollback()
        print(f"❌ Ошибка при архивации: {str(e)}")
        import traceback
        traceback.print_exc()
        
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to archive subscription"
        )
