import pytest
from sqlalchemy import insert, select
from conftest import async_session_maker, client
from src.auth.models import role

async def test_add_role():
    async with async_session_maker() as session:
        stmt = insert(role).values(id=1, name='admin', permissons=None)
        await session.execute(stmt)
        await session.commit()
        
        query=select(role)
        result = await session.execute(query)
        assert result.all() == [(1,'admin', None)], 'Роль не добавилась'

def test_register():
    respons=client.post('/auth/register', json={
  "email": "string",
  "password": "string",
  "is_active": True,
  "is_superuser": True,
  "is_verified": False,
  "username": "string",
  "role_id": 1
})
    
    assert respons.status_code == 201

