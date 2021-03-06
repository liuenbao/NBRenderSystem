#include "SamplesGame.h"
#include "TriangleSample.h"

using std::string;
using std::pair;

//std::vector<std::string>* SamplesGame::_categories = NULL;
//std::vector<SamplesGame::SampleRecordList>* SamplesGame::_samples = NULL;

//// Declare our game instance
//SamplesGame game;

SamplesGame::SamplesGame()
    : _activeSample(NULL), _font(NULL)
#ifdef MODULE_GUI_ENABLED
,  _sampleSelectForm(NULL)
#endif // #ifdef MODULE_GUI_ENABLED
{
}

void SamplesGame::initialize()
{
    _font = Font::create("res/ui/arial.gpb");

//    for (size_t i = 0; i < _categories->size(); ++i)
//    {
//        std::sort((*_samples)[i].begin(), (*_samples)[i].end());
//    }
//
//#ifdef MODULE_SCRIPT_ENABLED
//    // Load camera script
//    getScriptController()->loadScript("res/common/camera.lua");
//#endif // #ifdef MODULE_SCRIPT_ENABLED
//
//    // Create the selection form
//    _sampleSelectForm = Form::create("sampleSelect", NULL, Layout::LAYOUT_VERTICAL);
//    _sampleSelectForm->setWidth(220);
//    _sampleSelectForm->setHeight(1, true);
//    _sampleSelectForm->setScroll(Container::SCROLL_VERTICAL);
//    const size_t size = _samples->size();
//    for (size_t i = 0; i < size; ++i)
//    {
//        Label* categoryLabel = Label::create((*_categories)[i].c_str());
//        categoryLabel->setFontSize(22);
//        categoryLabel->setText((*_categories)[i].c_str());
//        _sampleSelectForm->addControl(categoryLabel);
//        categoryLabel->release();
//
//        SampleRecordList list = (*_samples)[i];
//        const size_t listSize = list.size();
//        for (size_t j = 0; j < listSize; ++j)
//        {
//            SampleRecord sampleRecord = list[j];
//            Button* sampleButton = Button::create(sampleRecord.title.c_str());
//            sampleButton->setText(sampleRecord.title.c_str());
//            sampleButton->setWidth(1, true);
//            sampleButton->setHeight(50);
//            sampleButton->addListener(this, Control::Listener::CLICK);
//            _sampleSelectForm->addControl(sampleButton);
//            sampleButton->release();
//        }
//    }
//    _sampleSelectForm->setFocus();
//
//    // Disable virtual gamepads.
//    unsigned int gamepadCount = getGamepadCount();
//
//    for (unsigned int i = 0; i < gamepadCount; i++)
//    {
//        Gamepad* gamepad = getGamepad(i, false);
//        if (gamepad->isVirtual())
//        {
//            gamepad->getForm()->setEnabled(false);
//        }
//    }
//
//    SampleRecord sampleRecord = (*_samples)[0][0];
//    runSample(sampleRecord.funcPtr);
    
    _activeSample = new TriangleSample();
    _activeSample->initialize();
}

void SamplesGame::finalize()
{
    SAFE_RELEASE(_font);
    if (_activeSample)
        _activeSample->finalize();
    SAFE_DELETE(_activeSample);
//    SAFE_DELETE(_categories);
//    SAFE_DELETE(_samples);
#ifdef MODULE_GUI_ENABLED
    SAFE_RELEASE(_sampleSelectForm);
#endif // #ifdef MODULE_GUI_ENABLED
}

void SamplesGame::update(float elapsedTime)
{
    if (_activeSample)
    {
#ifdef MODULE_GUI_ENABLED
        Gamepad* gamepad = getGamepad(0);
        if (gamepad && gamepad->isButtonDown(Gamepad::BUTTON_MENU2))
        {
            exitActiveSample();
            return;
        }
#endif // #ifdef MODULE_GUI_ENABLED

#ifdef MODULE_SCRIPT_ENABLED
        getScriptController()->executeFunction<void>("camera_update", "f", elapsedTime);
#endif // #ifdef MODULE_SCRIPT_ENABLED

        _activeSample->update(elapsedTime);
        return;
    }

#ifdef MODULE_GUI_ENABLED
    _sampleSelectForm->update(elapsedTime);
#endif // #ifdef MODULE_GUI_ENABLED
}

void SamplesGame::render(float elapsedTime)
{
    if (_activeSample)
    {
        _activeSample->render(elapsedTime);
        
        // Draw back arrow
        _font->start();
        _font->drawText("<<", getWidth() - 40, 20, Vector4::one(), 28);
        _font->finish();
        return;
    }
    // Clear the color and depth buffers
    clear(CLEAR_COLOR_DEPTH, Vector4::zero(), 1.0f, 0);
#ifdef MODULE_GUI_ENABLED
    _sampleSelectForm->draw();
#endif // #ifdef MODULE_GUI_ENABLED
}

void SamplesGame::resizeEvent(unsigned int width, unsigned int height)
{
    setViewport(gameplay::Rectangle(width, height));
}

void SamplesGame::touchEvent(Touch::TouchEvent evt, int x, int y, unsigned int contactIndex)
{
    if (_activeSample)
    {
//        if (evt == Touch::TOUCH_PRESS && x >= ((int)getWidth() - 80) && y <= 80)
//        {
//            exitActiveSample();
//        }
//        else
        {
#ifdef MODULE_SCRIPT_ENABLED
            getScriptController()->executeFunction<void>("camera_touchEvent", "[Touch::TouchEvent]iiui", evt, x, y, contactIndex);
#endif // #ifdef MODULE_SCRIPT_ENABLED
            _activeSample->touchEvent(evt, x, y, contactIndex);
        }
        return;
    }
}

