#ifdef MODULE_SCRIPT_ENABLED

// Autogenerated by gameplay-luagen
#ifndef LUA_TEXT_H_
#define LUA_TEXT_H_

namespace gameplay
{

// Lua bindings for Text.
int lua_Text__gc(lua_State* state);
int lua_Text_addRef(lua_State* state);
int lua_Text_createAnimation(lua_State* state);
int lua_Text_createAnimationFromBy(lua_State* state);
int lua_Text_createAnimationFromTo(lua_State* state);
int lua_Text_destroyAnimation(lua_State* state);
int lua_Text_draw(lua_State* state);
int lua_Text_getAnimation(lua_State* state);
int lua_Text_getClip(lua_State* state);
int lua_Text_getColor(lua_State* state);
int lua_Text_getHeight(lua_State* state);
int lua_Text_getJustify(lua_State* state);
int lua_Text_getNode(lua_State* state);
int lua_Text_getOpacity(lua_State* state);
int lua_Text_getRefCount(lua_State* state);
int lua_Text_getRightToLeft(lua_State* state);
int lua_Text_getSize(lua_State* state);
int lua_Text_getText(lua_State* state);
int lua_Text_getWidth(lua_State* state);
int lua_Text_getWrap(lua_State* state);
int lua_Text_release(lua_State* state);
int lua_Text_setClip(lua_State* state);
int lua_Text_setColor(lua_State* state);
int lua_Text_setHeight(lua_State* state);
int lua_Text_setJustify(lua_State* state);
int lua_Text_setOpacity(lua_State* state);
int lua_Text_setRightToLeft(lua_State* state);
int lua_Text_setText(lua_State* state);
int lua_Text_setWidth(lua_State* state);
int lua_Text_setWrap(lua_State* state);
int lua_Text_static_ANIMATE_COLOR(lua_State* state);
int lua_Text_static_ANIMATE_OPACITY(lua_State* state);
int lua_Text_static_create(lua_State* state);

void luaRegister_Text();

}

#endif

#endif // #ifdef MODULE_SCRIPT_ENABLED