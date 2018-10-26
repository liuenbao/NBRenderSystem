#ifdef MODULE_SCRIPT_ENABLED

// Autogenerated by gameplay-luagen
#ifndef LUA_FORM_H_
#define LUA_FORM_H_

namespace gameplay
{

// Lua bindings for Form.
int lua_Form__gc(lua_State* state);
int lua_Form_addControl(lua_State* state);
int lua_Form_addListener(lua_State* state);
int lua_Form_addRef(lua_State* state);
int lua_Form_addScript(lua_State* state);
int lua_Form_addScriptCallback(lua_State* state);
int lua_Form_canFocus(lua_State* state);
int lua_Form_clearScripts(lua_State* state);
int lua_Form_createAnimation(lua_State* state);
int lua_Form_createAnimationFromBy(lua_State* state);
int lua_Form_createAnimationFromTo(lua_State* state);
int lua_Form_destroyAnimation(lua_State* state);
int lua_Form_draw(lua_State* state);
int lua_Form_getAbsoluteBounds(lua_State* state);
int lua_Form_getActiveControl(lua_State* state);
int lua_Form_getAlignment(lua_State* state);
int lua_Form_getAnimation(lua_State* state);
int lua_Form_getAnimationPropertyComponentCount(lua_State* state);
int lua_Form_getAnimationPropertyValue(lua_State* state);
int lua_Form_getAutoSize(lua_State* state);
int lua_Form_getBorder(lua_State* state);
int lua_Form_getBounds(lua_State* state);
int lua_Form_getClip(lua_State* state);
int lua_Form_getClipBounds(lua_State* state);
int lua_Form_getConsumeInputEvents(lua_State* state);
int lua_Form_getControl(lua_State* state);
int lua_Form_getControlCount(lua_State* state);
int lua_Form_getCursorColor(lua_State* state);
int lua_Form_getCursorRegion(lua_State* state);
int lua_Form_getCursorUVs(lua_State* state);
int lua_Form_getFocusIndex(lua_State* state);
int lua_Form_getFont(lua_State* state);
int lua_Form_getFontSize(lua_State* state);
int lua_Form_getHeight(lua_State* state);
int lua_Form_getId(lua_State* state);
int lua_Form_getImageColor(lua_State* state);
int lua_Form_getImageRegion(lua_State* state);
int lua_Form_getImageUVs(lua_State* state);
int lua_Form_getLayout(lua_State* state);
int lua_Form_getMargin(lua_State* state);
int lua_Form_getNode(lua_State* state);
int lua_Form_getOpacity(lua_State* state);
int lua_Form_getPadding(lua_State* state);
int lua_Form_getParent(lua_State* state);
int lua_Form_getRefCount(lua_State* state);
int lua_Form_getScriptEvent(lua_State* state);
int lua_Form_getScroll(lua_State* state);
int lua_Form_getScrollPosition(lua_State* state);
int lua_Form_getScrollWheelRequiresFocus(lua_State* state);
int lua_Form_getScrollWheelSpeed(lua_State* state);
int lua_Form_getScrollingFriction(lua_State* state);
int lua_Form_getSkinColor(lua_State* state);
int lua_Form_getSkinRegion(lua_State* state);
int lua_Form_getState(lua_State* state);
int lua_Form_getStyle(lua_State* state);
int lua_Form_getTextAlignment(lua_State* state);
int lua_Form_getTextColor(lua_State* state);
int lua_Form_getTextRightToLeft(lua_State* state);
int lua_Form_getTheme(lua_State* state);
int lua_Form_getTopLevelForm(lua_State* state);
int lua_Form_getTypeName(lua_State* state);
int lua_Form_getWidth(lua_State* state);
int lua_Form_getX(lua_State* state);
int lua_Form_getY(lua_State* state);
int lua_Form_getZIndex(lua_State* state);
int lua_Form_hasFocus(lua_State* state);
int lua_Form_hasScriptListener(lua_State* state);
int lua_Form_insertControl(lua_State* state);
int lua_Form_isBatchingEnabled(lua_State* state);
int lua_Form_isChild(lua_State* state);
int lua_Form_isContainer(lua_State* state);
int lua_Form_isEnabled(lua_State* state);
int lua_Form_isEnabledInHierarchy(lua_State* state);
int lua_Form_isForm(lua_State* state);
int lua_Form_isHeightPercentage(lua_State* state);
int lua_Form_isScrollBarsAutoHide(lua_State* state);
int lua_Form_isScrolling(lua_State* state);
int lua_Form_isVisible(lua_State* state);
int lua_Form_isVisibleInHierarchy(lua_State* state);
int lua_Form_isWidthPercentage(lua_State* state);
int lua_Form_isXPercentage(lua_State* state);
int lua_Form_isYPercentage(lua_State* state);
int lua_Form_moveFocus(lua_State* state);
int lua_Form_release(lua_State* state);
int lua_Form_removeControl(lua_State* state);
int lua_Form_removeListener(lua_State* state);
int lua_Form_removeScript(lua_State* state);
int lua_Form_removeScriptCallback(lua_State* state);
int lua_Form_setActiveControl(lua_State* state);
int lua_Form_setAlignment(lua_State* state);
int lua_Form_setAnimationPropertyValue(lua_State* state);
int lua_Form_setAutoSize(lua_State* state);
int lua_Form_setBatchingEnabled(lua_State* state);
int lua_Form_setBorder(lua_State* state);
int lua_Form_setBounds(lua_State* state);
int lua_Form_setCanFocus(lua_State* state);
int lua_Form_setConsumeInputEvents(lua_State* state);
int lua_Form_setCursorColor(lua_State* state);
int lua_Form_setCursorRegion(lua_State* state);
int lua_Form_setEnabled(lua_State* state);
int lua_Form_setFocus(lua_State* state);
int lua_Form_setFocusIndex(lua_State* state);
int lua_Form_setFont(lua_State* state);
int lua_Form_setFontSize(lua_State* state);
int lua_Form_setHeight(lua_State* state);
int lua_Form_setId(lua_State* state);
int lua_Form_setImageColor(lua_State* state);
int lua_Form_setImageRegion(lua_State* state);
int lua_Form_setLayout(lua_State* state);
int lua_Form_setMargin(lua_State* state);
int lua_Form_setOpacity(lua_State* state);
int lua_Form_setPadding(lua_State* state);
int lua_Form_setPosition(lua_State* state);
int lua_Form_setScroll(lua_State* state);
int lua_Form_setScrollBarsAutoHide(lua_State* state);
int lua_Form_setScrollPosition(lua_State* state);
int lua_Form_setScrollWheelRequiresFocus(lua_State* state);
int lua_Form_setScrollWheelSpeed(lua_State* state);
int lua_Form_setScrollingFriction(lua_State* state);
int lua_Form_setSize(lua_State* state);
int lua_Form_setSkinColor(lua_State* state);
int lua_Form_setSkinRegion(lua_State* state);
int lua_Form_setStyle(lua_State* state);
int lua_Form_setTextAlignment(lua_State* state);
int lua_Form_setTextColor(lua_State* state);
int lua_Form_setTextRightToLeft(lua_State* state);
int lua_Form_setVisible(lua_State* state);
int lua_Form_setWidth(lua_State* state);
int lua_Form_setX(lua_State* state);
int lua_Form_setY(lua_State* state);
int lua_Form_setZIndex(lua_State* state);
int lua_Form_static_ANIMATE_OPACITY(lua_State* state);
int lua_Form_static_ANIMATE_POSITION(lua_State* state);
int lua_Form_static_ANIMATE_POSITION_X(lua_State* state);
int lua_Form_static_ANIMATE_POSITION_Y(lua_State* state);
int lua_Form_static_ANIMATE_SCROLLBAR_OPACITY(lua_State* state);
int lua_Form_static_ANIMATE_SIZE(lua_State* state);
int lua_Form_static_ANIMATE_SIZE_HEIGHT(lua_State* state);
int lua_Form_static_ANIMATE_SIZE_WIDTH(lua_State* state);
int lua_Form_static_clearFocus(lua_State* state);
int lua_Form_static_create(lua_State* state);
int lua_Form_static_getActiveControl(lua_State* state);
int lua_Form_static_getFocusControl(lua_State* state);
int lua_Form_static_getForm(lua_State* state);
int lua_Form_stopScrolling(lua_State* state);
int lua_Form_update(lua_State* state);

void luaRegister_Form();

}

#endif

#endif // #ifdef MODULE_SCRIPT_ENABLED