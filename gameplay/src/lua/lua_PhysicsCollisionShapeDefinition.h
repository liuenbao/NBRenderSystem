#ifdef MODULE_SCRIPT_ENABLED

#ifdef MODULE_PHYSICS_ENABLED

// Autogenerated by gameplay-luagen
#ifndef LUA_PHYSICSCOLLISIONSHAPEDEFINITION_H_
#define LUA_PHYSICSCOLLISIONSHAPEDEFINITION_H_

namespace gameplay
{

// Lua bindings for PhysicsCollisionShape::Definition.
int lua_PhysicsCollisionShapeDefinition__gc(lua_State* state);
int lua_PhysicsCollisionShapeDefinition__init(lua_State* state);
int lua_PhysicsCollisionShapeDefinition_isEmpty(lua_State* state);

void luaRegister_PhysicsCollisionShapeDefinition();

}

#endif

#endif // #ifdef MODULE_PHYSICS_ENABLED

#endif // #ifdef MODULE_SCRIPT_ENABLED