#ifdef MODULE_SCRIPT_ENABLED

// Autogenerated by gameplay-luagen
#ifndef LUA_TRANSFORMLISTENER_H_
#define LUA_TRANSFORMLISTENER_H_

namespace gameplay
{

// Lua bindings for Transform::Listener.
int lua_TransformListener__gc(lua_State* state);
int lua_TransformListener_transformChanged(lua_State* state);

void luaRegister_TransformListener();

}

#endif

#endif // #ifdef MODULE_SCRIPT_ENABLED