void SamplesGame::keyEvent(Keyboard::KeyEvent evt, int key)
{
    if (_activeSample)
    {
//        if (key == Keyboard::KEY_MENU || (evt == Keyboard::KEY_PRESS && (key == Keyboard::KEY_ESCAPE)))
//        {
//            // Pressing escape exits the active sample
//            exitActiveSample();
//        }
//        else
        {
#ifdef MODULE_SCRIPT_ENABLED
            getScriptController()->executeFunction<void>("camera_keyEvent", "[Keyboard::KeyEvent][Keyboard::Key]", evt, key);
#endif // #ifdef MODULE_SCRIPT_ENABLED
            _activeSample->keyEvent(evt, key);
        }
        return;
    }
    if (evt == Keyboard::KEY_PRESS)
    {
        switch (key)
        {
        case Keyboard::KEY_ESCAPE:
            exit();
            break;
        }
    }
}

bool SamplesGame::mouseEvent(Mouse::MouseEvent evt, int x, int y, int wheelDelta)
{
    if (_activeSample)
    {
        return _activeSample->mouseEvent(evt, x, y, wheelDelta);
    }
    return false;
}

void SamplesGame::menuEvent()
{
//    exitActiveSample();
}

void SamplesGame::gestureSwipeEvent(int x, int y, int direction)
{
    if (_activeSample)
        _activeSample->gestureSwipeEvent(x, y, direction);
}

void SamplesGame::gesturePinchEvent(int x, int y, float scale)
{
    if (_activeSample)
        _activeSample->gesturePinchEvent(x, y, scale);
}
    
void SamplesGame::gestureTapEvent(int x, int y)
{
    if (_activeSample)
        _activeSample->gestureTapEvent(x, y);
}

void SamplesGame::gestureLongTapEvent(int x, int y, float duration)
{
	if (_activeSample)
		_activeSample->gestureLongTapEvent(x, y, duration);
}

void SamplesGame::gestureDragEvent(int x, int y)
{
	if (_activeSample)
		_activeSample->gestureDragEvent(x, y);
}

void SamplesGame::gestureDropEvent(int x, int y)
{
	if (_activeSample)
		_activeSample->gestureDropEvent(x, y);
}

#ifdef MODULE_GUI_ENABLED
void SamplesGame::controlEvent(Control* control, EventType evt)
{
//    const size_t size = _samples->size();
//    for (size_t i = 0; i < size; ++i)
//    {
//        SampleRecordList list = (*_samples)[i];
//        const size_t listSize = list.size();
//        for (size_t j = 0; j < listSize; ++j)
//        {
//            SampleRecord sampleRecord = list[j];
//            if (sampleRecord.title.compare(control->getId()) == 0)
//            {
//                _sampleSelectForm->setEnabled(false);
//                runSample(sampleRecord.funcPtr);
//                return;
//            }
//        }
//    }
}

void SamplesGame::gamepadEvent(Gamepad::GamepadEvent evt, Gamepad* gamepad, unsigned int analogIndex)
{
    if (_activeSample)
        _activeSample->gamepadEvent(evt, gamepad);
}
#endif // #ifdef MODULE_GUI_ENABLED

//void SamplesGame::runSample(void* func)
//{
//    exitActiveSample();
//
//    SampleGameCreatePtr p = (SampleGameCreatePtr)func;
//
//    _activeSample = reinterpret_cast<Sample*>(p());
//    _activeSample->initialize();
//    resume();
//}
//
//void SamplesGame::exitActiveSample()
//{
//#ifdef MODULE_GUI_ENABLED
//    Gamepad* virtualGamepad = getGamepad(0, false);
//    if (virtualGamepad && virtualGamepad->isVirtual())
//    {
//        virtualGamepad->getForm()->setEnabled(false);
//    }
//#endif // #ifdef MODULE_GUI_ENABLED
//
//    if (_activeSample)
//    {
//        _activeSample->finalize();
//        SAFE_DELETE(_activeSample);
//
//#ifdef MODULE_GUI_ENABLED
//        _sampleSelectForm->setEnabled(true);
//        _sampleSelectForm->setFocus();
//#endif // #ifdef MODULE_GUI_ENABLED
//    }
//
//    // Reset some game options
//    setMultiTouch(false);
//    setMouseCaptured(false);
//}
//
//void SamplesGame::addSample(const char* category, const char* title, void* func, unsigned int order)
//{
//    if (_samples == NULL)
//        _samples = new std::vector<SampleRecordList>();
//    if (_categories == NULL)
//    {
//        _categories = new std::vector<std::string>();
//        _categories->push_back("Graphics");
//        _categories->push_back("Physics");
//        _categories->push_back("Media");
//        _categories->push_back("Input");
//        _samples->resize(_categories->size());
//    }
//
//    string categoryString(category);
//    string titleString(title);
//
//    int index = -1;
//    const int size = (int)_categories->size();
//    for (int i = 0; i < size; ++i)
//    {
//        if ((*_categories)[i].compare(categoryString) == 0)
//        {
//            index = i;
//        }
//    }
//    if (index < 0)
//    {
//        _categories->push_back(categoryString);
//        index = (int)_categories->size() - 1;
//    }
//
//    if (index <= (int)_samples->size())
//    {
//        _samples->resize(_categories->size());
//    }
//    (*_samples)[index].push_back(SampleRecord(titleString, func, order));
//}

