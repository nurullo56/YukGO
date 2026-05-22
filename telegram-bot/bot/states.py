from aiogram.fsm.state import State, StatesGroup

class AuthState(StatesGroup):
    """Authentication states"""
    waiting_for_phone = State()
