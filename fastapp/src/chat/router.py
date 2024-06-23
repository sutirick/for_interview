from typing import List
from sqlalchemy import insert, select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import APIRouter, Depends, FastAPI, Request, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from src.database import async_session_maker, get_async_session
from src.chat.models import Messages
from src.chat.schemas import MessagesModel

router = APIRouter(
    prefix='/chat',
    tags=['Chat']
)

templates = Jinja2Templates(directory="src/templates")

@router.get('/chat')
def get_chat_page(request: Request):
    return templates.TemplateResponse('chat.html',{'request':request})

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str, add_to_db:bool):
        if add_to_db:
        #добавление записи сначала в дб
            await self.add_messages_to_database(message)
        #
        for connection in self.active_connections:
            await connection.send_text(message)
    
    @staticmethod
    async def add_messages_to_database(message: str):
        async with async_session_maker() as session:
            stmt=insert(Messages).values(
                message=message
            )
            await session.execute(stmt)
            await session.commit()

manager = ConnectionManager()

#отдача сообщений до подключения к сокету
@router.get('/last-messages')
async def get_last_messages(
    session: AsyncSession = Depends(get_async_session)
) -> List[MessagesModel]:
    query=select(Messages).order_by(Messages.id.desc()).limit(5)
    messages = await session.execute(query)
    messages = messages.all()
    messages_list = [msg[0].as_dict() for msg in messages]
    return messages_list


@router.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.send_personal_message(f"You: {data}", websocket)
            await manager.broadcast(f"Client #{client_id} says: {data}", add_to_db=True)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{client_id} left the chat", add_to_db=False)

