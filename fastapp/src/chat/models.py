from sqlalchemy import Column, Integer,String
from src.database import Base

class Messages(Base):
    __tablename__= 'messages'
    id=Column(Integer, primary_key=True)
    message=Column(String,)

#serialize(сериализация) result from sqlalchemy to JSON
    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}